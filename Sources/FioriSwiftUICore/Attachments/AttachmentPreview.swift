//
//  AttachmentPreview.swift
//  Attachments
//
//  Created by Xu, Charles on 1/23/23.
//

import QuickLook
import SwiftUI

public struct AttachmentPreview<Attachment: AttachmentProcessing>: UIViewControllerRepresentable {
    @EnvironmentObject var dataModel: AttachmentDataModel<Attachment>
    @EnvironmentObject var attachmentContext: AttachmentContext
    @EnvironmentObject var configuration: AttachmentConfiguration<Attachment>
    
    public func makeUIViewController(context: Context) -> UINavigationController {
        let controller = QLPreviewController()

        let coordinator = context.coordinator
        controller.dataSource = coordinator
        
        controller.navigationItem.rightBarButtonItems = configuration.readonly ? [
            UIBarButtonItem(barButtonSystemItem: .done, target: context.coordinator, action: #selector(coordinator.dismiss))
        ] : [
            UIBarButtonItem(barButtonSystemItem: .done, target: context.coordinator, action: #selector(coordinator.dismiss)),
            UIBarButtonItem(barButtonSystemItem: .trash, target: context.coordinator, action: #selector(coordinator.delete(sender:)))
        ]
        context.coordinator.viewController = controller

        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.delegate = coordinator
        
        controller.currentPreviewItemIndex = attachmentContext.previewAttachmentAtIndex

        return navigationController
    }

    public func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    public class Coordinator: NSObject, QLPreviewControllerDataSource, UINavigationControllerDelegate {
        weak var viewController: QLPreviewController?
        let parent: AttachmentPreview

        init(_ parent: AttachmentPreview) {
            self.parent = parent
        }

        public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return self.parent.dataModel.attachments.count
        }
        
        public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return self.parent.dataModel.attachments[index]
        }
                
        @objc func dismiss() {
            parent.attachmentContext.isPreviewPresented.toggle()
        }
        
        @objc func delete(sender: Any) {
            DispatchQueue.main.async {
                let index = self.parent.attachmentContext.previewAttachmentAtIndex
                self.parent.attachmentContext.previewAttachmentAtIndex = index > 0 ? index - 1 : 0
                self.parent.dataModel.attachments.remove(at: index)
                self.viewController?.reloadData()
            }
        }
    }
}

#if DEBUG

struct TestAttachmentPreview: View {
    @EnvironmentObject var model: AttachmentDataModel<AttachmentImpl>
    @EnvironmentObject var context: AttachmentContext
    
    var body: some View {
        VStack {
            Button("Preview Image") {
                context.presentPreview(ofAttachment: 0)
            }
            Button("Preview PDF") {
                context.presentPreview(ofAttachment: 1)
            }
        }
        .fullScreenCover(isPresented: $context.isPreviewPresented) {
            AttachmentPreview<AttachmentImpl>()
        }
    }
}

extension QLPreviewController {
    class func canPreview(_ item: QLPreviewItem) -> Bool {
        return false
    }
}

struct TestAttachmentPreview_Previews: PreviewProvider {
    static let model = PreviewModel.model
    
    static var previews: some View {
        TestAttachmentPreview()
            .environmentObject(AttachmentDataModel(attachments: [
                model.defaultPreviewAttachments[4],
                model.defaultPreviewAttachments[0],
                model.defaultPreviewAttachments[1]
            ]))
            .environmentObject(AttachmentContext())
            .environmentObject(AttachmentConfiguration<AttachmentImpl>())

        TestAttachmentPreview()
            .environmentObject(AttachmentDataModel(attachments: [
                model.defaultPreviewAttachments[4],
                AttachmentImpl(logicalUrl: "https://localhost/docs/mydoc.pdf", title: "My Doc", subtitle: "100KB", thumbnail: nil, physicalUrl: nil),
                AttachmentImpl(logicalUrl: "https://localhost/docs/mydoc.pdf", title: "My Doc", subtitle: "100KB", thumbnail: nil, physicalUrl: model.defaultPreviewAttachments[4].physicalUrl)
            ]))
            .environmentObject(AttachmentContext())
            .environmentObject(AttachmentConfiguration<AttachmentImpl>(readonly: true))
    }
}

#endif
