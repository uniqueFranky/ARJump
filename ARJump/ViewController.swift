//
//  ViewController.swift
//  ARJump
//
//  Created by 闫润邦 on 2022/7/15.
//

import UIKit
import SceneKit
import ARKit

enum JumpDir: Int {
    case x
    case z
}

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    //pressBtn: Take Up the Whole Screen, Detecting the Duration of Press, in order to
    //          calculate the distance for the person to travel
    let pressBtn = UIButton()
    
    //tapRecognizer: For HitTest(RayCast), to select a point to start game
    let tapRecognizer = UITapGestureRecognizer()
    
    //startTime: Record the timestamp when press begins
    var startTime: Date!
    
    //started: Marks whether game has started
    var started = false
    
    //jumpDir: Marks the direction for jumping
    var jumpDir: JumpDir!
    
    //nowPlatform: The current platform on which the person is standing
    var nowPlatform: Platform!
    
    //nxtPlatform: The next platform on which the person is to stand
    var nxtPlatform: Platform!
    
    //personPlatform: The platform representing the person ( just see it as a platform or so )
    var personPlatform: Platform!
//    var constantY: Float!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTapRecognizer()
        configureSceneView()
        configureScene()
        configurePressBtn()
 
        
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
        sceneView.isUserInteractionEnabled = true

    }
    
    func configureScene() {
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.scene.physicsWorld.gravity = SCNVector3(x: 0, y: -1, z: 0)
    }
    
    func configureTapRecognizer() {
        sceneView.addGestureRecognizer(tapRecognizer)
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        tapRecognizer.addTarget(self, action: #selector(selectPlane))
    }
    
    func configurePressBtn() {
        sceneView.addSubview(pressBtn)
        pressBtn.frame = sceneView.frame
        pressBtn.backgroundColor = .clear
        pressBtn.isHidden = true
    }
}


//ARSCNView Delegate
extension ViewController: ARSCNViewDelegate {
    //Detected a Plane
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if anchor is ARPlaneAnchor {
            guard let planeAchor = anchor as? ARPlaneAnchor else {
                return
            }
            guard let meshGeometry = ARSCNPlaneGeometry(device: sceneView.device!) else {
                fatalError()
            }
                
            meshGeometry.update(from: planeAchor.geometry)
            let meshNode = SCNNode(geometry: meshGeometry)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.purple
            meshNode.geometry?.materials = [material]
            meshNode.opacity = 0.8
                
            node.addChildNode(meshNode)
            
        }
        
    }
    
    //Update Plane
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            print(anchor.transform.columns.3.y)
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


