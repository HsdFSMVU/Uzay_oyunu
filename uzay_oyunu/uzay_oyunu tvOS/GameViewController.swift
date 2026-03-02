//
//  GameViewController.swift
//  uzay_oyunu tvOS
//
//  Created by Serkan DURMUŞ on 1.03.2026.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let scene = SKScene(fileNamed: "GameScene") {
            scene.scaleMode = .aspectFill
            
            if let skView = self.view as? SKView {
                skView.ignoresSiblingOrder = true
                skView.showsFPS = true
                skView.showsNodeCount = true
                
                skView.presentScene(scene)
            }
        }
    }

}
