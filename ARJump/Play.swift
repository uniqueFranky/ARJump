//
//  Play.swift
//  ARJump
//
//  Created by 闫润邦 on 2022/7/15.
//

import Foundation
import ARKit
import SceneKit

extension ViewController {
    @objc func selectPlane() {
        
        if started {
            return
        }
        
        //If Tapped on a Plane
        let tapLocation = tapRecognizer.location(in: sceneView)
        let castQuery = sceneView.raycastQuery(from: tapLocation, allowing: .existingPlaneGeometry, alignment: .horizontal)!
        let results = sceneView.session.raycast(castQuery)
        guard let result = results.first else {
            return
        }
        
        
        //Game Starts
        started = true
        sceneView.gestureRecognizers = []
        let url = Bundle.main.url(forResource: "test", withExtension: "scn", subdirectory: "art.scnassets")!
        let scn = try! SCNScene(url: url)
        sceneView.scene = scn
        
        pressBtn.isHidden = false
        
        let cubePlatform = drawCube(withLen: 0.1, ofColor: .black)

        sceneView.scene.rootNode.addChildNode(cubePlatform.node)
        var pos = SCNVector3(x: result.worldTransform.columns.3.x, y: result.worldTransform.columns.3.y, z: result.worldTransform.columns.3.z)
        cubePlatform.node.position = pos
        
        pos.y += 0.3
        personPlatform = drawPerson()
        sceneView.scene.rootNode.addChildNode(personPlatform.node)
        personPlatform.node.position = pos
        personPlatform.node.physicsBody?.isAffectedByGravity = false
        pos.y -= 0.225
            
        personPlatform.node.runAction(SCNAction.move(to: pos, duration: 0.5)) {
            self.personPlatform.node.physicsBody?.type = .kinematic
            print("kinetic")
            self.nxtPlatform = self.addNewPlatform(afterPlatform: cubePlatform)
            self.nowPlatform = cubePlatform

        }
    }
    
    //Prepare for Jump
    @objc func touchDown() {
        startTime = Date.timeIntervalSinceReferenceDate
    }
    
    
    //Start to Jump
    @objc func touchUp() {
        let duration = Date.timeIntervalSinceReferenceDate - startTime
        
        let d = Float(duration)
        personPlatform.node.physicsBody?.type = .dynamic
        print(sceneView.scene.physicsWorld.gravity)
        var xScale: Float
        var zScale: Float
        if jumpDir == .x {
            xScale = 1
            zScale = 0
        } else {
            xScale = 0
            zScale = 1
        }
        
        //Jump
        personPlatform.node.physicsBody?.isAffectedByGravity = true
        personPlatform.node.physicsBody?.applyForce(SCNVector3(x: 0.5 * d * xScale, y: 0.5, z: 0.5 * d * zScale), asImpulse: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            //Stop Jump
            self.personPlatform.node.physicsBody?.type = .kinematic
            self.personPlatform.node.physicsBody?.isAffectedByGravity = false
            
            //Adjust Position (Due to the delay of applying Inpulse on the object)
            var pos = self.personPlatform.node.presentation.worldPosition
            pos.y = self.nxtPlatform.node.presentation.worldPosition.y
            pos.y += self.personPlatform.height
            self.personPlatform.node.physicsBody?.clearAllForces()
            self.personPlatform.node.runAction(SCNAction.move(to: pos, duration: 0.3))
            self.personPlatform.node.runAction(SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.5))
            
            if self.shouldRemain() {
                return
            }
            
            if self.shouldFail() {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "失败", message: "您掉了下去！\n", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "再玩一次", style: .default) { _ in
                        //Restart the Game
                        self.started = false
                        self.configureTapRecognizer()
                        self.configureSceneView()
                        self.configureScene()
                        self.configurePressBtn()
                        let configuration = ARWorldTrackingConfiguration()
                        //detect horizontal planes
                        configuration.planeDetection = [.horizontal]
                        self.sceneView.session.run(configuration, options: [.removeExistingAnchors])
                    }
                    alert.addAction(okAction)
                    self.present(alert, animated: true)
                }
            } else {
                self.nowPlatform = self.nxtPlatform
                self.nxtPlatform = self.addNewPlatform(afterPerson: self.personPlatform)
            }
            
        }
    }
    
    func shouldFail() -> Bool {
        let r1 = personPlatform.radius
        let r2 = nxtPlatform.radius
        
        var dis: Float
        if jumpDir == .x {
            dis = abs(personPlatform.node.presentation.position.x - nxtPlatform.node.presentation.position.x)
        } else {
            dis = abs(personPlatform.node.presentation.position.z - nxtPlatform.node.presentation.position.z)
        }
        
        if dis > r1 / 2 + r2 {
            personPlatform.node.physicsBody?.type = .dynamic
            personPlatform.node.physicsBody?.isAffectedByGravity = true
            return true
        } else {
            return false
        }
    }
    
    func shouldRemain() -> Bool {
        let r1 = personPlatform.radius
        let r2 = nowPlatform.radius
        
        var dis: Float
        if jumpDir == .x {
            dis = abs(personPlatform.node.presentation.position.x - nowPlatform.node.presentation.position.x)
        } else {
            dis = abs(personPlatform.node.presentation.position.z - nowPlatform.node.presentation.position.z)
        }
        
        if dis > r1 / 2 + r2 {
            return false
        } else {
            return true
        }
    }
}
