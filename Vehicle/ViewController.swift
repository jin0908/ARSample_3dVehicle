//
//  ViewController.swift
//  FloorIsLava
//
//  Created by Hyeongjin Um on 9/23/17.
//  Copyright © 2017 Hyeongjin Um. All rights reserved.


import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        sceneView.autoenablesDefaultLighting = true
        
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        
        // horizontal plane detection.
        configuration.planeDetection = .horizontal
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func createConcrete(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let concreteNode = SCNNode(geometry: SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z)))
        concreteNode.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "concrete")
        //cover image(texture) both side
        concreteNode.geometry?.firstMaterial?.isDoubleSided = true
        
        // lovaNode should be same position relatively with ARPlaneAnchor
        concreteNode.position = SCNVector3(planeAnchor.center.x,planeAnchor.center.y,planeAnchor.center.z)
        concreteNode.eulerAngles = SCNVector3(-90*CGFloat.pi/180,0,0)
        
        //fixed body.
        //collide 충돌하다.
        let staticBody = SCNPhysicsBody.static()
        concreteNode.physicsBody = staticBody
        return concreteNode
        
        //extent represents the width and height of a deteced horizontal
    }

    // MARK: - ARSCNViewDelegate
    
    
 // this delegate function checks if an AR anchor was added to the sceneView.
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // if it finds one, it adds planeanchor to that one
        //position /orientation / size of the surface
        
        //check if anchor added as a arplaneanchor.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let lavaNode = createConcrete(planeAnchor: planeAnchor)
        //node is default detected horizontal surface
        node.addChildNode(lavaNode)
        
        print("New flat surface detected, new ARPlaneAnchor added")
    }
    
    //when updated
    // when the floor is changed / updated.
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
        let lavaNode = createConcrete(planeAnchor: planeAnchor)
        node.addChildNode(lavaNode)
        
        print("updating floor's anchor...")
    }
    
    // removes unnecessary ( excessive ) ARPlaneAnchor
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let _ = anchor as? ARPlaneAnchor else { return }
        //when it remove node, remove childNode together.
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
         print("updating floor's anchor...")
    }
    
    
    @IBAction func addCar(_ sender: UIButton) {
        
        // get camera view.
        guard let pointOfView = sceneView.pointOfView else { return }
        let transform = pointOfView.transform
        // get orientation and location. ( orientation value should be - to work correctly)
        let orientation = SCNVector3(-transform.m31,-transform.m32,-transform.m33)
        let location = SCNVector3(transform.m41,transform.m42,transform.m43)
        let currentPositionOfCamera = orientation + location
        
        let box = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
        box.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        box.position = currentPositionOfCamera
        
        
        // to drop an object on the plane, we need gravity.
        // Physics body.
        // physical body.
        let body = SCNPhysicsBody(type: SCNPhysicsBodyType.dynamic, shape: SCNPhysicsShape(node: box, options: [SCNPhysicsShape.Option.keepAsCompound: true]))
        box.physicsBody = body
    
        self.sceneView.scene.rootNode.addChildNode(box)
    }
    
    
    
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x+right.x, left.y+right.y, left.z+right.z)
}
