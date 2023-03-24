//
//  AttachmentButtonView.swift
//  Attachments
//
//  Created by Xu, Charles on 2/3/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct AttachmentButtonView<Attachment: AttachmentProcessing, AlternativeThumbnailView: View>: View {
    @EnvironmentObject var dataModel: AttachmentDataModel<Attachment> // share data
    @EnvironmentObject var attachmentContext: AttachmentContext // share data
    @EnvironmentObject var configuration: AttachmentConfiguration<Attachment> // configure action list
    @EnvironmentObject var actionContext: AttachmentActionContext<Attachment> // button -> view interaction
    
    @State var isActionSheetPresented = false
    
    var body: some View {
        operationButton
            .accessibilityElement(children: .combine)
            .accessibilityLabel(NSLocalizedString("Add Attachment", tableName: "FioriSwiftUICore", bundle: Bundle.accessor, comment: ""))
            .accessibilityAddTraits(.isButton)
            .confirmationDialog("", isPresented: $isActionSheetPresented) {
                ForEach(0..<configuration.actions.count, id: \.self) { index in
                    configuration.actions[index].asButton(ctx: actionContext)
                }
            }
            .fullScreenCover(isPresented: $actionContext.isDialogViewPresented) {
                if let dialog = actionContext.dialogView {
                    dialog
                }
            }
            .fileImporter(isPresented: $actionContext.isFileImporterPresented, allowedContentTypes: actionContext.allowedContentTypes) { result in
                if case .success = result {
                    do {
                        let docURL: URL = try result.get()
                        defer {
                            docURL.stopAccessingSecurityScopedResource()
                        }
                        if docURL.startAccessingSecurityScopedResource() {
                            if let attachment = dataModel.makeFromURL(docURL) {
                                DispatchQueue.main.async {
                                    dataModel.attachments.append(attachment)
                                }
                            }
                        }
                    } catch {
                        let nsError = error as NSError
                        fatalError("File Import Error \(nsError), \(nsError.userInfo)")
                    }
                } else {
                    print("File Import Failed")
                }
            }
    }
    
    @ViewBuilder
    var operationButton: some View {
        if configuration.showActionsAsContextMenu {
            RoundedRectangle(cornerRadius: AttachmentsViewConstants.defaultCornerRadius)
                .stroke(Color.preferredColor(.separator, background: .lightConstant), style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round, dash: [7]))
                .overlay(Image(systemName: "plus").font(.system(size: 28)).foregroundColor(Color.preferredColor(.tintColor, background: .lightConstant)))
                .frame(width: AttachmentsViewConstants.thumbnaiWidth, height: AttachmentsViewConstants.thumbnaiHeight)
                .contentShape(Rectangle())
                .contextMenu {
                    ForEach(0..<configuration.actions.count, id: \.self) { index in
                        configuration.actions[index].asButton(ctx: actionContext)
                    }
                }

        } else {
            RoundedRectangle(cornerRadius: AttachmentsViewConstants.defaultCornerRadius)
                .stroke(Color.preferredColor(.separator, background: .lightConstant), style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round, dash: [7]))
                .overlay(Image(systemName: "plus").font(.system(size: 28)).foregroundColor(Color.preferredColor(.tintColor, background: .lightConstant)))
                .frame(width: AttachmentsViewConstants.thumbnaiWidth, height: AttachmentsViewConstants.thumbnaiHeight)
                .contentShape(Rectangle())
                .onTapGesture {
                    isActionSheetPresented.toggle()
                }
        }
    }
}

#if DEBUG

struct TestAttachmentButtonView: View {
    @StateObject var model = PreviewModel.model
    @StateObject var cfg = AttachmentConfiguration<AttachmentImpl>()
    
    var body: some View {
        VStack {
            Spacer()
            AttachmentButtonView<AttachmentImpl, AttachmentThumbnailView<AttachmentImpl>>()
                .environmentObject(model)
                .environmentObject(AttachmentContext())
                .environmentObject(cfg)
                .environmentObject(AttachmentActionContext<AttachmentImpl>())
            
            Spacer()
            Button("Pre-Configured Actions") {
                cfg.actions = model.defaultPreviewAllActions
                cfg.showActionsAsContextMenu = true
            }
            
            Button("Photos and Files") {
                cfg.actions = [
                    model.defaultPreviewPhotoAction,
                    model.defaultPreviewDocumentAction
                ]
                cfg.showActionsAsContextMenu = true
            }

            Button("Photos and Closure Action") {
                cfg.actions = [
                    model.defaultPreviewPhotoAction,
                    model.defaultPreviewClosureAction
                ]
                cfg.showActionsAsContextMenu = false
            }
        }
    }
}

struct AttachmentButtonView_Previews: PreviewProvider {
    static var previews: some View {
        TestAttachmentButtonView()
    }
}

#endif
