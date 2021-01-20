import Foundation
import simd
import MetalKit
import UIKit

final class Examples {
  private let renderer: Renderer

  init(renderer: Renderer) {
    self.renderer = renderer
  }



  func createPointCloud() {
    renderer.scene.root.clearAllChildren()
  }

 



  func createSceneBunny() {
    // Stanford Bunny data from: https://casual-effects.com/data/

    renderer.scene.root.clearAllChildren()

    guard let url = Bundle.main.url(forResource: "bunny", withExtension: "obj") else {
      return
    }

    let bufferIndex = Renderer.firstFreeVertexBufferIndex

    // position
    let vertexDescriptor = MDLVertexDescriptor()
    vertexDescriptor.attributes[0] = MDLVertexAttribute(
      name: MDLVertexAttributePosition,
      format: .float3,
      offset: 0,
      bufferIndex: bufferIndex
    )

    // normal
    vertexDescriptor.attributes[1] = MDLVertexAttribute(
      name: MDLVertexAttributeNormal,
      format: .float3,
      offset: MemoryLayout<Float>.size * 3,
      bufferIndex: bufferIndex
    )

    // color
    vertexDescriptor.attributes[2] = MDLVertexAttribute(
      name: MDLVertexAttributeColor,
      format: .float4,
      offset: MemoryLayout<Float>.size * 6,
      bufferIndex: bufferIndex
    )

    // texture coords
    vertexDescriptor.attributes[3] = MDLVertexAttribute(
      name: MDLVertexAttributeTextureCoordinate,
      format: .float2,
      offset: MemoryLayout<Float>.size * 10,
      bufferIndex: bufferIndex
    )
    vertexDescriptor.layouts[bufferIndex] = MDLVertexBufferLayout(stride: MemoryLayout<Float>.size * 12)

    let metalVertexDescriptor = MTKMetalVertexDescriptorFromModelIO(vertexDescriptor)!

    let allocator = MTKMeshBufferAllocator(device: renderer.device)
    let asset = MDLAsset(url: url, vertexDescriptor: vertexDescriptor, bufferAllocator: allocator)

    var meshes = [MTKMesh]()
    do {
      (_, meshes) = try MTKMesh.newMeshes(asset: asset, device: renderer.device)
    } catch {
      print("Could not load meshes from model")
    }

    guard let bunnyMetalTexture = Texture.loadMetalTexture(device: renderer.device, named: "bricks") else {
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

    let bunnyTexture = Texture(mtlTexture: bunnyMetalTexture, samplerState: sampler)

    let bunnyMaterial = Material(
      renderer: renderer,
      vertexName: "basic_vertex",
      fragmentName: "texture_fragment",
      vertexDescriptor: metalVertexDescriptor,
      texture0: bunnyTexture,
      texture1: nil
    )

    let bunnyMesh = Mesh(mtkMesh: meshes[0])
    bunnyMesh.material = bunnyMaterial

    let bunnyNode = Node(mesh: bunnyMesh)
    bunnyNode.scale = [2.5, 2.5, 2.5]
    bunnyNode.position.y = -2
    bunnyNode.update = { (time: Time, node: Node) in
      node.orientation *= Quaternion(angle: Math.toRadians(60.0) * Float(time.updateTime), axis: [0, 1, 0])
    }
    renderer.scene.root.addChild(bunnyNode)
  }
}
