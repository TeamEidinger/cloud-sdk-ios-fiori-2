//
//  DocumentAction.swift
//  Attachments
//
//  Created by Xu, Charles on 2/17/23.
//

import SwiftUI
import UniformTypeIdentifiers

public class DocumentAction<Attachment: AttachmentProcessing>: BaseAction<Attachment> {
    let allowedContentTypes: [UTType]
//    var onCompletion: (_ result: Result<URL, Error>) -> Void
    let onSaveFile: (URL) -> Attachment?
    
    public init(label: String, allowedContentTypes: [UTType], onSaveFile: @escaping (URL) -> Attachment?) {
        self.allowedContentTypes = allowedContentTypes
        self.onSaveFile = onSaveFile
        super.init(label: label)
    }
    
    override func asButton(ctx: AttachmentActionContext<Attachment>) -> Button<Text> {
        Button(label) {
            ctx.allowedContentTypes = self.allowedContentTypes
            ctx.isFileImporterPresented.toggle()
        }
    }
}
