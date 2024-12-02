//
//  SceneCatView.swift
//  SwiftUI-Awesome
//
//  Created by Jovins on 2021/7/29.
//

import SwiftUI
import SceneKit

struct SceneCatView: UIViewRepresentable {
    
    let scene = SCNScene(named: "cat.scn")!
    
    func makeUIView(context: Context) -> SCNView {
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(0, 0, 15)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.light!.color = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        lightNode.position = SCNVector3(0, 50, 50)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)

        // retrieve the SCNView
        let scnView = SCNView()
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        
        scnView.scene = scene

        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true

        // show statistics such as fps and timing information
        scnView.showsStatistics = false

        // configure the view
        scnView.backgroundColor = UIColor.white
    }
}

#if DEBUG
struct SceneCatView_Previews : PreviewProvider {
    static var previews: some View {
        SceneCatView()
    }
}
#endif
