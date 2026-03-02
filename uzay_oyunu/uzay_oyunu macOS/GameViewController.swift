//
//  GameViewController.swift
//  uzay_oyunu macOS
//
//  Created by Serkan DURMUŞ on 1.03.2026.
//

import Cocoa
import SpriteKit
import GameplayKit

class GameViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let scene = SKScene(fileNamed: "GameScene") {
            scene.scaleMode = .aspectFill
            
            if let skView = self.view as? SKView {
                skView.presentScene(scene)
                
                skView.ignoresSiblingOrder = true
                skView.showsFPS = true
                skView.showsNodeCount = true
            }
        }
    }

}

