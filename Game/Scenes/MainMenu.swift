//
//  MainMenu.swift
//  Game
//
//  Created by Nitrotech Asia on 05/04/2024.
//

import SpriteKit

class MainMenu: SKScene {
    var groundNodes: [SKSpriteNode] = []
    var containerNode: SKSpriteNode!

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        createBG()
        createGround()
        setupNodes()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let node = atPoint(touch.location(in: self))
        if node.name == "Play" {
           let scene = GameScene(size: size)
            scene.scaleMode = scaleMode
            view!.presentScene(scene, transition: .doorsOpenVertical(withDuration: 0.3))
        } else if node.name == "Highscore" {
            setupPanel()
        } else if node.name == "Setting" {
            setupSetting()
        } else if node.name == "Container" {
            containerNode.removeFromParent()
        } else if node.name == "Panel"{
            containerNode.removeFromParent()
        } else if node.name == "music" {
            let node = node as! SKSpriteNode
            let isEnable = !SKTAudio.musicEnable
            SKTAudio.musicEnable = isEnable
            node.texture = SKTexture(imageNamed: isEnable ? "musicOn" : "musicOff")
        } else if node.name == "effect" {
            let node = node as! SKSpriteNode
            let isEnable = !SKTAudio.effectEnable
            SKTAudio.effectEnable = isEnable
            node.texture = SKTexture(imageNamed: isEnable ? "effectOn" : "effectOff")
        }
    }

    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        moveGround()
    }
}

extension MainMenu {

    func moveGround() {
        for node in groundNodes {
            node.position.x -= 5
            if node.position.x <= -node.size.width {
                node.position.x += node.size.width * 3
            }
        }
    }

    func createBG() {
        for i in 0...2 {
            let bg = SKSpriteNode(imageNamed: "background")
            bg.name = "BG"
            bg.anchorPoint = .zero
            bg.position = CGPoint(x: CGFloat(i)*bg.frame.width, y: 0.0)
            bg.zPosition = -1
            addChild(bg)
        }
    }

    func createGround() {
        for i in 0...2 {
            let ground = SKSpriteNode(imageNamed: "ground")
            ground.name = "Ground"
            ground.anchorPoint = .zero
            ground.zPosition = 1.0
            ground.position = CGPoint(x: CGFloat(i) * ground.size.width, y: 0.0)
            ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
            ground.physicsBody?.isDynamic = false
            ground.physicsBody?.affectedByGravity = false
            ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
            addChild(ground)
            
            groundNodes.append(ground)
        }
    }

    func setupNodes() {
        let play = SKSpriteNode(imageNamed: "play")
        play.name = "Play"
        play.setScale(0.85)
        play.zPosition = 10.0
        play.position = CGPoint(x: size.width/2, y: size.height/2 + 200)
        addChild(play)
        let highscore = SKSpriteNode(imageNamed: "highscore")
        highscore.name = "Highscore"
        highscore.setScale(0.85)
        highscore.zPosition = 10.0
        highscore.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(highscore)
        let setting = SKSpriteNode(imageNamed: "setting")
        setting.name = "Setting"
        setting.setScale(0.85)
        setting.zPosition = 10.0
        setting.position = CGPoint(x: size.width/2, y: size.height/2 - 200)
        addChild(setting)
    }

    func setupPanel() {
        setupContainer()
        let panel = SKSpriteNode(imageNamed: "panel")
        panel.name = "Panel"
        panel.setScale(1.5)
        panel.zPosition = 20.0
        panel.position = .zero
        containerNode.addChild(panel)

        let x = -panel.frame.width/2 + 250
        let hightScoreLbl = SKLabelNode(fontNamed: "Krungthep")
        hightScoreLbl.text = "Hightscore: \(ScoreGenerator.shared.getHightScore())"
        hightScoreLbl.horizontalAlignmentMode = .left
        hightScoreLbl.fontSize = 80.0
        hightScoreLbl.zPosition = 35.0
        hightScoreLbl.position = CGPoint(x: x, y: hightScoreLbl.frame.height/2 - 30)
        panel.addChild(hightScoreLbl)

        let scoreLbl = SKLabelNode(fontNamed: "Krungthep")
        scoreLbl.text = "Score: \(ScoreGenerator.shared.getHightScore())"
        scoreLbl.horizontalAlignmentMode = .left
        scoreLbl.fontSize = 80.0
        scoreLbl.zPosition = 35.0
        scoreLbl.position = CGPoint(x: x, y: -scoreLbl.frame.height - 30)
        panel.addChild(scoreLbl)
    }

    func setupContainer() {
        containerNode = SKSpriteNode()
        containerNode.name = "conainer"
        containerNode.zPosition = 15.0
        containerNode.color = .clear
        containerNode.size = size
        containerNode.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(containerNode)
    }

    func setupSetting() {
        setupContainer()

        let panel = SKSpriteNode(imageNamed: "panel")
        panel.name = "Panel"
        panel.setScale(1.5)
        panel.zPosition = 20.0
        panel.position = .zero
        containerNode.addChild(panel)

        let music = SKSpriteNode(imageNamed: SKTAudio.musicEnable ? "musicOn" : "musicOff")
        music.name = "music"
        music.setScale(0.7)
        music.zPosition = 25.0
        music.position = CGPoint(x: -music.frame.width - 50, y: 0.0)
        panel.addChild(music)
        
        let effect = SKSpriteNode(imageNamed: SKTAudio.effectEnable ? "effectOn" : "effectOff")
        effect.name = "effect"
        effect.setScale(0.7)
        effect.zPosition = 20.0
        effect.position = .zero
        effect.position = CGPoint(x: music.frame.width + 50, y: 0.0)
        panel.addChild(effect)
    }
}
