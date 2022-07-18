//
//  ViewController.swift
//  ARJump
//
//  Created by 闫润邦 on 2022/7/15.
//

import UIKit
import SceneKit
import ARKit
import AVFoundation

enum JumpDir: Int {
    case x
    case z
}

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    //pressBtn: Detecting the Duration of Press, in order to
    //          calculate the distance for the person to travel
    let pressBtn = UIButton()
    
    //tapRecognizer: For HitTest(RayCast), to select a point to start game
    let tapRecognizer = UITapGestureRecognizer()
    
    //startTime: Record the timestamp when press begins
    var startTime: Double!
    
    //started: Marks whether game has started
    var started = false
    
    //jumpDir: Marks the direction for jumping
    var jumpDir: JumpDir!
    
    //nowPlatform: The current platform on which the person is standing
    var nowPlatform: Platform!
    
    //nxtPlatform: The next platform on which the person is to stand
    var nxtPlatform: Platform!
    
    //personPlatform: The platform representing the person ( just see it as a platform or so )
    var personPlatform: Platform!

    var bgmPlayer: AVAudioPlayer!
    var pressPlayer: AVAudioPlayer!
    var failPlayer: AVAudioPlayer!
    var fallPlayer: AVAudioPlayer!
    
    var materialFrom: SCNMaterial!
    var score = 0
    var currentScore: Int {
        get {
            return score
        }
        
        set {
            score = newValue
            scoreLabel.text = "当前分数： " + String(score)
        }
    }
    var highestScore = 0
    let storage = Storage()
    let historyBtn = UIButton(type: .system)
    let scoreLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTapRecognizer()
        configureSceneView()
        configureScene()
        configureHistoryBtn()
        configurePressBtn()
        configureScoreLabel()
        configurePlayers()
        
    }
    
    //run session
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        //detect horizontal planes
        configuration.planeDetection = [.horizontal]
        sceneView.session.run(configuration)
    }
    
    //pause session
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func configurePlayers() {
        var url = Bundle.main.url(forResource: "failsound", withExtension: "mp3")!
        failPlayer = try! AVAudioPlayer(contentsOf: url)
        
        url = Bundle.main.url(forResource: "fallsound", withExtension: "mp3")!
        fallPlayer = try! AVAudioPlayer(contentsOf: url)
        
        url = Bundle.main.url(forResource: "presssound", withExtension: "mp3")!
        pressPlayer = try! AVAudioPlayer(contentsOf: url)
        
        url = Bundle.main.url(forResource: "Graze the Roof", withExtension: "mp3")!
        bgmPlayer = try! AVAudioPlayer(contentsOf: url)
        bgmPlayer.numberOfLoops = -1
        bgmPlayer.play()
    }
}


//Configuration Functions
extension ViewController {
    func configureSceneView() {
        sceneView.delegate = self
//        sceneView.debugOptions = [.showFeaturePoints]
        sceneView.showsStatistics = false
        sceneView.isUserInteractionEnabled = true

    }
    
    func configureScene() {

        let url = Bundle.main.url(forResource: "test", withExtension: "scn", subdirectory: "art.scnassets")!
        let scn = try! SCNScene(url: url)
        sceneView.scene = scn

        
        let mUrl = Bundle.main.url(forResource: "ship", withExtension: "scn", subdirectory: "art.scnassets")!
        let mScn = try! SCNScene(url: mUrl)
        let boxNode = mScn.rootNode.childNode(withName: "box", recursively: true)!
        materialFrom = boxNode.geometry!.materials.first!
    }
    
    func configureTapRecognizer() {
        sceneView.addGestureRecognizer(tapRecognizer)
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        tapRecognizer.addTarget(self, action: #selector(selectPlane))
    }
    
    func configurePressBtn() {
        sceneView.addSubview(pressBtn)
        pressBtn.translatesAutoresizingMaskIntoConstraints = false
        pressBtn.backgroundColor = .clear
        pressBtn.isHidden = true
        pressBtn.addTarget(self, action: #selector(touchDown), for: .touchDown)
        pressBtn.addTarget(self, action: #selector(touchUp), for: .touchUpInside)
        
        pressBtn.topAnchor.constraint(equalTo: historyBtn.bottomAnchor).isActive = true
        pressBtn.leadingAnchor.constraint(equalTo: sceneView.leadingAnchor).isActive = true
        pressBtn.trailingAnchor.constraint(equalTo: sceneView.trailingAnchor).isActive = true
        pressBtn.bottomAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    func configureHistoryBtn() {
        historyBtn.setTitle("排行榜", for: .normal)
        historyBtn.translatesAutoresizingMaskIntoConstraints = false
        historyBtn.addTarget(self, action: #selector(showHistory), for: .touchUpInside)
        historyBtn.backgroundColor = .systemBlue
        historyBtn.setTitleColor(.white, for: .normal)
        sceneView.addSubview(historyBtn)
        
        
        historyBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        historyBtn.heightAnchor.constraint(equalToConstant: 60).isActive = true
        historyBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        historyBtn.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
    }
    
    @objc func showHistory() {
        let historyVC = HistoryViewController()
        historyVC.storage = storage
        navigationController?.pushViewController(historyVC, animated: true)
    }
    
    func configureScoreLabel() {
        scoreLabel.text = "当前分数: " + String(currentScore)
        scoreLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        scoreLabel.textAlignment = .center
        sceneView.addSubview(scoreLabel)
        
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.topAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.topAnchor).isActive = true
        scoreLabel.leadingAnchor.constraint(equalTo: sceneView.leadingAnchor).isActive = true
        scoreLabel.trailingAnchor.constraint(equalTo: historyBtn.leadingAnchor).isActive = true
        scoreLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
}


//ARSCNView Delegate
extension ViewController: ARSCNViewDelegate {
    //Detected a Plane
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if started {
            return
        }
        if anchor is ARPlaneAnchor {
            guard let planeAchor = anchor as? ARPlaneAnchor else {
                return
            }
            guard let meshGeometry = ARSCNPlaneGeometry(device: sceneView.device!) else {
                fatalError()
            }
                
            meshGeometry.update(from: planeAchor.geometry)
            let meshNode = SCNNode(geometry: meshGeometry)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.purple
            meshNode.geometry?.materials = [material]
            meshNode.opacity = 0.6
                
            node.addChildNode(meshNode)
            let light = SCNLight()
            light.type = .ambient
            light.color = UIColor.white
            
        }
        
    }
    
    //Update Plane
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if started {
            return
        }
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            print(anchor.transform.columns.3.y)
            return
        }
        guard let meshNode = node.childNodes.first else {
            return
        }
        guard let meshGeometry = meshNode.geometry as? ARSCNPlaneGeometry else {
            return
        }

        meshGeometry.update(from: planeAnchor.geometry)
    }
}


