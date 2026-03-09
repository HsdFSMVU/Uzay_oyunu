// MetalPhysics.swift
import MetalKit
import simd

class MetalPhysics {
    private var device: MTLDevice?
    private var commandQueue: MTLCommandQueue?
    private var additionPipelineState: MTLComputePipelineState?
    
    init() {
        setupMetal()
    }
    
    private func setupMetal() {
        guard let device = MTLCreateSystemDefaultDevice() else { return }
        self.device = device
        self.commandQueue = device.makeCommandQueue()
        
        guard let library = device.makeDefaultLibrary() else {
            print("❌ HATA: Shaders.metal bulunamadı!")
            return
        }
        
        // "simpleAddition" adında bir kernel fonksiyonu arıyor
        // Eğer Shaders.metal dosyasında bu isimde fonksiyon yoksa çalışmaz!
        guard let function = library.makeFunction(name: "simpleAddition") else {
            print("⚠️ 'simpleAddition' fonksiyonu Shaders.metal içinde bulunamadı.")
            return
        }
        
        do {
            self.additionPipelineState = try device.makeComputePipelineState(function: function)
        } catch {
            print("❌ Pipeline Hatası: \(error)")
        }
    }
    
    // Artık sonucu döndürüyor (return Float?)
    func calculateAddition(number1: Float, number2: Float) -> Float? {
        guard let device = device,
              let commandQueue = commandQueue,
              let pipelineState = additionPipelineState else {
            return nil
        }
        
        // 1. Girdileri hazırla
        var inputs: [Float] = [number1, number2]
        var output: Float = 0
        
        // 2. Buffer oluştur
        // Girdi Buffer'ı (2 sayı = 8 byte)
        let inputBuffer = device.makeBuffer(bytes: &inputs, length: MemoryLayout<Float>.size * 2, options: [])
        // Çıktı Buffer'ı (1 sayı = 4 byte)
        let outputBuffer = device.makeBuffer(bytes: &output, length: MemoryLayout<Float>.size, options: [])
        
        // 3. Komutları hazırla
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeComputeCommandEncoder() else {
            return nil
        }
        
        encoder.setComputePipelineState(pipelineState)
        encoder.setBuffer(inputBuffer, offset: 0, index: 0)
        encoder.setBuffer(outputBuffer, offset: 0, index: 1)
        
        // Tek bir işlem yapacağımız için 1x1x1 thread kullanıyoruz
        let gridSize = MTLSize(width: 1, height: 1, depth: 1)
        let threadGroupSize = MTLSize(width: 1, height: 1, depth: 1)
        encoder.dispatchThreadgroups(gridSize, threadsPerThreadgroup: threadGroupSize)
        
        encoder.endEncoding()
        
        // 4. Çalıştır ve bekle
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        // 5. Sonucu oku ve döndür
        let result = outputBuffer?.contents().load(as: Float.self)
        return result
    }
}
