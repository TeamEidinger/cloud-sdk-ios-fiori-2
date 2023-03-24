//
//  ImagePicker.swift
//  Attachments
//
//  Created by Xu, Charles on 1/12/23.
//

import PhotosUI
import SwiftUI

struct ImagePicker<Attachment: AttachmentProcessing>: UIViewControllerRepresentable {
    @EnvironmentObject var dataModel: AttachmentDataModel<Attachment>
    @EnvironmentObject var attachmentContext: AttachmentContext
    let onSaveImage: (UIImage) -> Attachment?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider else { return }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    if let uiImage = image as? UIImage {
                        if let attachment = self.parent.onSaveImage(uiImage) {
                            DispatchQueue.main.async {
                                self.parent.dataModel.attachments.append(attachment)
                            }
                        }
                    }
                }
            }
        }
    }
}
