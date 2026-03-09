//
//  GameScene.swift
//  uzay_oyunu Shared
//
//  Created by Serkan DURMUŞ on 1.03.2026.
//
import SpriteKit
import GameplayKit
import Foundation

class GameScene: SKScene {
    
    // Oyuncu nesnesi
    private var player: SKSpriteNode!
    private var anaGezegen: Gezegen!
    // Ateş Efektleri (Nodes)
    private var thrusterMiddle: SKSpriteNode! // W tuşu (Orta)
    private var thrusterLeft: SKSpriteNode!   // D tuşu (Sol Ateş -> Sağa dönerken)
    private var thrusterRight: SKSpriteNode!  // A tuşu (Sağ Ateş -> Sola dönerken)
    
  
    let normalTexture = SKTexture(imageNamed: "player")
    let gezegenTexture = SKTexture(imageNamed: "maviGezegen")
    // Hareket bayrakları
    private var isAPressed = false
    private var isDPressed = false
    private var isWPressed = false
    private var isSPressed = false
    private var isMouseLeftPressed = false
    private var isSpacePressed = false
    
    // Ses kontrolü
    private var hasTriggeredRocketSound = false
    var ses = SKAudioNode( fileNamed: "rocket_sound")
    let kamera = SKCameraNode()
    
    // Fizik Değişkenleri
    var moveSpeedX: CGFloat = 0
    var moveSpeedY: CGFloat = 0
    private var updatedTime: TimeInterval = 0;
    private var ivmeY : CGFloat = 0;
    private var ivmeX : CGFloat = 0;
    private var aci : CGFloat = 0;
  
    let rocketSound = SKAction.playSoundFileNamed("rocket_sound", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
            setupPlayer()
            setupThrusters()
            setupGezegen()
            // Kamera ayarları
            if kamera.parent == nil {
                self.addChild(kamera)
            }
      
            self.camera = kamera
        ses = SKAudioNode( fileNamed: "rocket_sound")
        ses.run(SKAction.stop())
        player.addChild(ses)
     
            #if os(iOS) || os(tvOS)
            setupControls()
            
            // DEĞİŞİKLİK BURADA: Hesaplamayı ekran tam oturduktan sonra yapması için sıraya alıyoruz
            DispatchQueue.main.async {
                self.updateButtonLayout()
            }
            #endif
        }
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        #if os(iOS)
        updateButtonLayout()
        #endif
    }
    
    func setupGezegen() {
          
       
            
             anaGezegen = Gezegen(konumX: -4000,
                                 konumY: 4000,
                                 boyut: 1000,      // Yarıçapı 1000 kabul ettiğimiz için çapı 2000 yaptık
                                 yukseklik: 0,
                                 yercekimi: 500000, // Eski sabit değerin
                                 texture: gezegenTexture)
            
            anaGezegen.zPosition = 0 // Oyuncunun arkasında kalsın
            addChild(anaGezegen)
        }

    func normalPlayer(){
        player.texture = normalTexture;
        let scale: CGFloat = 1
        player.setScale(scale)
    }
    
    func setupPlayer() {
        let texture = SKTexture(imageNamed: "player")
        player = SKSpriteNode(texture: texture)
        
        let scale: CGFloat = 0.5
        player.setScale(scale)
        player.zPosition = 1 // Oyuncu katmanı
        
        if player.parent == nil {
            player.position = .zero
            addChild(player)
        }
    }
    
    // YENİ: Ateş efektlerini kuran fonksiyon
    func setupThrusters() {
        // ÖNEMLİ DEĞİŞİKLİK:
        // Ateşleri sahneye (self) değil, player'a ekliyoruz.
        // Konumlarını (0,0) yapıyoruz çünkü player'ın tam merkezinde (veya üstünde) olacaklar.
        
        // 1. Orta Ateş (W için)
        thrusterMiddle = SKSpriteNode(imageNamed: "fly_ates_orta")
        // Parent'ı player olduğu için scale değerini 1 yapıyoruz (player zaten 0.5 scale edilmiş)
        thrusterMiddle.setScale(1.0)
        thrusterMiddle.position = .zero // Player'ın tam merkezi
        thrusterMiddle.zPosition = 2 // Player(1) olduğu için bu 2 olunca ÖNDE görünür.
        thrusterMiddle.isHidden = true
        player.addChild(thrusterMiddle) // DİKKAT: Player'a ekledik
        
        // 2. Sol Ateş (D tuşu için)
        thrusterLeft = SKSpriteNode(imageNamed: "fly_ates_sol")
        thrusterLeft.setScale(1.0)
        thrusterLeft.position = .zero
        thrusterLeft.zPosition = 2
        thrusterLeft.isHidden = true
        player.addChild(thrusterLeft)
        
        // 3. Sağ Ateş (A tuşu için)
        thrusterRight = SKSpriteNode(imageNamed: "fly_ates_sag")
        thrusterRight.setScale(1.0)
        thrusterRight.position = .zero
        thrusterRight.zPosition = 2
        thrusterRight.isHidden = true
        player.addChild(thrusterRight)
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        ivmeX = 0
        ivmeY = 0
        if ivmeY > 2000 || ivmeY < -2000 {
           print("hi")
        }
        kamera.position = player.position
        
        let radyan = aci * .pi / 180.0
        player.zRotation = -1 * radyan
        anaGezegen.gezegenIsle(player: &player, ivmeXGemi: &ivmeX, ivmeYGemi: &ivmeY, moveSpeedY: &moveSpeedY, moveSpeedX: &moveSpeedX )

        // Sadece Görünürlük Kontrolleri
        thrusterMiddle.isHidden = !isWPressed
        thrusterLeft.isHidden = !isDPressed
        thrusterRight.isHidden = !isAPressed
        
        
        if(updatedTime == 0){
            updatedTime = currentTime
        }
        let dt = currentTime - updatedTime
        updatedTime = currentTime
        // gezegen
        let uzaklikX : CGFloat = ( 4000 - player.position.x )
        let uzaklikY : CGFloat = ( 4000 - player.position.y )
        let uzunKenar: CGFloat = ((uzaklikX * uzaklikX) + (uzaklikY * uzaklikY)).squareRoot()
        print("\(uzaklikX) \t \(uzaklikY) \t \(uzunKenar) \t (dt)")
        let sinP : CGFloat = ( uzaklikY / uzunKenar )
        let cosP : CGFloat = ( uzaklikX / uzunKenar )
        
        ivmeY += (500000 * sinP ) /  (uzunKenar )
     
        ivmeX += (500000 *  cosP ) / (uzunKenar)
      
        if( uzunKenar <= 1000){
            moveSpeedX /= 1.4
            moveSpeedY /= 1.4
                player.position.x = 4000 - 1000 * cosP
                player.position.y = 4000 - 1000 * sinP
            
        }
        //gezegen bitis
 
        
        // Dönüş kontrolleri
        if isAPressed { aci -= 1 }
        if isDPressed { aci += 1 }
        
       
        if isWPressed {
            if !hasTriggeredRocketSound {
                hasTriggeredRocketSound = true
                ses.run(SKAction.play())
            }else {
                ses.run(SKAction.stop())

            }
        
            
            ivmeY += 1000 * cos(radyan)
            ivmeX += 1000 * sin(radyan)
        } else {
            hasTriggeredRocketSound = false
            player.removeAllActions()
        }
        
      
        
        // 2. HIZ GÜNCELLEMESİ
        moveSpeedY += dt * ivmeY
        moveSpeedX += dt * ivmeX
        
        // Sürtünme
        if player.position.y <= -460 {
            moveSpeedX /= 1.3
        } else {
           
        }
        
        // 3. KONUM GÜNCELLEMESİ
        player.position.x += moveSpeedX * dt
        player.position.y += moveSpeedY * dt
        
        // 4. ZEMİN KONTROLÜ
        if player.position.y <= -460 {
            player.position.y = -460
            
            if moveSpeedY < 0 {
                moveSpeedY = 0
            }
        }
    }
  
}

// MARK: - iOS / Dokunmatik Kontroller
#if os(iOS) || os(tvOS)
extension GameScene {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        evaluateTouches(event?.allTouches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        evaluateTouches(event?.allTouches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        evaluateTouches(event?.allTouches)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        evaluateTouches(event?.allTouches)
    }
 
    private func evaluateTouches(_ touches: Set<UITouch>?) {
        isWPressed = false
        isAPressed = false
        isDPressed = false
        isMouseLeftPressed = false
        
        guard let touches = touches else { return }
        
        for touch in touches {
            if touch.phase == .ended || touch.phase == .cancelled { continue }
            
            let location = touch.location(in: self.kamera)
            let nodesAtPoint = kamera.nodes(at: location)
            
            if nodesAtPoint.contains(where: { $0.name == "gasButton" }) {
                isWPressed = true
            }
            if nodesAtPoint.contains(where: { $0.name == "leftButton" }) {
                isAPressed = true
            }
            if nodesAtPoint.contains(where: { $0.name == "rightButton" }) {
                isDPressed = true
            }
        }
    }
    
    func setupControls() {
        if kamera.childNode(withName: "gasButton") != nil { return }
        
        let gasButton = createButton(name: "gasButton", text: "GAZ", color: .red, position: .zero)
        kamera.addChild(gasButton)
        
        let leftButton = createButton(name: "leftButton", text: "SOL", color: .blue, position: .zero)
        kamera.addChild(leftButton)
        
        let rightButton = createButton(name: "rightButton", text: "SAĞ", color: .blue, position: .zero)
        kamera.addChild(rightButton)
    }
    
    func updateButtonLayout() {
        guard let view = self.view else { return }
        
        guard let gasButton = kamera.childNode(withName: "gasButton") as? SKSpriteNode,
              let leftButton = kamera.childNode(withName: "leftButton") as? SKSpriteNode,
              let rightButton = kamera.childNode(withName: "rightButton") as? SKSpriteNode else {
            return
        }
        
        let safeArea = view.safeAreaInsets
        let viewHeight = view.bounds.height
        let viewWidth = view.bounds.width
        let margin: CGFloat = 20
        let buttonSize: CGFloat = 80
        
        // Sol Alt
        let leftButtonViewPoint = CGPoint(
            x: safeArea.left + margin + (buttonSize / 2),
            y: viewHeight - safeArea.bottom - margin - (buttonSize / 2)
        )
        let leftButtonScenePoint = convertPoint(fromView: leftButtonViewPoint)
        let leftButtonCameraPos = kamera.convert(leftButtonScenePoint, from: self)
        
        leftButton.position = leftButtonCameraPos
        rightButton.position = CGPoint(x: leftButtonCameraPos.x + 100, y: leftButtonCameraPos.y)
        
        // Sağ Alt
        let gasButtonViewPoint = CGPoint(
            x: viewWidth - safeArea.right - margin - (buttonSize / 2),
            y: viewHeight - safeArea.bottom - margin - (buttonSize / 2)
        )
        let gasButtonScenePoint = convertPoint(fromView: gasButtonViewPoint)
        let gasButtonCameraPos = kamera.convert(gasButtonScenePoint, from: self)
        
        gasButton.position = gasButtonCameraPos
    }
    
    private func createButton(name: String, text: String, color: SKColor, position: CGPoint) -> SKSpriteNode {
        let button = SKSpriteNode(color: color, size: CGSize(width: 80, height: 80))
        button.name = name
        button.position = position
        button.zPosition = 100
        button.alpha = 0.6
        
        let label = SKLabelNode(text: text)
        label.fontSize = 20
        label.fontName = "AvenirNext-Bold"
        label.verticalAlignmentMode = .center
        label.zPosition = 101
        button.addChild(label)
        
        return button
    }
}
#endif

// MARK: - macOS / Klavye & Mouse Kontrolleri
#if os(OSX)
extension GameScene {
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 1: isSPressed = true
        case 0: isAPressed = true
        case 2: isDPressed = true
        case 13: isWPressed = true
        case 49: isSpacePressed = true
        default: break
        }
    }
    
    override func keyUp(with event: NSEvent) {
        switch event.keyCode {
        case 1: isSPressed = false
        case 0: isAPressed = false
        case 2: isDPressed = false
        case 13: isWPressed = false
        case 49: isSpacePressed = false
        default: break
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        isMouseLeftPressed = true
        let location = event.location(in: self.kamera)
        let nodesAtPoint = kamera.nodes(at: location)
        
        if nodesAtPoint.contains(where: { $0.name == "gasButton" }) { isWPressed = true }
        if nodesAtPoint.contains(where: { $0.name == "leftButton" }) { isAPressed = true }
        if nodesAtPoint.contains(where: { $0.name == "rightButton" }) { isDPressed = true }
    }

    override func mouseUp(with event: NSEvent) {
        isMouseLeftPressed = false
    }
}
#endif

