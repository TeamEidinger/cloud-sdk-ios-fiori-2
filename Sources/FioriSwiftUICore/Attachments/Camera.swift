//
//  Camera.swift
//  Attachments
//
//  Created by Xu, Charles on 1/17/23.
//

import Photos
import PhotosUI
import SwiftUI

struct Camera<Attachment: AttachmentProcessing>: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var dataModel: AttachmentDataModel<Attachment>
    @EnvironmentObject var attachmentContext: AttachmentContext
    var onSaveImage: (UIImage) -> Attachment?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let camera = UIImagePickerController()
        camera.sourceType = .camera
        camera.allowsEditing = false
        camera.delegate = context.coordinator
        return camera
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: Camera
        
        init(_ parent: Camera) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//            if (info[.mediaType] as? String) == (kUTTypeMovie as String) {
//                // user took a video
//                if let mediaURL = info[.mediaURL] as? URL {
//                    if self.action.isSavedToCameraRoll {
//                        PHAsset.saveVideoFileToTmpDir(mediaURL, completionHandler: { [weak self] (asset, success) in
//                            guard let strongSelf = self else { return }
//                            if success {
//                                guard let a = asset else {
//                                    return
//                                }
//                                let newURLString = "assets-library://asset/asset.MOV?id=\(a.localIdentifier)&ext=MOV"
//                                    // use file url and asset
//                                guard let url = URL(string: newURLString) else {
//                                    return
//                                }
//                                strongSelf.action.delegate?.takePhotoAttachmentAction(strongSelf.action, didTakePhoto: a, at: url)
//                            } else {
//                                // PHAsset is not available. Use the url directly
//                                strongSelf.action.delegate?.takePhotoAttachmentAction(strongSelf.action, didTakeVideo: mediaURL)
//                            }
//                        })
//                    } else {
//                        // Developer wants the video directly
//                        self.action.delegate?.takePhotoAttachmentAction(self.action, didTakeVideo: mediaURL)
//                    }
//                }
//            } else
            if let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                if let attachment = self.parent.onSaveImage(uiImage) {
                    DispatchQueue.main.async {
                        self.parent.dataModel.attachments.append(attachment)
                    }
                }
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
