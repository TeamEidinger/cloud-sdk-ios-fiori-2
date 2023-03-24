//
//  AttachmentActionConfiguration.swift
//  Attachments
//
//  Created by Xu, Charles on 2/17/23.
//

import SwiftUI

class AttachmentConfiguration<Attachment: AttachmentProcessing>: ObservableObject {
    @Published var readonly: Bool
    @Published var maxNumberOfAttachments: Int?
    var actions: [BaseAction<Attachment>]
//    var attachmentFacotry: any AttachmentFactoryProtocol = DefaultAttachmentFactory()
    var showActionsAsContextMenu: Bool
    
    init(readonly: Bool = false, maxNumberOfAttachments: Int? = nil, actions: [BaseAction<Attachment>] = []) {
        self.readonly = readonly
        self.maxNumberOfAttachments = maxNumberOfAttachments
        self.actions = actions
        self.showActionsAsContextMenu = false
    }
}
