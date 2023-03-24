//
//  ActionIdentifiable.swift
//  Attachments
//
//  Created by Xu, Charles on 3/2/23.
//
import SwiftUI

public class BaseAction<Attachment: AttachmentProcessing>: Identifiable {
    public let id: UUID
    public let label: String
    
    public init(label: String) {
        self.id = UUID()
        self.label = label
    }
    
    func asButton(ctx: AttachmentActionContext<Attachment>) -> Button<Text> {
        fatalError("Please extend this class.")
    }
}
