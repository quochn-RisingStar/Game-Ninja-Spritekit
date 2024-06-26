//
//  GameOverScene.swift
//  Game
//
//  Created by Nitrotech Asia on 05/04/2024.
//

import SpriteKit

class GameOverScene: SKScene {
    var ground: SKSpriteNode!
    var containerNode: SKSpriteNode!

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        createBG()
        createGround()
        createGameOver()
        run(.sequence([.wait(forDuration: 3.3),
                       .run {
                           let scene = MainMenu(size: self.size)
                           scene.scaleMode = self.scaleMode
                           self.view!.presentScene(scene, transition: .doorsCloseVertical(withDuration: 0.5))
                       }]))
    }

    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        moveNodes()
    }
}

private extension GameOverScene {
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
            ground.position = CGPoint(x: -CGFloat(i)*ground.frame.width, y: AppDelegate.shared.isX ? 100.0 : 0.0)
            ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
            ground.physicsBody?.isDynamic = false
            ground.physicsBody?.affectedByGravity = false
            ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
            addChild(ground)
        }
    }

    func moveNodes() {
        enumerateChildNodes(withName: "BG") { (node, _) in
            let node = node as! SKSpriteNode
            node.position.x -= 8.0
            if node.position.x < -self.frame.width {
                node.position.x += node.frame.width*2
            }
        }
    
        enumerateChildNodes(withName: "Ground") { (node, _) in
            let node = node as! SKSpriteNode
            node.position.x -= 8.0
            if node.position.x < -self.frame.width {
                node.position.x += node.frame.width*2
            }
        }
    }

    func createGameOver() {
        let gameOver = SKSpriteNode(imageNamed: "gameOver")
        gameOver.name = "GameOver"
        gameOver.zPosition = 10
        gameOver.position = CGPoint(x: size.width/2, y: size.height/2 + gameOver.frame.height/2)
        addChild(gameOver)
        gameOver.setScale(0.7)
        let min = SKAction.scale(to: 1.1, duration: 0.3)
        let max = SKAction.scale(to: 0.7, duration: 0.3)
        let fullScale = SKAction.sequence([max, min])
        gameOver.run(.repeatForever(fullScale))
    }
}
