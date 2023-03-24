//
//  AttachmentQuickLookThumbnailView.swift
//  Attachments
//
//  Created by Xu, Charles on 2/21/23.
//

import SwiftUI
import QuickLook
import FioriThemeManager

public struct AttachmentQuickLookThumbnailView<Attachment: AttachmentProcessing>: View {
    let attachment: Attachment
    @State var image: Image
    
    public init(attachment: Attachment, image: Image = Image(systemName: "doc")) {
        self.attachment = attachment
        self.image = image
    }
    
    public var body: some View {
        VStack{
            image
                .font(.largeTitle)
                .frame(width: AttachmentsViewConstants.thumbnaiWidth, height: AttachmentsViewConstants.thumbnaiHeight)
                .accessibilityLabel(NSLocalizedString("Attachment Thumbnail", tableName: "FioriSwiftUICore", bundle: Bundle.accessor, comment: ""))
                .onAppear {
                    generateThumbnail()
                }
            
            VStack(alignment: .leading) {
                if let title = attachment.title {
                    Text(title)
                        .font(.fiori(forTextStyle: .caption2).weight(.bold))
                        .foregroundColor(Color.preferredColor(.primaryLabel, background: .lightConstant))
                        .lineLimit(2)
                        .truncationMode(.middle)
                }
                
                if let subtitle = attachment.subtitle {
                    Text(subtitle)
                        .font(.fiori(forTextStyle: .caption2))
                        .foregroundColor(Color.preferredColor(.tertiaryLabel, background: .lightConstant))
                        .truncationMode(.middle)
                }
                
                if let moreInfo = attachment.moreInfo {
                    Text(moreInfo)
                        .font(.fiori(forTextStyle: .caption2))
                        .foregroundColor(Color.preferredColor(.tertiaryLabel, background: .lightConstant))
                        .truncationMode(.middle)
                }
            }
            .frame(width: AttachmentsViewConstants.thumbnaiWidth, alignment: .leading)
        }
        .accessibilityElement(children: .contain)
    }
    
    fileprivate func generateThumbnail() {
        let size = CGSize(width: AttachmentsViewConstants.thumbnaiWidth, height: AttachmentsViewConstants.thumbnaiHeight)
        let scale = UIScreen.main.scale
        guard let url = attachment.physicalUrl else { return }
        
        let request = QLThumbnailGenerator.Request(
            fileAt: url,
            size: size,
            scale: scale,
            representationTypes: .all
        )
        
        let generator = QLThumbnailGenerator.shared
        generator.generateBestRepresentation(for: request) { thumbnail, error in
            DispatchQueue.main.async {
                if let thumbnail = thumbnail {
                    self.image = Image(uiImage: thumbnail.uiImage)
                } else if let error = error {
                    print(error)
                }
            }
        }
    }
}

#if DEBUG
struct TestAttachmentQuickLookThumbnailView<Attachment: AttachmentProcessing>: View {
    @EnvironmentObject var dataModel: AttachmentDataModel<Attachment>
    @EnvironmentObject var context: AttachmentContext
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.adaptive(minimum: AttachmentsViewConstants.thumbnaiWidth), alignment: .top), count: 1), spacing: 8) {
            Group {
                ForEach(0..<dataModel.attachments.count, id: \.self) { index in
                    AttachmentQuickLookThumbnailView(attachment: dataModel.attachments[index])
                }
            }
        }
    }
}

struct AttachmentQuickLookThumbnailView_Previews: PreviewProvider {
    static let model = PreviewModel.model
    
    static var previews: some View {
        TestAttachmentQuickLookThumbnailView<AttachmentImpl>()
            .environmentObject(model.defaultPreviewAttachmentModel)
            .environmentObject(model.defaultPreviewAttachmentContext)
    }
}
#endif
