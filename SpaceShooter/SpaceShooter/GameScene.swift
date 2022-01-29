//
//  GameScene.swift
//  SpaceShooter
//
//  Created by Тим on 28.09.2021.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starField:SKEmitterNode!
    var player:SKSpriteNode!
    var scoreLabel:SKLabelNode!
    var score:Int = 0 {
        didSet {
            scoreLabel.text = "Счет: \(score)"
        }
    }
    
    var pauseBtnNode:SKSpriteNode!
    
    var gameTimer:Timer!
    var aliens = ["alien", "alien2", "alien3"]
    
    let bulletCategory:UInt32 = 0x1 << 0
    let alienCategory: UInt32 = 0x1 << 1
    let playerCategory:UInt32 = 0x1 << 2
    
    let motionManager = CMMotionManager()
    var xAccelerate:CGFloat = 0
    
    var Paused = true
    
    func pauseResume() {
        let transition = SKTransition.flipVertical(withDuration: 0.5)
        let gameScene = MainMenu(size: UIScreen.main.bounds.size)
        self.view?.presentScene(gameScene, transition: transition)
    }
    
    override func didMove(to view: SKView) {
        starField = SKEmitterNode(fileNamed: "Starfield")
        starField.position = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height + 20)
        starField.advanceSimulationTime(10)
        self.addChild(starField)
    
        starField.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "shuttle")
        player.position = CGPoint(x: self.size.width / 2, y: self.size.height / 6)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = true

        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.contactTestBitMask = alienCategory
        player.physicsBody?.collisionBitMask = 1
        
        self.addChild(player)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        scoreLabel = SKLabelNode (text: "Счет: 0")
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = UIColor.white
        scoreLabel.position = CGPoint(x: 100, y: UIScreen.main.bounds.height - 50)
        score = 0
        
        pauseBtnNode = SKSpriteNode(imageNamed: "pause")
        pauseBtnNode.size = CGSize(width: 50, height: 50)
        pauseBtnNode.position = CGPoint(x: UIScreen.main.bounds.width - 50, y: UIScreen.main.bounds.height - 50)
        pauseBtnNode.name = "pause"
        self.addChild(scoreLabel)
        self.addChild(pauseBtnNode)
        
        var timeInterval = 0.75
        
        if UserDefaults.standard.bool(forKey: "hard") {
            timeInterval = 0.5
        }
        
        gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
        
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data: CMAccelerometerData?, error: Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xAccelerate = CGFloat(acceleration.x) * 0.75 + self.xAccelerate * 0.25
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            
            if nodesArray.first?.name == "pause"{
                pauseResume()
            }
        }
    }
    
    override func didSimulatePhysics() {
        player.position.x += xAccelerate * 50
        
        if player.position.x < 0 {
            player.position = CGPoint(x: UIScreen.main.bounds.width - player.size.width, y: player.position.y)
        }
        else if player.position.x > UIScreen.main.bounds.width {
            player.position = CGPoint(x: player.size.width, y: player.position.y)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody:SKPhysicsBody = contact.bodyA
        let secondBody:SKPhysicsBody = contact.bodyB
        
        if ((firstBody.categoryBitMask == alienCategory) && (secondBody.categoryBitMask == bulletCategory) || (firstBody.categoryBitMask == bulletCategory) && (secondBody.categoryBitMask == alienCategory)) {
            collisionElements(bulletNode: firstBody.node as! SKSpriteNode, alienNode: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == alienCategory) && (secondBody.categoryBitMask == playerCategory) || (firstBody.categoryBitMask == playerCategory) && (secondBody.categoryBitMask == alienCategory)) {
            collisionWithPlayer(enemy: firstBody.node as! SKSpriteNode, player: secondBody.node as! SKSpriteNode )
        }
        
//        if (alienBody.categoryBitMask & alienCategory) != 0 && (bulletBody.categoryBitMask & bulletCategory) != 0 {
//            collisionElements(bulletNode: bulletBody.node as! SKSpriteNode, alienNode: alienBody.node as! SKSpriteNode)
//        }
    }
    
    func collisionElements (bulletNode:SKSpriteNode, alienNode:SKSpriteNode) {
        let explosion = SKEmitterNode(fileNamed: "Vzriv")
        explosion?.position = alienNode.position
        self.addChild(explosion!)
        
        self.run(SKAction.playSoundFileNamed("vzriv.mp3", waitForCompletion: false))
        
        bulletNode.removeFromParent()
        alienNode.removeFromParent()
        
        self.run(SKAction.wait(forDuration: 2)) {
            explosion?.removeFromParent()
        }
        
        score += 5
    }
    
    func collisionWithPlayer(enemy:SKSpriteNode, player:SKSpriteNode) {
        enemy.removeFromParent()
        player.removeFromParent()
        
        let transition = SKTransition.flipVertical(withDuration: 0.5)
        let gameScene = GameOverScene(size: UIScreen.main.bounds.size)
        self.view?.presentScene(gameScene, transition: transition)    }
    
    @objc func addAlien() {
        aliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: aliens) as! [String]
        
        let alien = SKSpriteNode(imageNamed: aliens[0])
        let randomPos = GKRandomDistribution(lowestValue: 20, highestValue: Int(UIScreen.main.bounds.width) - 20)
        let pos = CGFloat(randomPos.nextInt())
        alien.position = CGPoint(x: pos, y: UIScreen.main.bounds.height + alien.size.height)
        
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic = true
        
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = bulletCategory
        alien.physicsBody?.collisionBitMask = 0
        
        self.addChild(alien)
        
        let animDuration:TimeInterval = 6
        var actions = [SKAction()]
        actions.append(SKAction.move(to: CGPoint(x: pos, y: 0 - alien.size.height), duration: animDuration))
        actions.append(SKAction.removeFromParent())
        
        alien.run(SKAction.sequence(actions))
        }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireBullet()
    }
    
    func fireBullet () {
        self.run(SKAction.playSoundFileNamed("vzriv.mp3", waitForCompletion: false))
        
        let bullet = SKSpriteNode(imageNamed: "torpedo")
        bullet.position = player.position
        bullet.position.y += 5
        
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width / 2)
        
        bullet.physicsBody?.isDynamic = true
        
        bullet.physicsBody?.categoryBitMask = bulletCategory
        bullet.physicsBody?.contactTestBitMask = alienCategory
        bullet.physicsBody?.collisionBitMask = 0
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(bullet)
        
        let animDuration:TimeInterval = 0.3
        var actions = [SKAction()]
        actions.append(SKAction.move(to: CGPoint(x: player.position.x, y: UIScreen.main.bounds.height + bullet.size.height), duration: animDuration))
        actions.append(SKAction.removeFromParent())
        
        bullet.run(SKAction.sequence(actions))
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
