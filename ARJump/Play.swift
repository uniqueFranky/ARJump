//
//  Play.swift
//  ARJump
//
//  Created by 闫润邦 on 2022/7/15.
//

import Foundation
import ARKit
import SceneKit
import AVFoundation

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
        pressPlayer.play()
        startTime = Date.timeIntervalSinceReferenceDate
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(pushPrg), userInfo: nil, repeats: true)
        
        
        SCNTransaction.animationDuration = 2
        personPlatform.node.runAction(SCNAction.move(by: SCNVector3(x: 0, y: -personPlatform.height * 0.2, z: 0), duration: 2))
        personPlatform.node.scale.y = 0.6
    }
    
    
    //Start to Jump
    @objc func touchUp() {
        
        timer.invalidate()
        resetPrg()
        let duration = Date.timeIntervalSinceReferenceDate - startTime
        personPlatform.node.scale.y = 1
//        personPlatform.node.runAction(SCNAction.move(by: SCNVector3(x: 0, y: personPlatform.height * 0.2, z: 0), duration: 0))
        let d = Float(duration)
        personPlatform.node.physicsBody?.type = .dynamic
        var xScale: Int
        var zScale: Int
        if jumpDir == .x {
            xScale = 1
            zScale = 0
        } else {
            xScale = 0
            zScale = 1
        }
        
        //Jump
        personPlatform.node.physicsBody?.isAffectedByGravity = true
        personPlatform.node.physicsBody?.applyForce(SCNVector3(x: 0.4 * d * Float(xScale), y: 0.5, z: 0.4 * d * Float(zScale)), asImpulse: true)
        
        
            /*
                Rotation Influences Move, have no solution now.
             */
        
//        personPlatform.node.runAction(SCNAction.rotate(by: CGFloat(Double.pi * 2), around: SCNVector3(x: personPlatform.height / 2 * Float((xScale ^ 1)), y: 0, z: personPlatform.height / 2 * Float((zScale ^ 1))), duration: 1))
        
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
                    self.failPlayer.play()
                    let alert = UIAlertController(title: "失败", message: "您掉了下去！\n", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "再玩一次", style: .default) { _ in
                        //Restart the Game
//                        if #available(iOS 15, *) {
//                            self.storage.insertHistory(ofScore: self.currentScore, atTime: Date.now)
//                        } else {
//                            // Fallback on earlier versions
//                        }
                        self.storage.insertHistory(ofScore: self.currentScore, atTime: Date())
                        self.currentScore = 0
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
                self.fallPlayer.play()
                self.currentScore += 1
                self.scoreLabel.setNeedsLayout()
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
