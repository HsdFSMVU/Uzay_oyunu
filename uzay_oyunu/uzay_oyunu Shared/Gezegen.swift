import SpriteKit

class Gezegen: SKSpriteNode {
    
    private var boyut: CGFloat
    private var yukseklik: CGFloat
    private var yercekimi: CGFloat
    
    

    
    struct Ivmeler {
        var oyuncuIvmeX: CGFloat
        var oyuncuIvmeY: CGFloat
    }
    
   
    init(konumX: CGFloat, konumY: CGFloat, boyut: CGFloat, yukseklik: CGFloat, yercekimi: CGFloat, texture: SKTexture) {
        self.boyut = boyut
        self.yukseklik = yukseklik
        self.yercekimi = yercekimi
        
       
        
       
        
        super.init(texture: texture, color: .clear, size: CGSize(width: 2 * boyut, height: 2 * boyut))
        

        self.position = CGPoint(x: konumX, y: konumY)
        
        
    
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        ivmeXGemi = ivmeX
        ivmeYGemi = ivmeY
        
    }
}
