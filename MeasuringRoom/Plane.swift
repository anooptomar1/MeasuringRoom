//
//  Plane.swift
//  MeasuringRoom
//
//  Created by Dotugo Indonesia on 10/24/17.
//  Copyright © 2017 Ansyar Hafid. All rights reserved.
//

import UIKit
import ARKit

class Plane: SCNNode {
    var anchor:         ARPlaneAnchor!
    var planeGeometry:  SCNPlane!
    
    init(anchor: ARPlaneAnchor) {
        super.init()
        
        self.anchor = anchor
        self.planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        
        let material = SCNMaterial()
        let image = UIImage(named: "griddy")
        material.diffuse.contents = image
        self.planeGeometry.materials = [material]
        
        let planeNode = SCNNode(geometry: self.planeGeometry)
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        //rotate 90degree to match ARKit plane
        planeNode.transform = SCNMatrix4MakeRotation(Float(Double.pi / 2), 1, 0, 0)
        
        self.setTextureScale()
        self.addChildNode(planeNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(anchor: ARPlaneAnchor) {
        self.planeGeometry.width = CGFloat(anchor.extent.x)
        self.planeGeometry.height = CGFloat(anchor.extent.z)
        self.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        self.setTextureScale()
    }
    
    func setTextureScale() {
        let width                           = self.planeGeometry.width
        let height                          = self.planeGeometry.height
        
        let material                        = self.planeGeometry.materials.first
        material?.diffuse.contentsTransform = SCNMatrix4MakeScale(Float(width), Float(height), 1)
        material?.diffuse.wrapS              = .repeat
        material?.diffuse.wrapT             = .repeat
    }
}
