import Foundation
import simd
import MetalKit


final class Examples {
  private let renderer: Renderer

  init(renderer: Renderer) {
    self.renderer = renderer
    print("renderer ready")
  }
    
    func createSceneSingleCube(textured: Bool) {
        print("creating cube scene")
      renderer.scene.root.clearAllChildren()

      let dimension: Float = 3.0

      // Define the 3D vertices and colors for the vertices
      guard let cubeMesh = Primitives.cuboid(
        renderer: renderer,
        width: dimension,
        height: dimension,
        length: dimension,
        topColor: UIColor(red: 1, green: 0.6, blue: 0.6, alpha: 1.0).cgColor,
        rightColor: UIColor(red: 0.6, green: 1, blue: 0.6, alpha: 1.0).cgColor,
        bottomColor: UIColor(red: 1, green: 0.8, blue: 0.6, alpha: 1.0).cgColor,
        leftColor: UIColor(red: 0.6, green: 0.6, blue: 1, alpha: 1.0).cgColor,
        frontColor: UIColor(red: 1, green: 1, blue: 0.6, alpha: 1.0).cgColor,
        backColor: UIColor(red: 0.8, green: 0.6, blue: 1, alpha: 1.0).cgColor
      ) else {
        print("Failed to create the cuboid mesh")
        return
      }

      var texture: Texture?
      if textured {
        guard let metalTexture = Texture.loadMetalTexture(device: renderer.device, named: "bricks") else {
          return
        }

        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.normalizedCoordinates = true
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.mipFilter = .linear
        guard let sampler = renderer.device.makeSamplerState(descriptor: samplerDescriptor) else {
          return
        }

        texture = Texture(mtlTexture: metalTexture, samplerState: sampler)
      }

      let material = Material.createBasic(renderer: renderer, texture0: texture)

      cubeMesh.material = material
      let node = Node(mesh: cubeMesh)
      node.update = { (time: Time, node: Node) in
        node.orientation *= Quaternion(
          angle: Math.toRadians(30.0) * Float(time.updateTime),
          axis: [0.5, 1, -1]
        )
        
      }
      renderer.scene.root.addChild(node)
    }
}
