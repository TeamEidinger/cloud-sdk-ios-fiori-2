//
//  AttachmentContext.swift
//  Attachments
//
//  Created by Xu, Charles on 2/2/23.
//

import Foundation
import SwiftUI

class AttachmentContext: ObservableObject {
    @Published var isPreviewPresented = false
    @Published var previewAttachmentAtIndex = 0
    
    init() {
    }
    
    func presentPreview(ofAttachment atIndex: Int) {
        previewAttachmentAtIndex = atIndex
        isPreviewPresented.toggle()
    }
}
