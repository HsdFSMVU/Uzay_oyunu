import SpriteKit

class Gezegen: SKSpriteNode {
    
    private var boyut: CGFloat

    private var yercekimi: CGFloat
    
    let gezegenTexture = SKTexture(imageNamed: "MAVIGEZEGEN 1")

    
    
   
    
    
   
    init(konumX: CGFloat, konumY: CGFloat, boyut: CGFloat,  yercekimi: CGFloat, texture: SKTexture) {
        self.boyut = boyut
        
        self.yercekimi = yercekimi
        
       
        
       
        
        super.init(texture: texture, color: .clear, size: CGSize(width: 2 * boyut, height: 2 * boyut))
        self.zPosition = 1

        self.position = CGPoint(x: konumX, y: konumY)
        
        
    
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        let konumXRandom = CGFloat(Int.random(in: -10...10)) * 3000
        let konumYRandom = CGFloat(Int.random(in: 3...7)) * 3000
        let boyutRandom =  CGFloat(Int.random(in: 10...15)) * 100
        let yercekimiRandom = boyutRandom * 500
  
        self.boyut = boyutRandom
        self.yercekimi = yercekimiRandom
        super.init(texture: gezegenTexture, color: .clear, size: CGSize(width: 2 * boyut, height: 2 * boyut))
        self.zPosition = 0
        self.position = CGPoint(x: konumXRandom, y: konumYRandom)
        
        print("konumX: \(konumXRandom)  konumY: \(konumYRandom) boyut: \(boyutRandom) texture: \(gezegenTexture)")
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // 3. Çekim İşleme Fonksiyonu
    public func gezegenIsle(player:inout SKSpriteNode, ivmeXGemi:inout CGFloat, ivmeYGemi:inout CGFloat, moveSpeedY: inout CGFloat ,moveSpeedX: inout CGFloat) {
       
        let uzaklikX: CGFloat = (self.position.x - player.position.x)
        let uzaklikY: CGFloat = (self.position.y - player.position.y)
        let uzunKenar: CGFloat = ((uzaklikX * uzaklikX) + (uzaklikY * uzaklikY)).squareRoot()
        
       
      
        
        let sinP: CGFloat = (uzaklikY / uzunKenar)
        let cosP: CGFloat = (uzaklikX / uzunKenar)
      
       
        let ivmeX = (yercekimi * cosP) / uzunKenar
        let ivmeY = (yercekimi * sinP) / uzunKenar
        if( uzunKenar <= boyut){
            moveSpeedX /= 1.4
            moveSpeedY /= 1.4
                player.position.x = self.position.x - boyut * cosP
                player.position.y = self.position.y - boyut * sinP
            
        }
        ivmeXGemi += ivmeX
        ivmeYGemi += ivmeY
        
    }
}
