//
//  ViewController.swift
//  ARJump
//
//  Created by 闫润邦 on 2022/7/15.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        configureSceneView()
        configureScene()
    }
    
    //run session
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        //detect horizontal planes
        configuration.planeDetection = [.horizontal]
        sceneView.session.run(configuration)
    }
    
    //pause session
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
}


//Configure Functions
extension ViewController {
    func configureSceneView() {
        sceneView.delegate = self
        sceneView.debugOptions = [.showWorldOrigin, .showPhysicsShapes]
        sceneView.showsStatistics = true
    }
    
    func configureScene() {
        let scene = SCNScene()
        sceneView.scene = scene
    }
}

//ARSCNView Delegate
extension ViewController: ARSCNViewDelegate {
    //Detected a Plane
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        //Only process anchors for planes
        guard let planeAchor = anchor as? ARPlaneAnchor else {
            return
        }
        guard let meshGeometry = ARSCNPlaneGeometry(device: sceneView.device!) else {
            fatalError()
        }
        meshGeometry.update(from: planeAchor.geometry)
        let meshNode = SCNNode(geometry: meshGeometry)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.blue
        meshNode.geometry?.materials = [material]
        meshNode.opacity = 0.5
        
        node.addChildNode(meshNode)
    }
    
    //Update Plane
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        guard let meshNode = node.childNodes.first else {
            return
        }
        guard let meshGeometry = meshNode.geometry as? ARSCNPlaneGeometry else {
            return
        }

        meshGeometry.update(from: planeAnchor.geometry)
    }
}



