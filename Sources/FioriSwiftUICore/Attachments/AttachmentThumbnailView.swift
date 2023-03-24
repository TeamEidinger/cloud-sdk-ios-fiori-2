//
//  AttachmentThumbnail.swift
//  Attachments
//
//  Created by Xu, Charles on 1/20/23.
//

import SwiftUI
import FioriThemeManager

public struct AttachmentThumbnailView<Attachment: AttachmentProcessing>: View {
    let attachment: Attachment
    @State private var image: Image?
    
    public init(attachment: Attachment) {
        self.attachment = attachment
    }
    
    public var body: some View {
        VStack{
            if let thumbnailUiImage = attachment.thumbnail {
                Image(uiImage: thumbnailUiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: AttachmentsViewConstants.thumbnaiWidth, height: AttachmentsViewConstants.thumbnaiHeight, alignment: .center)
                    .accessibilityLabel(NSLocalizedString("Attachment Thumbnail", tableName: "FioriSwiftUICore", bundle: Bundle.accessor, comment: ""))
            } else {
                if let image = image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: AttachmentsViewConstants.thumbnaiWidth, height: AttachmentsViewConstants.thumbnaiHeight, alignment: .center)
                        .background(
                            RoundedRectangle(cornerRadius: AttachmentsViewConstants.defaultCornerRadius)
                                .stroke(Color.preferredColor(.separator, background: .lightConstant), lineWidth: 1)
                        )
                        .clipped()
                        .cornerRadius(16)
                        .accessibilityLabel(NSLocalizedString("Attachment Thumbnail", tableName: "FioriSwiftUICore", bundle: Bundle.accessor, comment: ""))
                } else {
                    thumbnailImage()
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: AttachmentsViewConstants.thumbnailIconWidth, height: AttachmentsViewConstants.thumbnailIconHeight)
                        .frame(width: AttachmentsViewConstants.thumbnaiWidth, height: AttachmentsViewConstants.thumbnaiHeight)
                        .background(
                            RoundedRectangle(cornerRadius: AttachmentsViewConstants.defaultCornerRadius)
                                .stroke(Color.preferredColor(.separator, background: .lightConstant), lineWidth: 1)
                        )
                        .accessibilityLabel(NSLocalizedString("Attachment Thumbnail", tableName: "FioriSwiftUICore", bundle: Bundle.accessor, comment: ""))
                        .onAppear {
                            generateThumbnail()
                        }
                }
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
}

extension AttachmentThumbnailView {
    fileprivate func thumbnailImage() -> Image {
        let placeholder = Image(systemName: "doc")
        guard let url = attachment.physicalUrl else { return placeholder }
        let lowerFileExtension = url.pathExtension.lowercased()
        switch lowerFileExtension {
            // Audio files defined in https://en.wikipedia.org/wiki/Audio_file_format
        case "aa", "aac", "aax", "act", "aiff", "amr", "ape", "au", "awb", "dct", "dss", "dvf", "flac", "gsm", "iklax", "ivs", "m4a", "m4b", "mmf", "mp3", "mpc", "msv", "nsf", "oga", "mogg", "opus", "ra", "raw", "sln", "tta", "vox", "wav", "wma", "wv", "8svx":
            return Image(systemName: "waveform")
            
        case "csv":
            return Image(systemName: "doc.text")
            
            // Major image file extensions defined in https://en.wikipedia.org/wiki/Image_file_formats
        case "jpg", "jpeg", "jfif", "jpeg 2000", "exif", "tiff", "gif", "bmp", "png", "ppm", "pgm", "pbm", "pnm", "webp", "hdr", "heif", "bat", "bpg":
            return Image(systemName: "photo")
                .data(url: url)
            
        case "pdf":
            return Image(systemName: "doc.richtext.fill")
            
        case "ppt", "pptx", "pptm", "key":
            return Image(systemName: "doc.richtext")
            
        case "xls", "xlsx", "xlsm", "xltx", "xltm":
            return Image(systemName: "doc.richtext")
            
        case "txt", "rtf":
            return Image(systemName: "doc.text")
            
            // Video file extensions from https://en.wikipedia.org/wiki/Video_file_format
        case "webm", "mkv", "flv", "vob", "ogv", "ogg", "drc", "gifv", "mng", "avi", "mov", "qt", "wmv", "yuv", "rm", "rmvb", "asf", "amv", "mp4", "m4p", "m4v", "mpg", "mp2", "mpeg", "mpe", "mpv", "m2v", "svi", "3gp", "3g2", "mxf", "roq", "nsv", "f4v", "f4p", "f4a", "f4b":
            return Image(systemName: "video")
            
        default:
            return placeholder
        }
    }
    
    fileprivate func generateThumbnail() {
        guard let url = attachment.physicalUrl else { return }
        let fileExt = url.pathExtension
        guard ["jpg", "jpeg", "jfif", "jpeg 2000", "exif", "tiff", "gif", "bmp", "png", "ppm", "pgm", "pbm", "pnm", "webp", "hdr", "heif", "bat", "bpg"].contains(fileExt.lowercased()) else { return }
        
        if let data = try? Data(contentsOf: url) {
            if let uiImage = UIImage(data: data) {
                self.image = Image(uiImage: uiImage)
            }
        }
    }
}

extension Image {
    func data(url: URL) -> Self {
        if let data = try? Data(contentsOf: url) {
            return Image(uiImage: UIImage(data: data)!)
        }
        return self
    }
}

#if DEBUG

struct TestAttachmentThumbnail<Attachment: AttachmentProcessing>: View {
    @EnvironmentObject var dataModel: AttachmentDataModel<Attachment>
    @EnvironmentObject var context: AttachmentContext
    
    init() {
    }
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.adaptive(minimum: AttachmentsViewConstants.thumbnaiWidth), alignment: .top), count: 1), spacing: AttachmentsViewConstants.spaceBetweenTitleAndThumbnails) {
            Group {
                ForEach(0..<dataModel.attachments.count, id: \.self) { index in
                    AttachmentThumbnailView<Attachment>(attachment: dataModel.attachments[index])
                }
            }
        }
    }
}

struct AttachmentThumbnail_Previews: PreviewProvider {
    static let model = PreviewModel.model
    
    static var previews: some View {
        VStack {
            Text("Thumbnail + Title + SubTitle")
            TestAttachmentThumbnail<AttachmentImpl>()
                .environmentObject(model.defaultPreviewAttachmentModel)
                .environmentObject(model.defaultPreviewAttachmentContext)
        }
        VStack {
            Text("No Title with SubTitle")
            TestAttachmentThumbnail<AttachmentImpl>()
                .environmentObject(model.defaultPreviewAttachmentModelWithoutTitle)
                .environmentObject(model.defaultPreviewAttachmentContext)
        }
        VStack {
            Text("No Title and No SubTitle")
            TestAttachmentThumbnail<AttachmentImpl>()
                .environmentObject(model.defaultPreviewAttachmentModelWithoutTitleAndSubtitle)
                .environmentObject(model.defaultPreviewAttachmentContext)
        }
        VStack {
            Text("Custom Thumbnail")
            TestAttachmentThumbnail<AttachmentImpl>()
                .environmentObject(model.defaultPreviewAttachmentModeltWithThumbnail)
                .environmentObject(model.defaultPreviewAttachmentContext)
        }
        VStack {
            Text("No Thumbnail and No Physical URL")
            TestAttachmentThumbnail<AttachmentImpl>()
                .environmentObject(model.defaultPreviewAttachmentModelWithoutThumbnailAndPhysicalUrl)
                .environmentObject(model.defaultPreviewAttachmentContext)
        }
    }
}

#endif
