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
            self.constantY = self.personPlatform.node.presentation.worldPosition.y

        }
    }
    
    //Prepare for Jump
    @objc func touchDown() {
        print("touchDown")
        startTime = Date.now
//        print("rotation: ", self.personNode.presentation.rotation)

    }
    
    
    //Start to Jump
    @objc func touchUp() {
        print("touchUp")
        let duration = Date().timeIntervalSince(startTime)
        print(duration)
        
        let d = Float(duration)
        personPlatform.node.physicsBody?.type = .dynamic
        var xScale: Float
        var zScale: Float
        if jumpDir == .x {
            xScale = -1
            zScale = 0
        } else {
            xScale = 0
            zScale = 1
        }
        personPlatform.node.physicsBody?.isAffectedByGravity = true
        personPlatform.node.physicsBody?.applyForce(SCNVector3(x: 0.5 * d * xScale, y: 0.5, z: 0.5 * d * zScale), asImpulse: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.personPlatform.node.physicsBody?.type = .kinematic
            self.personPlatform.node.physicsBody?.isAffectedByGravity = false
            print(self.personPlatform.node.presentation.worldPosition.y)
            var pos = self.personPlatform.node.presentation.worldPosition
            
            pos.y = self.constantY
            self.personPlatform.node.physicsBody?.clearAllForces()
            self.personPlatform.node.runAction(SCNAction.move(to: pos, duration: 0.3))
            self.personPlatform.node.runAction(SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.5))
//            print("rotation: ", self.personNode.presentation.rotation)
            
            self.nowPlatform = self.nxtPlatform
            self.nxtPlatform = self.addNewPlatform(afterPerson: self.personPlatform)
        }
    }
}
