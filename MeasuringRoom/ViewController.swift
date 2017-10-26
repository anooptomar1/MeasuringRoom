//
//  ViewController.swift
//  MeasuringRoom
//
//  Created by Dotugo Indonesia on 10/24/17.
//  Copyright © 2017 Ansyar Hafid. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet weak var holoContainer: UIView!
    var holoRoom: ARHoloRoom!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if ARWorldTrackingConfiguration.isSupported {
            holoRoom        = ARHoloRoom.instanceFromNib()
            holoRoom.frame  = self.holoContainer.frame
            holoRoom.setupScene()
            
            self.holoContainer.addSubview(holoRoom)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    @IBAction func resetHoloLines() {
        if holoRoom != nil {
            holoRoom.resetLines()
        }
    }
}

