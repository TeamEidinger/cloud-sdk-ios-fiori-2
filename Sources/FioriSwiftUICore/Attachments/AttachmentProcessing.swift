//
//  AttachmentProcessing.swift
//  Attachments
//
//  Created by Xu, Charles on 2/20/23.
//
import UIKit
import QuickLook

public protocol AttachmentProcessing: Identifiable, QLPreviewItem {
    var id: String { get }
    var logicalUrl: String { get }
    
    var title: String? { get }
    var subtitle: String? { get }
    var moreInfo: String? { get }
    var thumbnail: UIImage? { get }
    var physicalUrl: URL? { get }
    
    init(id: String, logicalUrl: String, title: String?, subtitle: String?, moreInfo: String?, thumbnail: UIImage?, physicalUrl: URL?)
}

public class AttachmentImpl: NSObject, AttachmentProcessing {
    public let id: String
    public let logicalUrl: String
    public let title: String?
    public let subtitle: String?
    public let moreInfo: String?
    public let thumbnail: UIImage?
    public let physicalUrl: URL?

    required public init(id: String = UUID().uuidString, logicalUrl: String, title: String? = nil, subtitle: String? = nil, moreInfo: String? = nil, thumbnail: UIImage? = nil, physicalUrl: URL? = nil) {
        self.id = id
        self.logicalUrl = logicalUrl
        self.title = title
        self.subtitle = subtitle
        self.moreInfo = moreInfo
        self.thumbnail = thumbnail
        self.physicalUrl = physicalUrl
    }
    
    public var previewItemURL: URL? {
        return physicalUrl ?? URL(string: logicalUrl)
    }
    
    public var previewItemTitle: String? {
        return title
    }
}


public class AttachmentDataModel<Attachment: AttachmentProcessing>: ObservableObject {
    @Published public var attachments: [Attachment]
    public let tempWorkingDirectoryUrl: URL
    private var count: Int

    
    public init(attachments: [Attachment], tempWorkingDirectoryUrl: URL? = nil) {
        self.attachments = attachments
        self.count = 0
        if let tempDirPath = tempWorkingDirectoryUrl {
            self.tempWorkingDirectoryUrl = tempDirPath
        } else {
            let tempDirPath: String = NSTemporaryDirectory() + "attachments/\(UUID().uuidString)"
            self.tempWorkingDirectoryUrl = URL(fileURLWithPath: tempDirPath, isDirectory: true)
        }
        prepareWorkingDirectory()
    }
        
    public init(setup: (URL) -> [Attachment]) {
        self.attachments = [Attachment]()
        self.count = 0
        let tempDirPath: String = NSTemporaryDirectory() + "attachments/\(UUID().uuidString)"
        self.tempWorkingDirectoryUrl = URL(fileURLWithPath: tempDirPath, isDirectory: true)
        self.prepareWorkingDirectory()
        self.attachments = setup(self.tempWorkingDirectoryUrl)
    }
    
    private func prepareWorkingDirectory() {
        if FileManager.default.fileExists(atPath: self.tempWorkingDirectoryUrl.absoluteString) {
            do {
                print("deleting files in \(self.tempWorkingDirectoryUrl.absoluteString)")
                try FileManager.default.removeItem(at: self.tempWorkingDirectoryUrl)
            } catch let error as NSError {
                fatalError("Failed to list files in \(self.tempWorkingDirectoryUrl.absoluteString): \(error)")
            }
        }

        do {
            print("Creating temporary directory - \(self.tempWorkingDirectoryUrl.absoluteString)")
            try FileManager.default.createDirectory(at: self.tempWorkingDirectoryUrl, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            fatalError("Failed to create directory \(self.tempWorkingDirectoryUrl.absoluteString) - \(error)")
        }
    }
    
    private func saveFile(_ fileUrl: URL) -> URL? {
        return saveToTempFolder(url: fileUrl, fileName: nil, model: nil)
    }

    func saveToTempFolder(url :URL?, fileName: String?, model: Data?) -> URL? {
        guard url != nil || (fileName != nil && model != nil) else {
            return nil
        }
        
        let fileManager = FileManager.default
        let tempFolderUrl = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
        let attacmentFolderUrl = tempFolderUrl.appendingPathComponent("attachments", isDirectory: true)
        
        do {
            if !fileManager.fileExists(atPath: attacmentFolderUrl.path) {
                try fileManager.createDirectory(at: attacmentFolderUrl, withIntermediateDirectories: false, attributes: nil)
            }
            if let url = url {
                let fileUrl = attacmentFolderUrl.appendingPathComponent(url.lastPathComponent, isDirectory: false)
                if !fileManager.fileExists(atPath: fileUrl.path) {
                    try fileManager.copyItem(at: url, to: fileUrl)
                }
                return fileUrl
            }
            if let fileName = fileName, let model = model {
                let fileUrl = attacmentFolderUrl.appendingPathComponent(fileName, isDirectory: false)
                try model.write(to: fileUrl)
                return fileUrl
            }
        } catch let error as NSError {
            print("ERROR: Failed copy file \(String(describing: url)) \(String(describing: fileName)) to temp attachment folder: \(error)")
        }
        return nil
    }
    
    public func makeFromURL(_ url: URL) -> Attachment? {
        guard let url = saveFile(url) else { return nil }
        return makeAttachment(url: url)
    }
    
    private func saveImage(_ uiImage: UIImage) -> URL? {
        guard let model =  uiImage.jpegData(compressionQuality: 1.0) else {
            print("UIImageJPEGRepresentation failed to get data from photo image")
            return nil
        }
        
        let tempURL = tempWorkingDirectoryUrl.appendingPathComponent(String(format: "%d.%@", count, "JPG"), isDirectory: false)

        do {
            try model.write(to: tempURL)
            count += 1
            print("Done saving image to temporary folder \(tempURL)")
        } catch let error as NSError {
            print("Failed to save image to temporary folder - \(error)")
            return nil
        }

        return tempURL
    }


    public func makeFromImage(_ uiImage: UIImage) -> Attachment? {
        guard let url = saveImage(uiImage) else { return nil }
        return makeAttachment(url: url)
    }
    
    private func makeAttachment(url: URL) -> Attachment? {
        let sizeDate = getSizeDate(url: url)
        guard let size = sizeDate.0, let date = sizeDate.1 else {
            return Attachment(id: UUID().uuidString, logicalUrl: url.absoluteString, title: url.lastPathComponent, subtitle: nil, moreInfo: nil, thumbnail: nil, physicalUrl: url)
        }
        return Attachment(id: UUID().uuidString, logicalUrl: url.absoluteString, title: url.lastPathComponent, subtitle: size, moreInfo: date, thumbnail: nil, physicalUrl: url)
    }
    
    private func getSizeDate(url: URL) -> (String?, String?) {
        do {
            let resource =  try url.resourceValues(forKeys: [.fileSizeKey, .creationDateKey])
            guard let fileSize = resource.fileSize, let date = resource.contentModificationDate else {
                return (nil, nil)
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd,yyyy"
            return (ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file), dateFormatter.string(from: date))
        } catch {
            print(error)
            return (nil, nil)
        }
    }

}
