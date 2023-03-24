//
//  AttachmentActionContext.swift
//  Attachments
//
//  Created by Xu, Charles on 2/17/23.
//
import SwiftUI
import UniformTypeIdentifiers

class AttachmentActionContext<Attachment: AttachmentProcessing>: ObservableObject {
    @Published var dialogView: AnyView?
    @Published var isDialogViewPresented = false
    @Published var isFileImporterPresented = false
    @Published var allowedContentTypes: [UTType] = []
    @Published var onSaveFile: ((URL) -> Attachment?)?
}
