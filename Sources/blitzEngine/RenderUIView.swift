//
//  SwiftUIView.swift
//  
//
//  Created by Medhat Riad on 19/01/2021.
//

import SwiftUI
import MetalKit

enum Colors {
    static let background = MTLClearColorMake(0.0, 0.4, 0.21, 1.0)
}

public struct RenderUIView: UIViewRepresentable {

    let mtkView = MTKView()
    
    public init(){
        
    }
    
    /**
     makeUIView sets up the view
            
     */
    public func makeUIView(context: Context) -> some UIView {
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        mtkView.enableSetNeedsDisplay = true
                
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            mtkView.device = metalDevice
        }
        
        mtkView.framebufferOnly = false
        mtkView.clearColor = Colors.background
        mtkView.drawableSize = mtkView.frame.size
        mtkView.enableSetNeedsDisplay = true
        
        return mtkView
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    /**
     set up the view delegate
     */
    public func makeCoordinator() -> DummyRenderer {
        DummyRenderer(self)
    }
    
    
   
}

struct RenderUIView_Previews: PreviewProvider {
    static var previews: some View {
        RenderUIView()
    }
}
