//
//  ViewControllerView.swift
//  Attachments
//
//  Created by Xu, Charles on 3/6/23.
//

import SwiftUI
import UniformTypeIdentifiers
import Combine
import FioriSwiftUICore


class AttachmentViewCell: UICollectionViewCell {
    private var cancellable: AnyCancellable!

    var dataModel: AttachmentDataModel<AttachmentImpl> = AttachmentDataModel(attachments: [
        Bundle.main.url(forResource: "PDF Sample 1", withExtension: "pdf")!.makeAttachment(),
        Bundle.main.url(forResource: "Hello World", withExtension: "txt")!.makeAttachment()
    ])

    var attachmentsView: AttachmentsView<AttachmentImpl, AttachmentThumbnailView<AttachmentImpl>, AttachmentPreview<AttachmentImpl>>?

    var hostController: UIHostingController<AttachmentsView<AttachmentImpl, AttachmentThumbnailView<AttachmentImpl>, AttachmentPreview<AttachmentImpl>>>?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        attachmentsView = AttachmentsView<AttachmentImpl, AttachmentThumbnailView<AttachmentImpl>, AttachmentPreview<AttachmentImpl>>(
            title: "Attachments",
            dataModel: dataModel
        )

        hostController = UIHostingController(rootView: attachmentsView!)
        contentView.addSubview(hostController!.view)

        hostController?.view.translatesAutoresizingMaskIntoConstraints = false
        hostController?.view.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor).isActive = true
        hostController?.view.leftAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leftAnchor).isActive = true
        hostController?.view.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor).isActive = true

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func readonly() {
        _ = attachmentsView?.readonly()
    }
    
    func maxAttachment(number: Int) {
        _ = attachmentsView?.maxAttachment(number: number)
    }
    
    func actions(actions: [BaseAction<AttachmentImpl>]) {
        _ = attachmentsView?.actions(actions: actions)
    }
    
}

struct ControllerViewContainer: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> AttachmentDemoViewController {
        return AttachmentDemoViewController()
    }
    
    func updateUIViewController(_ uiViewController: AttachmentDemoViewController, context: Context) {
    }
}

struct AttachmentViewControllerView: View {
    var body: some View {
        ScrollView {
            ControllerViewContainer()
        }
    }
}

struct AttachmentViewControllerDemo_Previews: PreviewProvider {
    static var previews: some View {
        AttachmentViewControllerView()
    }
}

class AttachmentDemoViewController : UIViewController {
    var myCollectionView:UICollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let view = UIView()
        view.backgroundColor = .white
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 320)
        
        myCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        myCollectionView?.register(AttachmentViewCell.self, forCellWithReuseIdentifier: "MyCell")
        myCollectionView?.backgroundColor = UIColor.white
        
        myCollectionView?.dataSource = self
 
        view.addSubview(myCollectionView ?? UICollectionView())
        
        self.view = view
    }
}

extension AttachmentDemoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! AttachmentViewCell
        if indexPath.row == 2 {
            myCell.readonly()
        }
        myCell.maxAttachment(number: 3)
        myCell.actions(
            actions: [
                PhotoLibraryAction<AttachmentImpl>(label: "Select from Photos", onSaveImage: myCell.dataModel.makeFromImage),
                CameraAction<AttachmentImpl>(label: "Take a Photo", onSaveImage: myCell.dataModel.makeFromImage),
                DocumentAction<AttachmentImpl>(label: "Select from Files", allowedContentTypes: [.image, .svg, .pdf, .text, .swiftSource, UTType("org.openxmlformats.wordprocessingml.document")!, .presentation, .spreadsheet, .livePhoto, .movie], onSaveFile: myCell.dataModel.makeFromURL)
            ]
        )
        return myCell
    }
}
