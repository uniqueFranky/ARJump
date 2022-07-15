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
    let pressBtn = UIButton()
    let tapRecognizer = UITapGestureRecognizer()
    var startTime: Date!
    var started = false
    var jumpDir: JumpDir!
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
        sceneView.scene.physicsWorld.contactDelegate = self
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

extension ViewController {
    @objc func selectPlane() {
        
        if started {
            return
        }
        
        let tapLocation = tapRecognizer.location(in: sceneView)
        let castQuery = sceneView.raycastQuery(from: tapLocation, allowing: .existingPlaneGeometry, alignment: .horizontal)!
        let results = sceneView.session.raycast(castQuery)
        guard let result = results.first else {
            return
        }
        
        
        //Game Starts
        started = true
        sceneView.gestureRecognizers = []
        pressBtn.isHidden = false
        pressBtn.addTarget(self, action: #selector(touchDown), for: .touchDown)
        pressBtn.addTarget(self, action: #selector(touchUp), for: .touchUpInside)
        
        let url = Bundle.main.url(forResource: "test", withExtension: "scn", subdirectory: "art.scnassets")!
        let scn = try! SCNScene(url: url)
        let cubeNode = drawCube(withLen: 0.1, ofColor: .black)
        cubeNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: cubeNode.geometry!))

        sceneView.scene.rootNode.addChildNode(cubeNode)
        var pos = SCNVector3(x: result.worldTransform.columns.3.x, y: result.worldTransform.columns.3.y, z: result.worldTransform.columns.3.z)
        cubeNode.position = pos
        
        pos.y += 0.3
        let personNode = drawPerson()
        sceneView.scene.rootNode.addChildNode(personNode)
        personNode.position = pos
        personNode.physicsBody?.isAffectedByGravity = false
        pos.y -= 0.225
        personNode.runAction(SCNAction.move(to: pos, duration: 0.5)) {
            personNode.physicsBody?.type = .kinematic
            print("kinetic")
            self.addNewPlatform(after: cubeNode)
        }
    }
    
    @objc func touchDown() {
        print("touchDown")
        startTime = Date.now
    }
    @objc func touchUp() {
        print("touchUp")
        let duration = Date().timeIntervalSince(startTime)
        print(duration)
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
            material.diffuse.contents = UIColor.blue
            meshNode.geometry?.materials = [material]
            meshNode.opacity = 0.5
                
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



extension ViewController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        print("Contact!!!")
    }
    
}

