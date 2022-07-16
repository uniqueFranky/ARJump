//
//  Draw.swift
//  ARJump
//
//  Created by 闫润邦 on 2022/7/15.
//

import Foundation
import SceneKit

extension ViewController {
    
    func drawPerson() -> Platform {
        let personNode = SCNNode()
        let headNode = SCNNode(geometry: SCNSphere(radius: 0.015))
        let bodyNode = SCNNode(geometry: SCNCone(topRadius: 0, bottomRadius: 0.015, height: 0.05))

        personNode.addChildNode(headNode)
        personNode.addChildNode(bodyNode)

        
        let colors: [UIColor] = [
            .brown,
            .black,
            .darkGray,
            .label,
            .blue,
            .magenta,
            .orange,
            .purple,
            .yellow
        ]
        let color = Int.random(in: 0..<colors.count)
        
        let material = materialFrom.copy() as! SCNMaterial
        material.diffuse.contents = colors[color]
        material.diffuse.intensity = 1

        headNode.geometry?.materials = [material]
        bodyNode.geometry?.materials = [material]

        bodyNode.position = SCNVector3(x: 0, y: 0, z: 0)
        headNode.position = SCNVector3(x: 0, y: 0.025, z: 0)

        personNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: personNode))
        personNode.physicsBody?.restitution = 0
        personNode.physicsBody?.mass = 1
        
        return Platform(with: personNode, ofRadius: 0.015, ofHeight: 0.025 + 0.015 + 0.025 + 0.025 / 2)
    }
    
    func drawCube(withLen len: CGFloat, ofColor color: UIColor) -> Platform {
        let cubeNode = SCNNode(geometry: SCNBox(width: len, height: len, length: len, chamferRadius: 0))
        let material = materialFrom.copy() as! SCNMaterial
        material.diffuse.contents = color
        cubeNode.geometry?.materials = [material]
        return Platform(with: cubeNode, ofRadius: Float(len) / 2, ofHeight: Float(len))
    }
    
    func drawCylinder(withRadius r: CGFloat, height h: CGFloat, ofColor color: UIColor) -> Platform {
        let cylNode = SCNNode(geometry: SCNCylinder(radius: r, height: h))
        let material = materialFrom.copy() as! SCNMaterial
        material.diffuse.contents = color
        cylNode.geometry?.materials = [material]
        return Platform(with: cylNode, ofRadius: Float(r), ofHeight: Float(h))
    }
    
    
    func addNewPlatform(afterPlatform last: Platform) -> Platform {
        let shape = Int.random(in: 1...2)
        let dis = Float.random(in: 0.2...0.4)
        let dir = Int.random(in: 1...2)
        let colors: [UIColor] = [
            .brown,
            .black,
            .darkGray,
            .label,
            .blue,
            .magenta,
            .orange,
            .purple,
            .yellow
        ]
        let color = Int.random(in: 0..<colors.count)
        var platform: Platform
        if shape == 1 {
            platform = drawCube(withLen: 0.1, ofColor: colors[color])
        } else {
            platform = drawCylinder(withRadius: 0.05, height: 0.1, ofColor: colors[color])
        }
        
        var pos = last.node.worldPosition
        if dir == 1 {
            jumpDir = .x
            pos.x += dis
        } else {
            jumpDir = .z
            pos.z += dis
        }
        platform.node.worldPosition = pos
        sceneView.scene.rootNode.addChildNode(platform.node)
        return platform
    }
    
    
    func addNewPlatform(afterPerson last: Platform) -> Platform {
        let shape = Int.random(in: 1...2)
        let dis = Float.random(in: 0.2...0.4)
        let dir = Int.random(in: 1...2)
        let colors: [UIColor] = [
            .brown,
            .black,
            .darkGray,
            .label,
            .blue,
            .magenta,
            .orange,
            .purple,
            .yellow
        ]
        let color = Int.random(in: 0..<colors.count)
        var platform: Platform
        if shape == 1 {
            platform = drawCube(withLen: 0.1, ofColor: colors[color])
        } else {
            platform = drawCylinder(withRadius: 0.05, height: 0.1, ofColor: colors[color])
        }
        
        var pos = last.node.presentation.worldPosition
        if dir == 1 {
            jumpDir = .x
            pos.x += dis
        } else {
            jumpDir = .z
            pos.z += dis
        }
        pos.y -= 0.075
        platform.node.worldPosition = pos
        sceneView.scene.rootNode.addChildNode(platform.node)
        return platform
    }
}

struct Platform {
    let node: SCNNode
    let radius: Float
    let height: Float
    
    init(with node: SCNNode, ofRadius r: Float, ofHeight h: Float) {
        self.node = node
        self.radius = r
        self.height = h
    }
}
