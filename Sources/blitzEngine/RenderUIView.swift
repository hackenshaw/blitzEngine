//
//  SwiftUIView.swift
//  
//
//  Created by Medhat Riad on 19/01/2021.
//

import SwiftUI

public final class RenderUIView: UIViewRepresentable {

    private var uiView: UIView!
    private var renderer: Renderer!
    private var examples: Examples!
    
    public init(){
        
    }
    
    /**
     makeUIView sets up the view
            
     */
    public func makeUIView(context: Context) -> some UIView {
        uiView = renderer.getUIView()
        
        
        return uiView
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        
        
    }
    
    /**
     set up the view delegate
     */
    public func makeCoordinator() -> Renderer? {
        //TODO: move this code into app
        guard let coordinator = Renderer(name: "MetalRenderer") else {
          print("Renderer cannot be initialized")
          return nil
        }
        renderer = coordinator
        examples = Examples(renderer: renderer)
        
        examples.createSceneSingleCube(textured: false)
        return renderer
    }
    
    
   
}

struct RenderUIView_Previews: PreviewProvider {
    static var previews: some View {
        RenderUIView()
    }
}
