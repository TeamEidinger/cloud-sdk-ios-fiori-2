//
//  CameraAction.swift
//  Attachments
//
//  Created by Xu, Charles on 2/17/23.
//

import SwiftUI

public class CameraAction<Attachment: AttachmentProcessing>: BaseAction<Attachment> {
    let onSaveImage: (UIImage) -> Attachment?
    
    public init(label: String, onSaveImage: @escaping (UIImage) -> Attachment?) {
        self.onSaveImage = onSaveImage
        super.init(label: label)
    }
    
    override func asButton(ctx: AttachmentActionContext<Attachment>) -> Button<Text> {
        Button(self.label) {
            ctx.dialogView = AnyView(Camera<Attachment>(onSaveImage: self.onSaveImage))
            ctx.isDialogViewPresented.toggle()
        }
    }
}
