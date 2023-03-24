//
//  SingleAttachmentView.swift
//  Attachments
//
//  Created by Xu, Charles on 2/24/23.
//

import SwiftUI
import UniformTypeIdentifiers
import FioriSwiftUICore

struct SingleAttachmentView1: View {
    let dataModel: AttachmentDataModel<AttachmentImpl>
    let maxAttachmentNumber: Int?
    let readonly: Bool
    let showActionsAsContextMenu: Bool
    
    init(readonly: Bool = false, showActionsAsContextMenu: Bool = false) {
        self.dataModel = AttachmentDataModel<AttachmentImpl>(setup: { previewWorkingDirectoryUrl in
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
                Bundle.main.url(forResource: "Artist Daqian Zhang", withExtension: "jpeg"),
                Bundle.main.url(forResource: "San Ramon", withExtension: "png"),
                Bundle.main.url(forResource: "Word Sample 1", withExtension: "docx")
            ].compactMap{ $0 }.compactMap { makeAttachment(url: $0) }
        })

        self.maxAttachmentNumber = 5
        self.readonly = readonly
        self.showActionsAsContextMenu = showActionsAsContextMenu
    }

    var body: some View {
        VStack() {
            if readonly {
                cell.readonly()
            } else {
                cell
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    var cell: AttachmentsView<AttachmentImpl, AttachmentThumbnailView<AttachmentImpl>, AttachmentPreview<AttachmentImpl>> {
        AttachmentsView<AttachmentImpl, AttachmentThumbnailView<AttachmentImpl>, AttachmentPreview<AttachmentImpl>>(
            title: maxAttachmentNumber != nil ? "Attachments: %d of \(maxAttachmentNumber!), readonly: \(readonly)" : "Attachments: %d, readonly: \(readonly)",
            dataModel: dataModel
        )
        .actions(
            actions: [
                PhotoLibraryAction(label: "Select from Photos", onSaveImage: dataModel.makeFromImage),
                CameraAction(label: "Take a Photo", onSaveImage: dataModel.makeFromImage),
                DocumentAction(label: "Select from Files", allowedContentTypes: [.image, .svg, .pdf, .text, .swiftSource, UTType("org.openxmlformats.wordprocessingml.document")!, .presentation, .spreadsheet, .livePhoto, .movie], onSaveFile: dataModel.makeFromURL),
                ClosureAction(label: "Remove All") {
                    DispatchQueue.main.async {
                        self.dataModel.attachments.removeAll()
                    }
                }
            ], showActionsAsContextMenu: showActionsAsContextMenu)
        .maxAttachment(number: maxAttachmentNumber!)
    }
}

struct SingleAttachmentView2: View {
    let maxAttachmentNumber: Int? = 5
    let readonly = false

    let dataModel: AttachmentDataModel<AttachmentImpl>

    init() {
        dataModel = AttachmentDataModel(attachments: [
            Bundle.main.url(forResource: "PDF Sample 2", withExtension: "pdf")!.makeAttachment(),
            Bundle.main.url(forResource: "Hello World", withExtension: "txt")!.makeAttachment()
        ])
    }
    
    
    var body: some View {
        VStack {
            AttachmentsView<AttachmentImpl, AttachmentQuickLookThumbnailView<AttachmentImpl>, AttachmentPreview<AttachmentImpl>>(
                title: maxAttachmentNumber != nil ? "Attachments: %d of \(maxAttachmentNumber!), readonly: \(readonly)" : "Attachments: %d, readonly: \(readonly)",
                dataModel: dataModel,
                thumbnailContent: { attachment in return AttachmentQuickLookThumbnailView(attachment: attachment) }
            )
            .actions(
                actions: [
                    PhotoLibraryAction<AttachmentImpl>(label: "Select from Photos", onSaveImage: dataModel.makeFromImage),
                    CameraAction<AttachmentImpl>(label: "Take a Photo", onSaveImage: dataModel.makeFromImage),
                    DocumentAction<AttachmentImpl>(label: "Select from Files", allowedContentTypes: [.image, .svg, .pdf, .text, .swiftSource, UTType("org.openxmlformats.wordprocessingml.document")!, .presentation, .spreadsheet, .livePhoto, .movie], onSaveFile: dataModel.makeFromURL),
                    ClosureAction(label: "Remove All") {
                        DispatchQueue.main.async {
                            self.dataModel.attachments.removeAll()
                        }
                    },
                    ClosureAction(label: "Custom Action") { print("do something with imagination")}
                ]
            )
            .maxAttachment(number: maxAttachmentNumber!)
            
            Spacer()
        }
    }
}

struct SingleAttachmentView3: View {
    let maxAttachmentNumber: Int? = 5
    let readonly = false

    let dataModel: AttachmentDataModel<AttachmentImpl>

    init() {
        dataModel = AttachmentDataModel(attachments: [
            Bundle.main.url(forResource: "PDF Sample 1", withExtension: "pdf")!.makeAttachment(),
            Bundle.main.url(forResource: "Artist Daqian Zhang", withExtension: "jpeg")!.makeAttachment(),
            Bundle.main.url(forResource: "Hello World", withExtension: "txt")!.makeAttachment()
        ])
    }
    
    
    var body: some View {
        VStack {
            AttachmentsView<AttachmentImpl, AttachmentQuickLookThumbnailView<AttachmentImpl>, AttachmentReadonlyPreview<AttachmentImpl>>(
                title: maxAttachmentNumber != nil ? "Attachments: %d of \(maxAttachmentNumber!), readonly: \(readonly)" : "Attachments: %d, readonly: \(readonly)",
                dataModel: dataModel,
                thumbnailContent: { attachment in return AttachmentQuickLookThumbnailView(attachment: attachment) },
                previewContent: { return AttachmentReadonlyPreview<AttachmentImpl>() }
            )
            .actions(
                actions: [
                    PhotoLibraryAction<AttachmentImpl>(label: "Select from Photos", onSaveImage: dataModel.makeFromImage),
                    CameraAction<AttachmentImpl>(label: "Take a Photo", onSaveImage: dataModel.makeFromImage),
                    DocumentAction<AttachmentImpl>(label: "Select from Files", allowedContentTypes: [.image, .svg, .pdf, .text, .swiftSource, UTType("org.openxmlformats.wordprocessingml.document")!, .presentation, .spreadsheet, .livePhoto, .movie], onSaveFile: dataModel.makeFromURL),
                    ClosureAction(label: "Remove All") {
                        DispatchQueue.main.async {
                            self.dataModel.attachments.removeAll()
                        }
                    },
                    ClosureAction(label: "Custom Action") { print("do something with imagination")}
                ]
            )
            .maxAttachment(number: maxAttachmentNumber!)
            
            Spacer()
        }
    }
}

struct SingleAttachmentView4: View {
    let maxAttachmentNumber: Int? = 12
    let readonly = false

    let dataModel: AttachmentDataModel<AttachmentImpl>

    init() {
        dataModel = AttachmentDataModel(attachments: generateAttachments())
    }
    
    
    var body: some View {
        VStack {
            AttachmentsView<AttachmentImpl, AttachmentQuickLookThumbnailView<AttachmentImpl>, AttachmentPreview<AttachmentImpl>>(
                title: maxAttachmentNumber != nil ? "Attachments: %d of \(maxAttachmentNumber!), readonly: \(readonly)" : "Attachments: %d, readonly: \(readonly)",
                dataModel: dataModel,
                thumbnailContent: { attachment in return AttachmentQuickLookThumbnailView(attachment: attachment) }
            )
            .actions(
                actions: [
                    PhotoLibraryAction<AttachmentImpl>(label: "Select from Photos", onSaveImage: dataModel.makeFromImage),
                    CameraAction<AttachmentImpl>(label: "Take a Photo", onSaveImage: dataModel.makeFromImage),
                    DocumentAction<AttachmentImpl>(label: "Select from Files", allowedContentTypes: [.image, .svg, .pdf, .text, .swiftSource, UTType("org.openxmlformats.wordprocessingml.document")!, .presentation, .spreadsheet, .livePhoto, .movie], onSaveFile: dataModel.makeFromURL),
                    ClosureAction(label: "Remove All") {
                        DispatchQueue.main.async {
                            self.dataModel.attachments.removeAll()
                        }
                    },
                    ClosureAction(label: "Custom Action") { print("do something with imagination")}
                ]
            )
            .maxAttachment(number: maxAttachmentNumber!)
            
            Spacer()
        }
    }
}

struct SingleAttachmentView_Previews: PreviewProvider {
    static var previews: some View {
        SingleAttachmentView1(readonly: false, showActionsAsContextMenu: true)
        SingleAttachmentView1(readonly: false, showActionsAsContextMenu: false)
        SingleAttachmentView1(readonly: true, showActionsAsContextMenu: false)
        SingleAttachmentView2()
        SingleAttachmentView3()
        SingleAttachmentView4()
    }
}
