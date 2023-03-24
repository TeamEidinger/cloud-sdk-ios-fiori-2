//
//  URL+Extensions.swift
//  Attachments
//
//  Created by Xu, Charles on 1/26/23.
//
import Foundation
import FioriSwiftUICore

extension URL {
    public func makeAttachment() -> AttachmentImpl {
        var sizeDate: (String?, String?) {
            do {
                let resource =  try self.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey])
                let fileSize = resource.fileSize!
                let date = resource.contentModificationDate
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM dd,yyyy"
                return (ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file), date != nil ? dateFormatter.string(from: date!) : nil)
            } catch {
                print(error)
                return (nil, nil)
            }
        }
        
        return AttachmentImpl(logicalUrl: self.absoluteString, title: self.lastPathComponent, subtitle: sizeDate.0, moreInfo: sizeDate.1, thumbnail: nil, physicalUrl: self)
    }
}
