//
//  GameScene.swift
//  uzay_oyunu Shared
//
//  Created by Serkan DURMUŞ on 1.03.2026.
//
import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // Oyuncu nesnesi
    private var player: SKSpriteNode!
    let attackTexture = SKTexture(imageNamed: "s+attack")
    let normalTexture = SKTexture(imageNamed: "player")
    // Hareket bayrakları
    private var isAPressed = false
    private var isDPressed = false
    private var isWPressed = false
    private var isSPressed = false
    private var isMouseLeftPressed = false
    private var isSpacePressed = false
    
    // Sesin basılı tutarken saniyede 60 kere çalmasını engelleyecek kontrol bayrağı
    private var hasTriggeredRocketSound = false
   
    let kamera = SKCameraNode()
    // Hız ve Zaman
    var moveSpeedX: CGFloat = 0
    var moveSpeedY: CGFloat = 0
    private var updatedTime: TimeInterval = 0;
    var oldMS : CGFloat = 0;
    private var ivmeY : CGFloat = -200;
    private var ivmeX : CGFloat = 0;
    private var aci : CGFloat = 0;
  
    let rocketSound = SKAction.playSoundFileNamed("rocket_sound", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        setupPlayer()
        
        // Kamera daha önce eklenmemişse ekle (Çökmeyi engeller)
        if kamera.parent == nil {
            self.addChild(kamera)
        }
        self.camera = kamera
        
        // Butonları ekrana yerleştir
        setupButtons()
    }
    
    // MARK: - Buton Kurulumu
    func setupButtons() {
        // İsterseniz 'color: .systemRed' kısımlarını silip 'imageNamed: "butonGorseli"' yapabilirsiniz.
        
        // 1. Sağdaki GAZ (W) Butonu
        let gasButton = createButton(name: "gasButton", text: "GAZ", color: .systemRed, position: CGPoint(x: 300, y: -200))
        kamera.addChild(gasButton)
        
        // 2. Soldaki SOL (A) Butonu
        let leftButton = createButton(name: "leftButton", text: "SOL", color: .systemBlue, position: CGPoint(x: -300, y: -200))
        kamera.addChild(leftButton)
        
        // 3. Soldaki SAĞ (D) Butonu
        let rightButton = createButton(name: "rightButton", text: "SAĞ", color: .systemBlue, position: CGPoint(x: -200, y: -200))
        kamera.addChild(rightButton)
    }
    
    // Butonları kolayca oluşturmak için yardımcı fonksiyon
    private func createButton(name: String, text: String, color: SKColor, position: CGPoint) -> SKSpriteNode {
        let button = SKSpriteNode(color: color, size: CGSize(width: 80, height: 80))
        button.name = name
        button.position = position
        button.zPosition = 100
        
        let label = SKLabelNode(text: text)
        label.fontSize = 20
        label.fontName = "AvenirNext-Bold"
        label.verticalAlignmentMode = .center
        label.zPosition = 101 // Butonun üzerinde dursun
        button.addChild(label)
        
        return button
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
        
        if player.parent == nil {
            player.position = .zero
            player.zPosition = 1
            addChild(player)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        kamera.position = player.position
        let radyan = aci * .pi / 180.0
        player.zRotation = -1 * radyan
        
        if(updatedTime == 0){
            updatedTime = currentTime
        }
        let currentTimeInt = CGFloat(Int(currentTime*1000)) / 1000
        let dt = currentTime - updatedTime
        updatedTime = currentTime
        
        // Dönüş kontrolleri
        if isAPressed { aci -= 1 }
        if isDPressed { aci += 1 }
        
        // 1. İVME HESAPLAMA (Motor İtme Kuvveti)
        if isWPressed {
            // Gaza (veya W'ye) basıldığında sesi sadece 1 KERE oynat
            if !hasTriggeredRocketSound {
                hasTriggeredRocketSound = true
                player.run(rocketSound)
            }
            
            player.texture = SKTexture(imageNamed: "fly")
            
            ivmeY = 1000 * cos(radyan)
            ivmeX = 1000 * sin(radyan)
        } else {
            // Elini gazdan çektiyse bir sonraki basış için ses kontrolünü sıfırla
            hasTriggeredRocketSound = false
            
            player.texture = SKTexture(imageNamed: "player")
            ivmeX = 0
            ivmeY = 0 // Motor çalışmıyor
        }
        
        // Yerçekimini ekle
        ivmeY -= 500
        
        // 2. HIZ GÜNCELLEMESİ
        moveSpeedY += dt * ivmeY
        moveSpeedX += dt * ivmeX
        
        // Yatay Sürtünme
        if player.position.y <= -460 {
            moveSpeedX /= 1.3
        } else {
            moveSpeedX /= (isWPressed ? 1.01 : 1.001)
        }
        
        // 3. KONUM GÜNCELLEMESİ
        player.position.x += moveSpeedX * dt
        player.position.y += moveSpeedY * dt
        
        // 4. ZEMİN ÇARPIŞMA KONTROLÜ
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
    
    // Ekranda o an var olan tüm dokunuşları değerlendirir (Multi-touch desteği)
    private func evaluateTouches(_ touches: Set<UITouch>?) {
        // Önce hepsini false yapıyoruz
        isWPressed = false
        isAPressed = false
        isDPressed = false
        isMouseLeftPressed = false
        
        guard let touches = touches else { return }
        
        // Hala ekranda devam eden dokunuşları kontrol ediyoruz
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
}
#endif

// MARK: - macOS / Klavye & Mouse Kontrolleri
#if os(OSX)
extension GameScene {
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 1: isSPressed = true // 'S'
        case 0: isAPressed = true
        case 2: isDPressed = true
        case 13: isWPressed = true
        case 49: isSpacePressed = true
        default: break
        }
    }
    
    override func keyUp(with event: NSEvent) {
        switch event.keyCode {
        case 1: isSPressed = false // 'S'
        case 0: isAPressed = false
        case 2: isDPressed = false
        case 13: isWPressed = false
        case 49: isSpacePressed = false
        default: break
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        isMouseLeftPressed = true
        
        // Mouse ile tıklayarak test edebilmek için
        let location = event.location(in: self.kamera)
        let nodesAtPoint = kamera.nodes(at: location)
        
        if nodesAtPoint.contains(where: { $0.name == "gasButton" }) { isWPressed = true }
        if nodesAtPoint.contains(where: { $0.name == "leftButton" }) { isAPressed = true }
        if nodesAtPoint.contains(where: { $0.name == "rightButton" }) { isDPressed = true }
    }

    override func mouseUp(with event: NSEvent) {
        isMouseLeftPressed = false
        // Mouse bırakılınca ekrandaki butonların etkisini kaldır
        // (Ancak klavyeye basılı tutuyorsa bozmamak için burada sıfırlamıyorum, 
        // asıl oyun testini klavye ile yapabilirsiniz)
    }
}
#endif // os(OSX)

