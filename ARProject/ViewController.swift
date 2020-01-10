//
//  ViewController.swift
//  ARProject
//
//  Created by Mojave on 05/01/20.
//  Copyright © 2020 Mojave. All rights reserved.
//

import UIKit
import ARKit
final class ViewController: UIViewController {
    
    @IBOutlet weak var arscnView: ARSCNView!
    
    // for ARPlane
    private var planeGeometry : SCNPlane!
    
    
    
    // for storing all records of ARArchors
    private var anchors = [ARAnchor]()
    
    private var lipstickModel : SCNNode?{
        guard let lipstickModel = loadModel(modelName: "lipsticks2.dae") else {return nil}
        
        lipstickModel.transform = SCNMatrix4MakeRotation(Float.pi / 2, 1, 0, 0)
        
        lipstickModel.name = "Lipstick"
        
        return lipstickModel
    }
    
    private var lipstickBottomModel : SCNNode?{
        guard let lipstickModel = loadModel(modelName: "LIPSTICK_BOTTOM_PART.dae") else {return nil}
        
        lipstickModel.transform = SCNMatrix4MakeRotation(Float.pi / 2, 1, 0, 0)
        
        lipstickModel.name = "lipstickBottomModel"
        
        return lipstickModel
    }
    
    private var lipstickMiddleModel : SCNNode?{
        guard let lipstickModel = loadModel(modelName: "LIPSTICK_MIDDLE_PART.dae") else {return nil}
        
        lipstickModel.transform = SCNMatrix4MakeRotation(Float.pi / 2, 1, 0, 0)
        
        lipstickModel.name = "lipstickMiddleModel"
        
        return lipstickModel
    }
    
    private var lipstickUpperModel : SCNNode?{
        guard let lipstickModel = loadModel(modelName: "LIPSTICK_UPPER_PART.dae") else {return nil}
        
        lipstickModel.transform = SCNMatrix4MakeRotation(Float.pi / 2, 1, 0, 0)
        
        lipstickModel.name = "lipstickUpperModel"
        
        return lipstickModel
    }
    
    private var planeNode : SCNNode!
    
    private var isTopCollected : Bool = false
    
    private var isMiddleCollected : Bool = false
    
    private var isBottomCollected : Bool = false
    
    private var iscollectedAll : Bool = false{
        didSet{
                print("All collected")
            allCollected()
        }
    }
    
    let scene = SCNScene()
    
    
    private func allCollected(){
        for child in planeNode.childNodes{
            child.removeFromParentNode()
        }
        
        DispatchQueue.main.sync {
            planeNode.addChildNode(lipstickModel!)
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Set view's delegate
        arscnView.delegate = self
        
        // show statistics such as fps & timing
        arscnView.showsStatistics = true
        
        
        
        //setting Sceneview Scene
        arscnView.scene = scene
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        
        // Create a Session Configuration
        let configuration = ARWorldTrackingConfiguration()
        
        //for plane detection
        configuration.planeDetection = .horizontal
        
        // for light estimation
        configuration.isLightEstimationEnabled = true
        
        //run the view's session
        arscnView.session.run(configuration)
        //   sceneView.session.run(configuration, options: .resetTracking)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        arscnView.session.pause()
    }
    
    private func scatterLipstickParts(node : SCNNode ){
        
        DispatchQueue.main.async {
            let position : SCNVector3 = SCNVector3(Float.random(in: -1..<1), Float.random(in: -1..<1), Float.random(in: 0.1..<0.5))
            
            node.runAction(SCNAction.move(to: position, duration: 3))
        }
        
        
    }
    
    
}



//MARK:- AR
extension ViewController : ARSCNViewDelegate{
    
    // called when we are finding an anchor or ARKit finds an anchor  (i.e. when a new plane is detected an new anchor is added)
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        // print("found new anchor")
        var node : SCNNode?
        
        // checking is found anchor is an ARPlane Anchor
        if let planeAnchor = anchor as? ARPlaneAnchor,anchors.isEmpty{
            
            DispatchQueue.main.sync { [weak self] in
                guard let `self` = self else { return }
                
                //setting an SCNNode()
                node = SCNNode()
                
                // creating an Plane (extent == > length) //cmd+extent for summary
                self.planeGeometry = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
                
                
                // apply a color to Plane
                self.planeGeometry.firstMaterial?.diffuse.contents = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
                
                //creating a Planenode with Planegeometry
                let planeNode = SCNNode(geometry: self.planeGeometry)
                
                // since we are using scenekit here for plane our plane is vertical we declare y=0 and will rotate the planeNode around x axis with 90 degree
                planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
                
                
                //MARK:- Rotating a Plane x =1 as we wan to rotate only x
                planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
                
                node?.addChildNode(planeNode)
                
                if let lipstickMdl = lipstickModel{
                    
                    planeNode.addChildNode(lipstickMdl)
                    
                    lipstickMdl.opacity  = 0.75
                    
                    lipstickMdl.runAction(SCNAction.fadeOpacity(to: 1, duration: 3)) {
                        lipstickMdl.removeFromParentNode()
                        
                        
                        DispatchQueue.main.sync {
                            if let lipstickBottomMl = self.lipstickBottomModel,let lipstickUpperMl = self.lipstickUpperModel,let lipstickMiddleMl = self.lipstickMiddleModel{
                                
                                
                                planeNode.addChildNode(lipstickBottomMl)
                                
                                
                                
                                lipstickBottomMl.position = SCNVector3(0, 0, 0)
                                
                                
                                
                                
                                planeNode.addChildNode(lipstickMiddleMl)
                                
                                lipstickMiddleMl.position = SCNVector3(0, 0, 0.03)
                                
                                planeNode.addChildNode(lipstickUpperMl)
                                
                                lipstickUpperMl.position = SCNVector3(0, 0, 0.06)
                                
                                self.scatterLipstickParts(node: lipstickBottomMl)
                                
                                self.scatterLipstickParts(node: lipstickMiddleMl)
                                
                                self.scatterLipstickParts(node: lipstickUpperMl)
                                
                                self.planeNode = planeNode
                                
                            }
                        }
                       
                    }
                }
                self.anchors.append(planeAnchor)
            }
            
        }
        return node
    }
    
    private func videoNode() -> SCNNode{
        
        
        let url = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
        //let videoItem = AVPlayerItem(url: URL(fileURLWithPath: fileUrlString))
        
        let videoItem = AVPlayerItem(url: url!)
        
        let player = AVPlayer(playerItem: videoItem)
        //initialize video node with avplayer
        let videoNode = SKVideoNode(avPlayer: player)
        
        
        player.play()
        // add observer when our player.currentItem finishes player, then start playing from the beginning
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil) { (notification) in
            player.seek(to: CMTime.zero)
            player.play()
            print("Looping Video")
        }
        
        // set the size (just a rough one will do)
        let videoScene = SKScene(size: CGSize(width: 480, height: 360))
        // center our video to the size of our video scene
        videoNode.position = CGPoint(x: videoScene.size.width / 2, y: videoScene.size.height / 2)
        // invert our video so it does not look upside down
        videoNode.yScale = -1.0
        // add the video to our scene
        videoScene.addChild(videoNode)
        // create a plan that has the same real world height and width as our detected image
        let plane = SCNPlane(width: 0.2, height: 0.1)
        // set the first materials content to be our video scene
        plane.firstMaterial?.diffuse.contents = videoScene
        // create a node out of the plane
        let planeNode = SCNNode(geometry: plane)
        
        
        
        
        planeNode.position = SCNVector3(x: 0, y: 0.2, z: 0)
        // since the created node will be vertical, rotate it along the x axis to have it be horizontal or parallel to our detected image
        // planeNode.eulerAngles.x = Float.pi / 2
        // finally add the plane node (which contains the video node) to the added node
        // node.addChildNode(planeNode)
        return planeNode
    }
    
    
    
    
    
    
    private func loadModel(modelName : String) -> SCNNode?{
        
        
        guard let virtualObjectScene = SCNScene(named: modelName) else {return nil}
        
        let wrapperNode = SCNNode()
        
        for child in virtualObjectScene.rootNode.childNodes{
            wrapperNode.addChildNode(child)
        }
        
        return wrapperNode
    }
    
    
    private func removeNode(name : String){
        
        if let node = (planeNode.childNodes.filter{$0.name == name}).first{
            
            switch node.name{
            case lipstickModel?.name:
                print("lipstick")
            case lipstickBottomModel?.name:
                print("lipstickBottomModel")
                 isBottomCollected = true
                node.runAction(SCNAction.move(to: SCNVector3(0, 0, 0), duration: 3)) {
                    if self.isBottomCollected && self.isMiddleCollected && self.isTopCollected {
                        if !self.iscollectedAll{
                            self.iscollectedAll = true
                        }
                    }
                }

                
            case lipstickMiddleModel?.name:
                print("lipstickMiddleModel")
                isMiddleCollected = true
                node.runAction(SCNAction.move(to: SCNVector3(0, 0, 0.03), duration: 3)) {
                    if self.isBottomCollected && self.isMiddleCollected && self.isTopCollected {
                        if !self.iscollectedAll{
                            self.iscollectedAll = true
                        }
                    }
                }
                // removeNode(name: lipstickMiddleModel?.name ?? "")
                
            case lipstickUpperModel?.name:
                print("lipstickUpperModel")
                
                isTopCollected = true
                node.runAction(SCNAction.move(to: SCNVector3(0, 0, 0.06), duration: 3)) {
                    if self.isBottomCollected && self.isMiddleCollected && self.isTopCollected {
                        if !self.iscollectedAll{
                            self.iscollectedAll = true
                        }
                    }
                }
                //removeNode(name: lipstickUpperModel?.name ?? "")
                
            default:
                print("default")
                
            }
            
           // (planeNode.childNodes.filter{$0.name == name}).first?.removeFromParentNode()
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        if(touch.view == self.arscnView){
            print("touch working")
            let viewTouchLocation:CGPoint = touch.location(in: arscnView)
            guard let result = arscnView.hitTest(viewTouchLocation, options: nil).first else {
                return
            }
            //            if let lipstickModel = lipstickModel, lipstickModel.name == result.node.name {
            //
            //                print("match")
            //
            //               lipstickModel.addChildNode(videoNode())
            //
            //
            //
            //            }
            //            else{
            //                print("WTH man")
            //            }
            
            switch result.node.name{
            case lipstickModel?.name:
                print("lipstick")
            case lipstickBottomModel?.name:
                print("lipstickBottomModel")
                removeNode(name: lipstickBottomModel?.name ?? "")
            case lipstickMiddleModel?.name:
                print("lipstickMiddleModel")
                removeNode(name: lipstickMiddleModel?.name ?? "")
                
            case lipstickUpperModel?.name:
                print("lipstickUpperModel")
                removeNode(name: lipstickUpperModel?.name ?? "")
                
            default:
                print("default")
                
            }
            
            
        }
        
    }
    
}



