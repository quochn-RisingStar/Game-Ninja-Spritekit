//
//  GameScene.swift
//  Game
//
//  Created by Nitrotech Asia on 04/04/2024.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var ground: SKSpriteNode!
    var player: SKSpriteNode!
    var cameraNode = SKCameraNode()
    var objects: [SKSpriteNode] = []
    var coin: SKSpriteNode!
    var pauseNode: SKSpriteNode!
    var containerNode = SKNode()

    var cameraMovePointPerSecond = 450.0
    var lastUpdateTime = 0.0
    var dt: TimeInterval = 0.0
    var isTime = CGFloat(3.0)
    var onGround = true
    var gravity: CGFloat = 0.6
    var velocityY:CGFloat = 0
    var playerPosY: CGFloat = 0.0
    var numberScore: Int = 0
    var gameOver = false
    var life: Int = 3
    
    var lifeNodes: [SKSpriteNode] = []
    var scoreLbl = SKLabelNode(fontNamed: "Krungthep")
    var coinIcon: SKSpriteNode!

    var playableRect: CGRect {
        let ratio: CGFloat
        let deviceWidth = UIScreen.main.bounds.width * UIScreen.main.scale
        let deviceHeight = UIScreen.main.bounds.height * UIScreen.main.scale
        ratio = deviceWidth/deviceHeight
        let playableHeight = size.width/ratio
        let playableMargin = (size.height - playableHeight) / 2
        return CGRect(x: 0.0, y: playableMargin, width: size.width, height: playableHeight)
    }
    
    var cameraRect: CGRect {
        let width = playableRect.width
        let height = playableRect.height
        let x = cameraNode.position.x - size.width/2.0 + (size.width - width)/2.0
        let y = cameraNode.position.y - size.height/2.0 + (size.height - height)/2.0
        return CGRect(x: x, y: y, width: width, height: height)
    }

    override func didMove(to view: SKView) {
        setupNodes()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let node = atPoint(touch.location(in: self))
        if node.name == "Pause" {
            if isPaused { return }
            createPanel()
            lastUpdateTime = 0.0
            dt = 0
            isPaused = true
        } else if node.name == "Resume" {
            containerNode.removeFromParent()
            isPaused = false
        } else if node.name == "Quit" {
//            presentScene(Ma)
        } else {
            if !isPaused {
                if onGround {
                    onGround = false
                    velocityY = -25.0
                }
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if velocityY < -12.5 {
            velocityY = -12.5
        }
    }
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        moveCamera()
        movePlayer()
        velocityY += gravity
        player.position.y -= velocityY
        if player.position.y < playerPosY {
            player.position.y = playerPosY
            velocityY = 0.0
            onGround = true
        }
        if gameOver {
            let scene = GameOverScene(size: size)
             scene.scaleMode = scaleMode
             view!.presentScene(scene, transition: .doorsCloseVertical(withDuration: 0.8))
        }
        boundCheckPlayer()
    }
}

extension GameScene {
    func setupNodes() {
        createBG()
        createGround()
        createPlayer()
        setupObs()
        spawnObstacles()
        createCoin()
        spawnCoin()
        setupPhysics()
        setupLife()
        setupScore()
        setupPause()
        setupCamera()
    }

    func setupCamera(){
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
        
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
            ground = SKSpriteNode(imageNamed: "ground")
            ground.name = "Ground"
            ground.anchorPoint = .zero
            ground.zPosition = 1.0
            ground.position = CGPoint(x: CGFloat(i)*ground.frame.width, y: 0.0)
            ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
            ground.physicsBody?.isDynamic = false
            ground.physicsBody?.affectedByGravity = false
            ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
            addChild(ground)
        }
    }

    func createPlayer() {
        player = SKSpriteNode(imageNamed: "ninja")
        player.name = "Player"
        player.zPosition = 5.0
        player.position = CGPoint(x: frame.width/2 - 100,
                                  y: ground.frame.height + player.frame.height/2.0)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.restitution = 0.0
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Block | PhysicsCategory.Coin | PhysicsCategory.Obstacle
        playerPosY = player.position.y
        addChild(player)
    }

    func createPanel() {
        cameraNode.addChild(containerNode)
        let panel = SKSpriteNode(imageNamed: "panel")
        panel.zPosition = 60.0
        panel.position = .zero
        containerNode.addChild(panel)

        let resume = SKSpriteNode(imageNamed: "resume")
        resume.zPosition = 70.0
        resume.name = "Resume"
        resume.setScale(0.7)
        resume.position = CGPoint(x: panel.frame.width/2 - resume.frame.width * 1.5 , y: 0.0)
        panel.addChild(resume)
    
        let quit = SKSpriteNode(imageNamed: "back")
        quit.zPosition = 70.0
        quit.name = "Back"
        quit.setScale(0.7)
        quit.position = CGPoint(x: -panel.frame.width/2 + quit.frame.width * 1.5, y: 0.0)
        panel.addChild(quit)
    }

    func moveCamera() {
        let amoutToMove = CGPoint(x: cameraMovePointPerSecond * CGFloat(dt), y: 0.0)
        cameraNode.position += amoutToMove
        enumerateChildNodes(withName: "BG") { (node, _ ) in
         let node = node as! SKSpriteNode
            if node.position.x + node.frame.width < self.cameraRect.origin.x {
                node.position = CGPoint(x: node.position.x + node.frame.width*2.0, y: node.position.y)
            }
        }
        enumerateChildNodes(withName: "Ground") { (node, _ ) in
         let node = node as! SKSpriteNode
            if node.position.x + node.frame.width < self.cameraRect.origin.x {
                node.position = CGPoint(x: node.position.x + node.frame.width*2.0, y: node.position.y)
            }
        }
    }

    func movePlayer() {
        let amountToMove = cameraMovePointPerSecond * CGFloat(dt)
        if !onGround {
            let rotate = CGFloat(1).degreesToRadians() * amountToMove/3
            player.zRotation -= rotate
        } else {
            player.zRotation = 0.0
        }
        player.position.x += amountToMove
    }
    func setupObs() {
        for i in 1...3 {
            let sprite = SKSpriteNode(imageNamed: "block-\(i)")
            sprite.name = "Block"
            objects.append(sprite)
        }
        for i in 1...2 {
            let sprite = SKSpriteNode(imageNamed: "obstacle-\(i)")
            sprite.name = "Obstacle"
            objects.append(sprite)
        }
        let index = Int(arc4random_uniform(UInt32(objects.count-1)))
        let sprite = objects[index].copy() as! SKSpriteNode
        sprite.zPosition = 5.0
        sprite.setScale(0.85)
        sprite.position = CGPoint(x: cameraRect.maxX + sprite.frame.width/2.0,
                                  y: ground.frame.height + sprite.frame.height/2.0)
        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        sprite.physicsBody?.isDynamic = false
        sprite.physicsBody?.affectedByGravity = false
        if sprite.name == "Block" {
            sprite.physicsBody?.categoryBitMask = PhysicsCategory.Block
        } else {
            sprite.physicsBody?.categoryBitMask = PhysicsCategory.Obstacle
        }
        sprite.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        addChild(sprite)
        sprite.run(.sequence([.wait(forDuration: 10.0), .removeFromParent()]))
    }

    func spawnObstacles() {
        let random = Double(CGFloat.random(min: 1.5, max: isTime))
        run(.repeatForever(.sequence([
            .wait(forDuration: random),
            .run { [weak self] in
                self?.setupObs()
            }])))

        run(.repeatForever(.sequence([
            .wait(forDuration: 5.0),
            .run {
                self.isTime -= 0.01
                if self.isTime <= 1.5 {
                    self.isTime = 1.5
                }
            }])))
    }

    func setupPause() {
        pauseNode = SKSpriteNode(imageNamed: "pause")
        pauseNode.name = "Pause"
        pauseNode.zPosition = 50.0
        pauseNode.setScale(0.5)
        pauseNode.position = CGPoint(x: playableRect.width/2 - pauseNode.frame.width/2 - 30.0,
                                     y: playableRect.height/2.0 - pauseNode.frame.height/2 - 10.0)
        cameraNode.addChild(pauseNode)
    }

    func setupLife() {
        let node1 = SKSpriteNode(imageNamed: "life-on")
        let node2 = SKSpriteNode(imageNamed: "life-on")
        let node3 = SKSpriteNode(imageNamed: "life-on")
        setupLifePos(node1, i: 1.0, j: 0)
        setupLifePos(node2, i: 2.0, j: 8)
        setupLifePos(node3, i: 3.0, j: 16)
        lifeNodes.append(node1)
        lifeNodes.append(node2)
        lifeNodes.append(node3)
    }

    func setupLifePos(_ node: SKSpriteNode, i: CGFloat, j: CGFloat) {
        let width = playableRect.width
        let height = playableRect.height
        node.setScale(0.5)
        node.zPosition = 50.0
        node.position = CGPoint(x: -width/2 + node.frame.width*i + j - 15.0,
                                y: height/2 - node.frame.height/2)
        cameraNode.addChild(node)
    }

    func setupScore() {
        coinIcon = SKSpriteNode(imageNamed: "coin-1")
        coinIcon.setScale(0.5)
        coinIcon.zPosition = 50.0
        coinIcon.position = CGPoint(x: -playableRect.width/2 + coinIcon.frame.width,
                                    y: playableRect.height/2 - lifeNodes[0].frame.height - coinIcon.frame.height/2)
        cameraNode.addChild(coinIcon)
        scoreLbl.text = "\(numberScore)"
        scoreLbl.fontSize = 60.0
        scoreLbl.horizontalAlignmentMode = .left
        scoreLbl.verticalAlignmentMode = .top
        scoreLbl.zPosition = 50.0
        scoreLbl.position = CGPoint(x: -playableRect.width/2 + coinIcon.size.width * 2 - 10,
                                     y: coinIcon.position.y + coinIcon.frame.height/2 - 8)
        cameraNode.addChild(scoreLbl)
    }

    func createCoin() {
        coin = SKSpriteNode(imageNamed: "coin-1")
        coin.name = "Coin"
        coin.zPosition = 20.0
        coin.setScale(0.85)
        let coinHeight = coin.frame.height
        let random = CGFloat.random(min: -coinHeight, max: coinHeight*2)
        coin.position = CGPoint(x: cameraRect.maxX + coin.frame.width, y: size.height/2.0 + random)
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width/2)
        coin.physicsBody?.restitution = 0.0
        coin.physicsBody?.affectedByGravity = false
        coin.physicsBody?.categoryBitMask = PhysicsCategory.Coin
        coin.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        addChild(coin)
        coin.run(.sequence([.wait(forDuration: 15.0), .removeFromParent()]))
        var textures: [SKTexture] = []
        for i in 1...6 {
            textures.append(SKTexture(imageNamed: "coin-\(i)"))
        }
        coin.run(.repeatForever(.animate(with: textures, timePerFrame: 0.07)))
    }
    func spawnCoin() {
        let radom = CGFloat.random(min: 2.5, max: 5.5)
        run(.repeatForever(.sequence([.wait(forDuration: TimeInterval(radom)), .run {
            [weak self] in
            self?.createCoin()
        }])))
    }

    func setupPhysics() {
        physicsWorld.contactDelegate = self
    }

    func boundCheckPlayer() {
        let bottomLeft = CGPoint(x: cameraRect.minX, y: cameraRect.minY)
        if player.position.x <= bottomLeft.x {
            player.position.x = bottomLeft.x
            lifeNodes.forEach({ $0.texture = SKTexture(imageNamed: "life-off")})
            numberScore = 0
            scoreLbl.text = "\(numberScore)"
            gameOver = true
        }
    }

    func setupGameOver() {
        life -= 1
        if life <= 0 {
            life = 0
        }
        lifeNodes[life].texture = SKTexture(imageNamed: "life-off")
        if life <= 0 && !gameOver {
            gameOver = true
        }
    }
}

extension GameScene: SKPhysicsContactDelegate{
    func didBegin(_ contact: SKPhysicsContact) {
        let other = contact.bodyA.categoryBitMask == PhysicsCategory.Player ? contact.bodyB : contact.bodyA
        switch other.categoryBitMask {
        case PhysicsCategory.Block:
            cameraMovePointPerSecond += 200.0
            numberScore -= 1
            if numberScore <= 0 { numberScore = 0 }
            scoreLbl.text = "\(numberScore)"
        case PhysicsCategory.Obstacle:
            setupGameOver()
        case PhysicsCategory.Coin:
            if let node = other.node {
                node.removeFromParent()
                numberScore += 1
                scoreLbl.text = "\(numberScore)"
                if numberScore % 5 == 0 {
                    cameraMovePointPerSecond += 50
                }
                let hightScore = ScoreGenerator.shared.getHightScore()
                if numberScore > hightScore {
                    ScoreGenerator.shared.setHightScore(hightScore)
                    ScoreGenerator.shared.setScore(numberScore)
                }
            }
        default:
            break
        }
    }
}


import CoreGraphics

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}
func += (left: inout CGPoint, right: CGPoint) {
    left = left + right
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func -= (left: inout CGPoint, right: CGPoint) {
    left = left - right
}

func * (point: CGPoint, scalar: CGPoint) -> CGPoint {
    return CGPoint(x: point.x * scalar.x, y: point.y * scalar.y)
}

func *= (point: inout CGPoint, scalar: CGPoint) {
    point = point * scalar
}

func / (point: CGPoint, scalar: CGPoint) -> CGPoint {
    return CGPoint(x: point.x / scalar.x, y: point.y / scalar.y)
}

func /= (point: inout CGPoint, scalar: CGPoint) {
    point = point / scalar
}

extension CGFloat {
    func radiansToDegrees() -> CGFloat {
        return self * 180.0 * CGFloat.pi
    }

    func degreesToRadians() -> CGFloat {
        return self *  CGFloat.pi/180.0
    }
    static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(0xFFFFFFFF))
    }

    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        assert(min < max)
        return CGFloat.random() * (max - min) + min
    }
}

struct PhysicsCategory {
    static let Player: UInt32 = 0b1
    static let Block: UInt32 = 0b10
    static let Obstacle: UInt32 = 0b100
    static let Ground: UInt32 = 0b1000
    static let Coin: UInt32 = 0b10000
}

class ScoreGenerator {
    static let shared = ScoreGenerator()
    static let keyHeightScore = "keyHeightScore"
    static let keyScore = "keyScore"
    private init() {}

    func setScore(_ score: Int) {
        UserDefaults.standard.set(score, forKey: ScoreGenerator.keyScore)
    }

    func getScore(_ score: Int) -> Int {
        UserDefaults.standard.integer(forKey: ScoreGenerator.keyScore)
    }

    func setHightScore(_ score: Int) {
        UserDefaults.standard.set(score, forKey: ScoreGenerator.keyHeightScore)
    }

    func getHightScore() -> Int {
        UserDefaults.standard.integer(forKey: ScoreGenerator.keyScore)
    }
}
