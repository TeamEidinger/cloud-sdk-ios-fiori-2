//
//  ClosureAction.swift
//  Attachments
//
//  Created by Xu, Charles on 3/2/23.
//

import SwiftUI

public class ClosureAction<Attachment: AttachmentProcessing>: BaseAction<Attachment> {
    let closure: () -> Void

    public init(label: String, closure: @escaping () -> Void = {}) {
        self.closure = closure
        super.init(label: label)
    }
    
    override func asButton(ctx: AttachmentActionContext<Attachment>) -> Button<Text> {
        Button(label, action: closure)
    }
}
