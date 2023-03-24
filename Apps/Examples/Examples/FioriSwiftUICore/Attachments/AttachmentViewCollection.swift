//
//  AttachmentViewCollection.swift
//  Attachments
//
//  Created by Xu, Charles on 1/4/23.
//

import SwiftUI
import FioriSwiftUICore
import UniformTypeIdentifiers

final class OrientationInfo: ObservableObject {
    enum Orientation {
        case portrait
        case landscape
    }
    
    @Published var orientation: Orientation
    
    private var _observer: NSObjectProtocol?
    
    init() {
        if UIDevice.current.orientation.isLandscape {
            self.orientation = .landscape
        }
        else {
            self.orientation = .portrait
        }
        
        _observer = NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: nil) { [unowned self] note in
            guard let device = note.object as? UIDevice else {
                return
            }
            if device.orientation.isPortrait {
                self.orientation = .portrait
            }
            else if device.orientation.isLandscape {
                self.orientation = .landscape
            }
        }
    }
    
    deinit {
        if let observer = _observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

struct AttachmentViewCollection: View {
    @EnvironmentObject var orientationInfo: OrientationInfo
    
    init() {
    }
    
    var columns: [GridItem] {
        get {
            if UIDevice.current.userInterfaceIdiom == .phone {
                switch orientationInfo.orientation {
                case .portrait:
                    return [GridItem(.flexible(minimum: 80), alignment: .top)]
                case .landscape:
                    return [GridItem(.flexible(minimum: 80), alignment: .top), GridItem(.flexible(), alignment: .top)]
                }
            } else {
                switch orientationInfo.orientation {
                case .portrait:
                    return [GridItem(.flexible(minimum: 80), alignment: .top), GridItem(.flexible(), alignment: .top)]
                case .landscape:
                    return [GridItem(.flexible(minimum: 80), alignment: .top), GridItem(.flexible(), alignment: .top), GridItem(.flexible(), alignment: .top)]
                }
            }
        }
    }

    var body: some View {
        ScrollView() {
            LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
                ForEach(0...numberOfItems, id: \.self) { index in
                    if readonly(index: index) {
                        AttachmentsView<AttachmentImpl, AttachmentThumbnailView<AttachmentImpl>,  AttachmentPreview<AttachmentImpl>>(
                            title: title(index: index),
                            dataModel: dataModels[index]
                        )
                        .actions(actions: [
                            PhotoLibraryAction<AttachmentImpl>(label: "Select from Photos", onSaveImage: dataModels[index].makeFromImage),
                            CameraAction<AttachmentImpl>(label: "Take a Photo", onSaveImage: dataModels[index].makeFromImage),
                            DocumentAction<AttachmentImpl>(label: "Select from Files", allowedContentTypes: [.image, .svg, .pdf, .text, .swiftSource, UTType("org.openxmlformats.wordprocessingml.document")!, .presentation, .spreadsheet, .livePhoto, .movie], onSaveFile: dataModels[index].makeFromURL)
                        ])
                        .maxAttachment(number: maxNumberOfAttachments(index: index))
                        .readonly()
                    } else {
                        AttachmentsView<AttachmentImpl, AttachmentThumbnailView<AttachmentImpl>, AttachmentPreview<AttachmentImpl>>(
                            title: title(index: index),
                            dataModel: dataModels[index]
                        )
                        .actions(actions: [
                            PhotoLibraryAction<AttachmentImpl>(label: "Select from Photos", onSaveImage: dataModels[index].makeFromImage),
                            CameraAction<AttachmentImpl>(label: "Take a Photo", onSaveImage: dataModels[index].makeFromImage),
                            DocumentAction<AttachmentImpl>(label: "Select from Files", allowedContentTypes: [.image, .svg, .pdf, .text, .swiftSource, UTType("org.openxmlformats.wordprocessingml.document")!, .presentation, .spreadsheet, .livePhoto, .movie], onSaveFile: dataModels[index].makeFromURL)
                        ])
                        .maxAttachment(number: maxNumberOfAttachments(index: index))
                    }
                }
            }
        }
    }
    
    func title(index: Int) ->  String {
        return readonly(index: index) ? "Attachments: %d of \(maxNumberOfAttachments(index: index)), readonly: \(readonly(index: index))"
         : "Attachments: %d, readonly: \(readonly(index: index))"
    }
    
    func maxNumberOfAttachments(index: Int) -> Int {
        return index + 2
    }
    
    func readonly(index: Int) -> Bool {
        return index != 0 && index % 3 == 0
    }
}

extension Collection {
    func choose(_ n: Int) -> Array<Element> { Array(shuffled().prefix(n)) }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AttachmentViewCollection()
            .environmentObject(OrientationInfo())
    }
}
