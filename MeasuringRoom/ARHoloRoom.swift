//
//  ARHoloRoom.swift
//  Anchorock
//
//  Created by Ansyar Hafid on 10/22/17.
//  Copyright © 2017 Anchorock. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ARHoloRoom: UIView {
    @IBOutlet weak var sceneView:       ARSCNView!
    @IBOutlet weak var distanceLable:   UILabel!
    @IBOutlet weak var aimLabel:        UILabel!
    
    let session         = ARSession()
    let vectorZero      = SCNVector3()
    let sessionConfig   = ARWorldTrackingConfiguration()
    var measuring       = false
    var startValue      = SCNVector3()
    var endValue        = SCNVector3()
    
    class func instanceFromNib() -> ARHoloRoom {
        return UINib(nibName: "ARHoloRoom", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ARHoloRoom
    }
    
    func setupScene() {
        sceneView.delegate  = self
        sceneView.session   = session
        session.run(sessionConfig, options: [.resetTracking, .removeExistingAnchors])
        resetValues()
    }
    
    func resetValues() {
        measuring   = false
        startValue  = SCNVector3()
        endValue    = SCNVector3()
        
        updateResultLabel(0.0)
    }
    
    func updateResultLabel(_ value: Float) {
        let cm      = value * 100.0
        let inch    = cm*0.3937007874
        distanceLable.text = String(format: "%.2f cm / %.2f\"", cm, inch)
    }
    
    func detectObjects() {
        if let worldPos = sceneView.realWorldVector(screenPos: self.center) {
            aimLabel.isHidden = false
            if measuring {
                if startValue == vectorZero {
                    startValue = worldPos
                }
                
                endValue = worldPos
                updateResultLabel(startValue.distance(from: endValue))
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetValues()
        measuring = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        measuring = false
    }

}

extension ARHoloRoom: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.detectObjects()
        }
    }
}
