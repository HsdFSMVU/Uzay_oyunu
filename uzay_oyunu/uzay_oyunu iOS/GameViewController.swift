//
//  GameViewController.swift
//  uzay_oyunu iOS
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
            // Sahnenin ekranı tam kaplamasını sağlıyoruz
            scene.scaleMode = .aspectFill
            
            if let skView = self.view as? SKView {
                skView.presentScene(scene)
                
                skView.ignoresSiblingOrder = true
                skView.showsFPS = true
                skView.showsNodeCount = true
            }
        }
    }

    // Butonu oluşturan ve ekrana yerleştiren fonksiyon
    private func setupButton() {
        let myButton = UIButton(type: .system)
        myButton.setTitle("Oyunu Başlat", for: .normal)
        myButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        myButton.backgroundColor = .systemBlue
        myButton.setTitleColor(.white, for: .normal)
        myButton.layer.cornerRadius = 12
        
        // Butonun tıklanma olayını (aksiyonunu) bağlıyoruz
        myButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        // Auto Layout (Otomatik Yerleşim) kullanacağımızı belirtiyoruz
        myButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(myButton)
        
        // Butonun ekrandaki konumunu ayarlıyoruz (Örn: Alt orta kısım)
        NSLayoutConstraint.activate([
            myButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            myButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            myButton.widthAnchor.constraint(equalToConstant: 160),
            myButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // Butona tıklandığında çalışacak fonksiyon
    @objc private func buttonTapped() {
        print("Butona tıklandı!")
        // Burada yapmak istediğiniz işlemi ekleyebilirsiniz.
        // Örneğin: Oyunun duraklatılması, yeni sahneye geçiş vb.
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return .landscape // Sadece yatay modda çalışmaya zorlar
        }
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
