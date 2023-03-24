//
//  File.swift
//  
//
//  Created by Xu, Charles on 3/16/23.
//

import Foundation
import UIKit

#if DEBUG

public class PDFGenerator: AttachmentGenerator {
    let content: String
    
    public init(name: String, path: URL, content: String) {
        self.content = content
        super.init(name: name, path: path)
    }
    
    override public var url: URL? {
        let fmt = UIMarkupTextPrintFormatter(markupText: content)
                
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(fmt, startingAtPageAt: 0)
                
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4, 72 dpi
        let printable = page.insetBy(dx: 0, dy: 0)
        
        render.setValue(NSValue(cgRect: page), forKey: "paperRect")
        render.setValue(NSValue(cgRect: printable), forKey: "printableRect")
        
        
        let data = NSMutableData()
        UIGraphicsBeginPDFContextToData(data, .zero, nil)
        
        for i in 1...render.numberOfPages {
            UIGraphicsBeginPDFPage();
            let bounds = UIGraphicsGetPDFContextBounds()
            render.drawPage(at: i - 1, in: bounds)
        }
        
        UIGraphicsEndPDFContext();
        
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
