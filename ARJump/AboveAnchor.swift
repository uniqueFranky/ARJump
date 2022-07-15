//
//  AboveAnchor.swift
//  ARJump
//
//  Created by 闫润邦 on 2022/7/15.
//

import Foundation
import ARKit

class AboveAnchor: ARAnchor {
    init(from: ARAnchor, goUp: Float) {
        var transform = from.transform
        transform.columns.3.y += goUp
        let anchor = ARAnchor(transform: transform)
        super.init(anchor: anchor)
    }
    
    required init(anchor: ARAnchor) {
        super.init(anchor: anchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
