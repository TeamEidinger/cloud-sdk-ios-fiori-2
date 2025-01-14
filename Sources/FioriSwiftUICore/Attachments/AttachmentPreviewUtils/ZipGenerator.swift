//
//  ZipGenerator.swift
//  
//
//  Created by Xu, Charles on 3/16/23.
//

import Foundation

#if DEBUG

public class ZipGenerator: AttachmentGenerator {
    
    override public var url: URL? {
        if let data = Data(base64Encoded: "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", options: .ignoreUnknownCharacters) {

//            let filePath = String(format: "%@/%@", tempDirPath, name)
//            let fileURL = URL(fileURLWithPath: filePath)
            let fileURL = URL(fileURLWithPath: name, relativeTo: path)

            do {
                try data.write(to: fileURL)
                return fileURL
            } catch {
                print("Error while writing: " + error.localizedDescription)
            }
        }
        return nil
    }
}

#endif
