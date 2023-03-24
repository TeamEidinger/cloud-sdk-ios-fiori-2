//
//  TextGenerator.swift
//  
//
//  Created by Xu, Charles on 3/16/23.
//

import Foundation

#if DEBUG

public class TextGenerator: AttachmentGenerator {
    let content: String
    
    public init(name: String, path: URL, content: String) {
        self.content = content
        super.init(name: name, path: path)
    }
    
    override public var url: URL? {
        let data = Data(content.utf8)
        let fileURL = URL(fileURLWithPath: name, relativeTo: path)

        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error while writing: " + error.localizedDescription)
        }
        return fileURL
    }
}

#endif
