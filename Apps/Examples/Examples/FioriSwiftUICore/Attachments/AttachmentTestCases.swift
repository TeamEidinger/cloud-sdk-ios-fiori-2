//
//  MainView.swift
//  Attachments
//
//  Created by Xu, Charles on 3/3/23.
//

import SwiftUI
import UniformTypeIdentifiers
import FioriSwiftUICore

struct AttachmentTestCases: View {
    var body: some View {
        List {
            NavigationLink(destination: ScrollView {
                SingleAttachmentView1(readonly: false, showActionsAsContextMenu: false)
            }) {
                Text("Actions as Sheet")
            }
            
            NavigationLink(destination: ScrollView {
                SingleAttachmentView1(readonly: false, showActionsAsContextMenu: true)
            }) {
                Text("Actions as ContextMenu")
            }
            
            NavigationLink(destination: ScrollView {
                SingleAttachmentView1(readonly: true, showActionsAsContextMenu: false)
            }) {
                Text("Readonly")
            }
            
            NavigationLink(destination: ScrollView {
                SingleAttachmentView2()
            }) {
                Text("Demo QuickLook Thumbnails")
            }
            
            NavigationLink(destination: ScrollView {
                SingleAttachmentView4()
            }) {
                Text("More Types of QuickLook Thumbnails")
            }

            NavigationLink(destination: ScrollView {
                SingleAttachmentView3()
            }) {
                Text("Demo Alternative Preview")
            }

            NavigationLink(destination: AttachmentViewCollection().environmentObject(OrientationInfo())) {
                Text("Collection of Views")
            }
            
            NavigationLink(destination: ControllerViewContainer()) {
                Text("Integrate with UIViewController ")
            }

//            debug SwiftUI previews
//            NavigationLink(
//                destination: AttachmentGeneratorView()) {
//                Text("Image")
//            }
        }
    }
}

#if DEBUG

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AttachmentTestCases()
        }
    }
}

#endif
