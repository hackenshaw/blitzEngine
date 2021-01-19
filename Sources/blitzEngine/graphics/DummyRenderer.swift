//
//  DummyRenderer.swift
//  
//
//  Created by Medhat Riad on 19/01/2021.
//

import MetalKit

public class DummyRenderer : NSObject, MTKViewDelegate {
    var parent: RenderUIView
    var metalDevice: MTLDevice!
    var metalCommandQueue: MTLCommandQueue!
    
    var pipelineState: MTLRenderPipelineState?
    var vertexBuffer: MTLBuffer?
    
    var vertices: [Float] = [
        0.0 , 0.5 , 0.0,
        -0.5, -0.5, 0.0,
        0.5 , -0.5, 0.0
    ]
    
    
    
    public init(_ parent: RenderUIView) {
        self.parent = parent
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            self.metalDevice = metalDevice
        }
        self.metalCommandQueue = metalDevice.makeCommandQueue()!
        
        super.init()
        
        buildModel()
        buildPipelineState()
    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }

    public func draw(in view: MTKView) {
        // Get the current drawable and descriptor
        guard let drawable = view.currentDrawable,
              let pipelineState = pipelineState else {
            return
        }
        
        // Create a buffer from the commandQueue
        let commandBuffer = metalCommandQueue.makeCommandBuffer()
        
        // make the render pass descriptor
        let rpd = view.currentRenderPassDescriptor
        rpd?.colorAttachments[0].clearColor = Colors.background
        rpd?.colorAttachments[0].loadAction = .clear
        rpd?.colorAttachments[0].storeAction = .store
        
        // make encoder
        let re = commandBuffer?.makeRenderCommandEncoder(descriptor: rpd!)
        
        re?.setRenderPipelineState(pipelineState)
        re?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        re?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
        
        re?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
    private func buildModel() {
        vertexBuffer = metalDevice.makeBuffer(bytes: vertices,
                                              length: vertices.count * MemoryLayout<Float>.size,
                                              options: [])
    }
    
    private func buildPipelineState() {
        let library = metalDevice.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertex_shader")
        let fragmentFunction = library?.makeFunction(name: "fragment_shader")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            pipelineState =  try metalDevice.makeRenderPipelineState(descriptor: pipelineDescriptor)
        }
        catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
}
