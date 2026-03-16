//
//  GameScene.swift
//  uzay_oyunu Shared
//
//  Created by Serkan DURMUŞ on 1.03.2026.
//
import SpriteKit
import GameplayKit
import Foundation
import GameController

class GameScene: SKScene {
    
    // Oyuncu nesnesi
    private var player: SKSpriteNode!
    private var anaGezegenler: [Gezegen] = []
    
    // Ateş Efektleri (Nodes)
    private var thrusterMiddle: SKSpriteNode! // W tuşu (Orta)
    private var thrusterLeft: SKSpriteNode!   // D tuşu (Sol Ateş -> Sağa dönerken)
    private var thrusterRight: SKSpriteNode!  // A tuşu (Sağ Ateş -> Sola dönerken)
    
  
    let normalTexture = SKTexture(imageNamed: "player")
    
    // Hareket bayrakları
    private var isAPressed = false
    private var isDPressed = false
    private var isWPressed = false
    private var isSPressed = false
    private var isMouseLeftPressed = false
    private var isSpacePressed = false
    private var gamepad: GCController?
    
   

    let kamera = SKCameraNode()
    
    // Fizik Değişkenleri
    var moveSpeedX: CGFloat = 0
    var moveSpeedY: CGFloat = 0
    private var updatedTime: TimeInterval!
    private var eskiKonumX: CGFloat!
    private var eskiKonumY: CGFloat!
    private var eskiHizX: CGFloat!
    private var eskiHizY: CGFloat!
    private var ivmeY : CGFloat!
    private var ivmeX : CGFloat!
    
    private var aci : CGFloat = 0;
  
    
    
    override func didMove(to view: SKView) {
            setupPlayer()
            setupThrusters()
            setupGezegen()
        setupGamepadObserver()
            // Kamera ayarları
            if kamera.parent == nil {
                self.addChild(kamera)
            }
        
            self.camera = kamera

     
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
    
    
    // TODO: Başı boş gezen meteorlar eklenecek.
    // TODO: Hızlanınca kamera genisleyecek yavaslayinca eski haline gelecek.
    // TODO: Yildizlar eklenecek
    
    
    
    
    
    
    // MARK: - Gamepad (Xbox/PS) Kurulumu
        func setupGamepadObserver() {
            // Kontrolcü bağlandığında haber ver
            NotificationCenter.default.addObserver(self, selector: #selector(kontrolcuBaglandi), name: .GCControllerDidConnect, object: nil)
            
            // Kontrolcü koptuğunda haber ver
            NotificationCenter.default.addObserver(self, selector: #selector(kontrolcuKoptu), name: .GCControllerDidDisconnect, object: nil)
            
            // Eğer oyun açıldığında kontrolcü zaten bağlıysa onu hemen yakala
            if let mevcutKontrolcu = GCController.controllers().first {
                kontrolcuAyarla(kontrolcu: mevcutKontrolcu)
            }
        }
        
        @objc func kontrolcuBaglandi(notification: Notification) {
            guard let kontrolcu = notification.object as? GCController else { return }
            print("🎮 Gamepad Bağlandı: \(kontrolcu.vendorName ?? "Bilinmeyen Cihaz")")
            kontrolcuAyarla(kontrolcu: kontrolcu)
        }
    func kontrolcuAyarla(kontrolcu: GCController) {
            gamepad = kontrolcu
            
            // Çoğu modern kontrolcü "Extended Gamepad" profiline uyar
            guard let extendedGamepad = kontrolcu.extendedGamepad else { return }
            
            
        // 1. GAZ: Xbox'ta 'A' tuşuna (veya istersen sağ tetiğe) basıldığında W'ye basılmış gibi yap
        /*
            extendedGamepad.buttonA.valueChangedHandler = { (button, value, pressed) in
                self.isWPressed = pressed
            }
            */
            // Alternatif Gaz: Sağ Tetik (RT) kullanmak istersen üsttekini silip bunu açabilirsin
            
            extendedGamepad.rightTrigger.valueChangedHandler = { (button, value, pressed) in
                self.isWPressed = pressed
            }
            
            
            // 2. SOLA DÖNÜŞ: D-Pad Sol Tuşu
            extendedGamepad.dpad.left.valueChangedHandler = { (button, value, pressed) in
                self.isAPressed = pressed
            }
            
            // 3. SAĞA DÖNÜŞ: D-Pad Sağ Tuşu
            extendedGamepad.dpad.right.valueChangedHandler = { (button, value, pressed) in
                self.isDPressed = pressed
            }
            
            // Ekstra: Sol Analog Joystick (Thumbstick) ile dönmek istersen:
            extendedGamepad.leftThumbstick.valueChangedHandler = { (stick, xValue, yValue) in
                // xValue -1.0 (Tam Sol) ile 1.0 (Tam Sağ) arası değer alır
                if xValue < -0.3 {
                    self.isAPressed = true
                    self.isDPressed = false
                } else if xValue > 0.3 {
                    self.isDPressed = true
                    self.isAPressed = false
                } else {
                    self.isAPressed = false
                    self.isDPressed = false
                }
            }
        }
        @objc func kontrolcuKoptu(notification: Notification) {
            print("⚠️ Gamepad Bağlantısı Koptu!")
            gamepad = nil
            // Kontrolcü koparsa gemi takılı kalmasın diye tuşları sıfırlıyoruz
            isWPressed = false
            isAPressed = false
            isDPressed = false
        }
        // MARK: - SETUP
    func setupGezegen() {
                
        for _ in 1...5{
           let gezegen = Gezegen()
           
            addChild(gezegen)
            
            anaGezegenler.append(gezegen)
        }
              
              
        
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
        player.zPosition = 1
        
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
    
    // MARK: - UPDATE
    
    override func update(_ currentTime: TimeInterval) {
       
        ivmeX = 0
        ivmeY = 0
        
        /// Delta değerleri ( ∆ )
        if(updatedTime == nil){
            updatedTime = currentTime
        }
        let dt = currentTime - updatedTime
        updatedTime = currentTime
        
        if(eskiKonumX == nil){
            eskiKonumX = player.position.x
        }
        let dVx = (player.position.x - eskiKonumX) * (dt * 50)
        eskiKonumX = player.position.x
        
        if(eskiKonumY == nil){
            eskiKonumY = player.position.y
        }
        let dVy = (player.position.y - eskiKonumY) * (dt * 50)
        eskiKonumY = player.position.y
        
        if(eskiHizX == nil){
            eskiHizX = dVx
        }
        let dAx = (dVx - eskiHizX) * (dt * 50)
        eskiHizX = dVx

        if(eskiHizY == nil){
            eskiHizY = dVy
        }
        let dAy = (dVy - eskiHizY) * (dt * 50)
        eskiHizY = dVy
        /// Deltalar ( ∆ ) bitiş
        
        
        /// Kamera Ayarı
        #if os(iOS) || os(tvOS)
        kamera.position = player.position
        #endif
    
        if dAy > 5 || dAy < -5 {
            print("\n\n--------------------------------------------------------------")
            print("IvmeX: \(dAx), HızX: \(eskiHizX!), Zaman: \(Int(currentTime) % 1000)")
            print("IvmeY: \(dAy), HızY: \(eskiHizY!), Zaman: \(Int(currentTime) % 1000)")
            print("--------------------------------------------------------------")
        }

        let radyan = aci * .pi / 180.0
        player.zRotation = -1 * radyan
        for gezegen in anaGezegenler {
            gezegen.gezegenIsle(player: &player, ivmeXGemi: &ivmeX, ivmeYGemi: &ivmeY, moveSpeedY: &moveSpeedY, moveSpeedX: &moveSpeedX )
        }
        

        // Sadece Görünürlük Kontrolleri
        thrusterMiddle.isHidden = !isWPressed
        thrusterLeft.isHidden = !isDPressed
        thrusterRight.isHidden = !isAPressed
        
        

       
 
        
        // Dönüş kontrolleri
        if isAPressed { aci -= 2 }
        if isDPressed { aci += 2 }
        
       
        if isWPressed {
   
            ivmeY += 1000 * cos(radyan)
            ivmeX += 1000 * sin(radyan)
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
#if os(OSX)
kamera.position = player.position
#endif
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
    override func mouseDragged(with event: NSEvent) {
        
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

