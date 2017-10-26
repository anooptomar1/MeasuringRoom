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
    @IBOutlet weak var marker:          UILabel!
    
    let session         = ARSession()
    let vectorZero      = SCNVector3()
    let sessionConfig   = ARWorldTrackingConfiguration()
    var measuring       = false
    var startValue      = SCNVector3()
    var endValue        = SCNVector3()
    
    var previousPoint:  SCNVector3?
    var currentPoint:   SCNVector3?
    var lining          = false
    var lineColor       = UIColor.white
    
    var lines           = [Line]()
    var currentLine:    Line?
    var unit:           DistanceUnit = .meter
    
    var planes:         [UUID:Plane]!
    
    class func instanceFromNib() -> ARHoloRoom {
        return UINib(nibName: "ARHoloRoom", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ARHoloRoom
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touch is Starting")
        addPoint()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touch is Ending")
        if !lining { lining = true }
    }
    
    func addPoint() {
        if let worldPosition = sceneView.worldVector(screenPosition: self.center) {
            if startValue == vectorZero {
                startValue = worldPosition
            } else {
                startValue = endValue
            }
            endValue = worldPosition
            currentLine = Line(sceneView: sceneView, startVector: startValue, unit: unit)
        }
    }
    
    func lineDrawing() {
        if let worldPosition = sceneView.worldVector(screenPosition: self.center) {
            if lining {
                if startValue == vectorZero {
                    startValue = worldPosition
                } else {
                    startValue = endValue
                }
                endValue = worldPosition
                
                currentLine?.update(to: endValue)
            }
        }
    }
    
    func setupScene() {
        sceneView.delegate      = self
        sceneView.session       = session
        self.planes             = [UUID:Plane]()
        
        sceneView.debugOptions  = [ARSCNDebugOptions.showFeaturePoints]
        
        let scene               = SCNScene()
        sceneView.scene         = scene
        
        setupSession()
    }
    
    func setupSession() {
        sessionConfig.planeDetection    = .horizontal
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
        let inch    = cm * 0.3937007874
        print(String(format: "%.2f cm / %.2f\"", cm, inch))
        //distanceLable.text = String(format: "%.2f cm / %.2f\"", cm, inch)
    }
    
    func detectObjects() {

        if let worldPosition = sceneView.worldVector(screenPosition: self.center) {
            if lining {
                if startValue == vectorZero {
                    startValue = worldPosition
                    currentLine = Line(sceneView: sceneView, startVector: startValue, unit: unit)
                }
                
                endValue = worldPosition
                currentLine?.update(to: endValue)
            }
        }
    }
    
    func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
        
        let indices: [Int32] = [0, 1]
        
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        
        return SCNGeometry(sources: [source], elements: [element])
        
    }
    
    @IBAction func resetLines() {
        lining      = false
        startValue  = SCNVector3()
        endValue    = SCNVector3()
        currentLine = nil
        for node in sceneView.scene.rootNode.childNodes {
            node.removeFromParentNode()
        }
    }

}


//  Extension: ARSCNViewDelegate
extension ARHoloRoom: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.lineDrawing()
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if !anchor.isKind(of: ARPlaneAnchor.self) {
            return
        }
        
        let plane = Plane(anchor: anchor as! ARPlaneAnchor)
        self.planes[anchor.identifier] = plane
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let plane = planes[anchor.identifier] {
            plane.update(anchor: anchor as! ARPlaneAnchor)
        } else {
            return
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        self.planes.removeValue(forKey: anchor.identifier)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
    }
}
