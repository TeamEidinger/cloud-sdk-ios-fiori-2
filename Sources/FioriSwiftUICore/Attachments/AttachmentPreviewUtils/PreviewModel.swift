//
//  MockModel.swift
//  
//
//  Created by Xu, Charles on 3/16/23.
//

import SwiftUI
import UniformTypeIdentifiers

#if DEBUG

public class PreviewModel: AttachmentDataModel<AttachmentImpl> {
    private static var singleton: PreviewModel = PreviewModel()
                                                        
    init() {
        super.init { previewWorkingDirectoryUrl in
            func makeAttachment(url: URL) -> AttachmentImpl? {
                var sizeDate: (String?, String?) {
                    do {
                        let resource =  try url.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey])
                        let fileSize = resource.fileSize!
                        let date = resource.contentModificationDate
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MMM dd,yyyy"
                        return (ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file), date != nil ? dateFormatter.string(from: date!) : nil)
                    } catch {
                        print(error)
                        return (nil, nil)
                    }
                }
                
                return AttachmentImpl(logicalUrl: url.absoluteString, title: url.lastPathComponent, subtitle: sizeDate.0, moreInfo: sizeDate.1, thumbnail: nil, physicalUrl: url)
            }

            return [
                Self.shortNamePdf(inDirectory: previewWorkingDirectoryUrl),
                Self.shortNameHtml(inDirectory: previewWorkingDirectoryUrl),
                Self.shortNameMd(inDirectory: previewWorkingDirectoryUrl),
                Self.shortNameText(inDirectory: previewWorkingDirectoryUrl),
                Self.shortNameImage(inDirectory: previewWorkingDirectoryUrl),
                Self.shortNameZip(inDirectory: previewWorkingDirectoryUrl),
                Self.longNamePdf(inDirectory: previewWorkingDirectoryUrl),
                Self.longNameHtml(inDirectory: previewWorkingDirectoryUrl),
                Self.longNameMd(inDirectory: previewWorkingDirectoryUrl),
                Self.longNameText(inDirectory: previewWorkingDirectoryUrl),
                Self.longNameImage(inDirectory: previewWorkingDirectoryUrl),
                Self.longNameZip(inDirectory: previewWorkingDirectoryUrl)
            ].compactMap{ $0 }.compactMap { makeAttachment(url: $0) }
        }
    }
    
    public static func shortNamePdf(inDirectory previewDirectory: URL) -> URL? {
        return PDFGenerator(name: "PDF Demo.pdf", path: previewDirectory, content: "<b><i>PDF</i> Demo</b> <p>Generated PDF file from HTML content!</p>").url
    }
    
    public static func shortNameHtml(inDirectory previewDirectory: URL) -> URL? {
        return TextGenerator(name: "HTML Demo.html", path: previewDirectory, content: "<html><body><b><i>PDF</i> Demo</b> <p>Generated PDF file from HTML content!</p></body></html>").url
    }

    public static func shortNameMd(inDirectory previewDirectory: URL) -> URL? {
        return TextGenerator(name: "MD Demo.md", path: previewDirectory, content: "# The largest heading\n## The second largest heading\n###### The smallest heading\nMD Demo").url
    }
    
    public static func shortNameText(inDirectory previewDirectory: URL) -> URL? {
        return TextGenerator(name: "Text Demo.txt", path: previewDirectory, content: "Text Demo\n\nGenerated Text file!\n\n\nMarch 16, 2023").url
    }

    public static func shortNameImage(inDirectory previewDirectory: URL) -> URL? {
        ImageGenerator(name: "Image Demo.JPG", path: previewDirectory).url
    }

    public static func shortNameZip(inDirectory previewDirectory: URL) -> URL? {
        return ZipGenerator(name: "Zip Demo.zip", path: previewDirectory).url
    }

    public static func longNamePdf(inDirectory previewDirectory: URL) -> URL? {
        return  PDFGenerator(name: "PDF document with very very long long long long long name.pdf", path: previewDirectory, content: "<b><i>PDF</i> Demo</b> <p>Generated PDF file from HTML content!</p>").url
    }

    public static func longNameHtml(inDirectory previewDirectory: URL) -> URL? {
        return TextGenerator(name: "HTML document with very very long long long long long name.html", path: previewDirectory, content: "<html><body><b><i>PDF</i> Demo</b> <p>Generated PDF file from HTML content!</p></body></html>").url
    }

    public static func longNameMd(inDirectory previewDirectory: URL) -> URL? {
        return TextGenerator(name: "MD document with very very long long long long long name.md", path: previewDirectory, content: "# The largest heading\n## The second largest heading\n###### The smallest heading\nMD Demo").url
    }

    public static func longNameText(inDirectory previewDirectory: URL) -> URL? {
        return TextGenerator(name: "Text document with very very long long long long long name.txt", path: previewDirectory, content: "Text Demo\n\nGenerated Text file!\n\n\nMarch 16, 2023").url
    }

    public static func longNameImage(inDirectory previewDirectory: URL) -> URL? {
        return ImageGenerator(name: "Image document with very very long long long long long name.JPG", path: previewDirectory).url
    }

    public static func longNameZip(inDirectory previewDirectory: URL) -> URL? {
        return ZipGenerator(name: "Zip document with very very long long long long long name.zip", path: previewDirectory).url
    }

    public var defaultPreviewAttachments: [AttachmentImpl] {
        return self.attachments
    }

    public var defaultPreviewAttachmentsWithoutTitle: [AttachmentImpl] {
        return defaultPreviewAttachments.compactMap {
            AttachmentImpl(logicalUrl: $0.logicalUrl, title: nil, subtitle: $0.subtitle, thumbnail: $0.thumbnail, physicalUrl: $0.physicalUrl)
        }
    }

    public var defaultPreviewAttachmentsWithoutTitleAndSubtitle: [AttachmentImpl] {
        return defaultPreviewAttachments.compactMap {
            AttachmentImpl(logicalUrl: $0.logicalUrl, title: nil, subtitle: nil, thumbnail: $0.thumbnail, physicalUrl: $0.physicalUrl)
        }
    }

    public var defaultPreviewAttachmentsWithThumbnail: [AttachmentImpl] {
        return defaultPreviewAttachments.compactMap {
            AttachmentImpl(logicalUrl: $0.logicalUrl, title: $0.title, subtitle: $0.subtitle, thumbnail: UIImage(systemName: "square.dashed.inset.filled"), physicalUrl: $0.physicalUrl)
        }
    }

    public var defaultPreviewAttachmentsWithoutThumbnailAndPhysicalUrl: [AttachmentImpl] {
        return defaultPreviewAttachments.compactMap {
            AttachmentImpl(logicalUrl: $0.logicalUrl, title: $0.title, subtitle: $0.subtitle, thumbnail: nil, physicalUrl: nil)
        }
    }

    var defaultPreviewAttachmentContext: AttachmentContext {
        return AttachmentContext()
    }


    public var defaultPreviewAttachmentModel: AttachmentDataModel<AttachmentImpl> {
        return AttachmentDataModel(attachments: defaultPreviewAttachments)
    }
    
    public var defaultEmptyPreviewAttachmentModel: AttachmentDataModel<AttachmentImpl> {
        return AttachmentDataModel<AttachmentImpl>(attachments: [])
    }
    
    public var defaultPreviewAttachmentModelWithoutTitle: AttachmentDataModel<AttachmentImpl> {
        return AttachmentDataModel(attachments: defaultPreviewAttachmentsWithoutTitle)
    }
    
    public var defaultPreviewAttachmentModelWithoutTitleAndSubtitle: AttachmentDataModel<AttachmentImpl> {
        return AttachmentDataModel(attachments: defaultPreviewAttachmentsWithoutTitleAndSubtitle)
    }
    
    public var defaultPreviewAttachmentModeltWithThumbnail: AttachmentDataModel<AttachmentImpl> {
        return AttachmentDataModel(attachments: defaultPreviewAttachmentsWithThumbnail)
    }
    
    public var defaultPreviewAttachmentModelWithoutThumbnailAndPhysicalUrl: AttachmentDataModel<AttachmentImpl> {
        return AttachmentDataModel(attachments: defaultPreviewAttachmentsWithoutThumbnailAndPhysicalUrl)
    }

    public var defaultPreviewPhotoAction: PhotoLibraryAction<AttachmentImpl> {
        return PhotoLibraryAction<AttachmentImpl>(label: "Select from Photos", onSaveImage: makeFromImage)
    }
    
    public var defaultPreviewCameraAction: CameraAction<AttachmentImpl> {
        return CameraAction<AttachmentImpl>(label: "Take a Photo", onSaveImage: makeFromImage)
    }
    
    public var defaultPreviewDocumentAction: DocumentAction<AttachmentImpl> {
        return DocumentAction<AttachmentImpl>(label: "Select from Files", allowedContentTypes: [.image, .svg, .pdf, .text, .swiftSource, UTType("org.openxmlformats.wordprocessingml.document")!, .presentation, .spreadsheet, .livePhoto, .movie], onSaveFile: makeFromURL)
    }
    
    public var defaultPreviewClosureAction: ClosureAction<AttachmentImpl> {
        return ClosureAction<AttachmentImpl>(label: "Closure") { print("running in action closure") }
    }

    public var defaultPreviewAllActions: [BaseAction<AttachmentImpl>] {
        return [defaultPreviewPhotoAction, defaultPreviewCameraAction, defaultPreviewDocumentAction, defaultPreviewClosureAction]
    }

    public static var model: PreviewModel {
        return singleton
    }
}

public struct AttachmentGeneratorView: View {
    let model = PreviewModel.model
    
    public init() {
    }
    
    public var body: some View {
        List {
            ForEach(0..<model.defaultPreviewAttachments.count, id: \.self) { index in
                Text(model.defaultPreviewAttachments[index].logicalUrl)
            }
        }
    }
}

struct AttachmentGeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        AttachmentGeneratorView()
    }
}

#endif
