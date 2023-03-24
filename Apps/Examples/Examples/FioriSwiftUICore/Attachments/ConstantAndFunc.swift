//
//  ConstantsAndFunc.swift
//  Examples
//
//  Created by Xu, Charles on 3/23/23.
//  Copyright © 2023 SAP. All rights reserved.
//

import Foundation
import FioriSwiftUICore

let numberOfItems = 6

func generateAttachments() -> [AttachmentImpl] {
   return [
        Bundle.main.url(forResource: "Rainbow Dublin", withExtension: "jpg")!.makeAttachment(),
        Bundle.main.url(forResource: "Artist Daqian Zhang", withExtension: "jpeg")!.makeAttachment(),
        Bundle.main.url(forResource: "San Ramon", withExtension: "png")!.makeAttachment(),
        Bundle.main.url(forResource: "President Donald Trump", withExtension: "svg")!.makeAttachment(),
        Bundle.main.url(forResource: "PDF Sample 1", withExtension: "pdf")!.makeAttachment(),
        Bundle.main.url(forResource: "MD Sample", withExtension: "md")!.makeAttachment(),
        Bundle.main.url(forResource: "PDF Sample 2", withExtension: "pdf")!.makeAttachment(),
        Bundle.main.url(forResource: "Hello World", withExtension: "txt")!.makeAttachment(),
        Bundle.main.url(forResource: "Zip Sample", withExtension: "zip")!.makeAttachment(),
        Bundle.main.url(forResource: "HTML Sample", withExtension: "html")!.makeAttachment()
    ].shuffled()
}

func generateDataModels() -> [AttachmentDataModel<AttachmentImpl>] {
    let bundledAttachments = generateAttachments()
    var dataModels = [AttachmentDataModel<AttachmentImpl>]()
    for i in 0...numberOfItems {
        dataModels.append(AttachmentDataModel<AttachmentImpl>(attachments: bundledAttachments.choose(i)))
    }
    return dataModels
}

let dataModels: [AttachmentDataModel<AttachmentImpl>] = generateDataModels()
