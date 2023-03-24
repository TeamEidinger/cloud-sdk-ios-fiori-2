//
//  File.swift
//  
//
//  Created by Xu, Charles on 3/16/23.
//

import Foundation

#if DEBUG

public class AttachmentGenerator: Identifiable {
    let name: String
    let path: URL
    
    init(name: String, path: URL) {
        self.name = name
        self.path = path
    }
    
    public var url: URL? {
        fatalError("Please subclass AttachmentGenerator.")
    }
}

#endif
