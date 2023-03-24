//
//  AttachmentsView.swift
//  Attachments
//
//  Created by Xu, Charles on 1/6/23.
//

import SwiftUI
import PhotosUI

public struct AttachmentsView<Attachment: AttachmentProcessing, ThumbnailView: View, PreviewView: View>: View {
    @State var title: String?
    @ObservedObject var dataModel: AttachmentDataModel<Attachment>
    @ObservedObject var configuration = AttachmentConfiguration<Attachment>()
    @StateObject var context: AttachmentContext = AttachmentContext()
    var thumbnailContent: ((Attachment) -> ThumbnailView)
    var previewContent: (() -> PreviewView)

    
    public init(title: String? = nil,
         dataModel: AttachmentDataModel<Attachment>,
         thumbnailContent: ((Attachment) -> ThumbnailView)? = nil,
         previewContent: (() -> PreviewView)? = nil) {
        self.title = title
        self.dataModel = dataModel
        self.thumbnailContent = thumbnailContent ?? { attachment in return AttachmentThumbnailView<Attachment>(attachment: attachment) as! ThumbnailView }
        self.previewContent = previewContent ?? { return AttachmentPreview<Attachment>() as! PreviewView }

    }
    
    public var body: some View {
        VStack(spacing: AttachmentsViewConstants.spaceBetweenTitleAndThumbnails) {
            if let title = title {
                HStack {
                    Text(String(format: title, $dataModel.attachments.count))
                    Spacer()
                }
                .font(.fiori(forTextStyle: .subheadline).weight(.bold))
                .foregroundColor(Color.preferredColor(.primaryLabel, background: .lightConstant))
                .padding(.leading, 10)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.adaptive(minimum: AttachmentsViewConstants.thumbnaiWidth), alignment: .top), count: 1), spacing: AttachmentsViewConstants.thumbnailSpace) {
                // attachment operation button
                if !configuration.readonly && configuration.maxNumberOfAttachments ?? Int.max > dataModel.attachments.count {
                    AttachmentButtonView<Attachment, ThumbnailView>()
                        .environmentObject(AttachmentActionContext<Attachment>())
                }
                
                // attachment thumbnail group
                Group {
                    ForEach(0 ..< $dataModel.attachments.count, id: \.self) { index in
                        thumbnailContent(dataModel.attachments[index])
                            .onTapGesture {
                                withAnimation {
                                    context.presentPreview(ofAttachment: index)
                                }
                            }
                    }
                }
                .fullScreenCover(isPresented: $context.isPreviewPresented) {
                    previewContent()
                        .ignoresSafeArea()
                }
            }
            .environmentObject(dataModel)
            .environmentObject(configuration)
            .environmentObject(context)
        }
        .padding()
    }
    
    public func title(title: String) -> Self {
        self.title = title
        return self
    }
    
    public func actions(actions: [BaseAction<Attachment>], showActionsAsContextMenu: Bool = false) -> Self {
        configuration.actions = actions
        configuration.showActionsAsContextMenu = showActionsAsContextMenu
        return self
    }
    
    public func readonly()  -> Self {
        configuration.readonly = true
        return self
    }
    
    public func edittable()  -> Self {
        configuration.readonly = false
        return self
    }
    
    public func maxAttachment(number: Int)  -> Self {
        configuration.maxNumberOfAttachments = number
        return self
    }
}

#if DEBUG

struct TestAttachmentsView: View {
    let ctx: AttachmentContext
    let cfg: AttachmentConfiguration<AttachmentImpl>
    let dataModel: PreviewModel
    
    init() {
        ctx = AttachmentContext()
        cfg = AttachmentConfiguration<AttachmentImpl>(
            maxNumberOfAttachments: 5
        )
        dataModel = PreviewModel.model
    }
    
    
    var title: String {
        "Attachments (%d of \(cfg.maxNumberOfAttachments!))"
    }
    
    var body: some View {
        VStack {
            AttachmentsView<AttachmentImpl, AttachmentThumbnailView<AttachmentImpl>, AttachmentPreview<AttachmentImpl>>(
                title: title,
                dataModel: dataModel
//                thumbnailContent: { attachment in return AttachmentQuickLookThumbnailView(attachment: attachment) },
            )
            .actions(actions: dataModel.defaultPreviewAllActions, showActionsAsContextMenu: false)
            .maxAttachment(number: 5)
            Spacer()
        }
    }
}


struct AttachmentsView_Previews: PreviewProvider {
    static var previews: some View {
        TestAttachmentsView()
    }
}

#endif
