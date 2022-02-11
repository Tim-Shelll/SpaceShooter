//
//  MainMenu.swift
//  SpaceShooter
//
//  Created by Тим on 06.10.2021.
//

import SpriteKit

class MainMenu: SKScene {
    var starField:SKEmitterNode!
    
    var newGameBtnNode:SKSpriteNode!
    var levelBtnNode:SKSpriteNode!
    var labelLevelNode:SKLabelNode!
    
    override func didMove(to view: SKView) {
        starField = SKEmitterNode(fileNamed: "Starfield")
        starField.position = CGPoint(x: 0, y: UIScreen.main.bounds.height + 20)
        starField.advanceSimulationTime(5)
        self.addChild(starField)
    
        starField.zPosition = -1
        
        newGameBtnNode = (self.childNode(withName: "newGameBtn") as! SKSpriteNode)
        newGameBtnNode.texture = SKTexture(imageNamed: "swift_newGameBtn")
        
        levelBtnNode = (self.childNode(withName: "levelBtn") as! SKSpriteNode)
        levelBtnNode.texture = SKTexture(imageNamed: "swift_levelBtn")
        
        labelLevelNode = (self.childNode(withName: "labelLevelBtn") as! SKLabelNode)
        
        let userlvl = UserDefaults.standard
        if userlvl.bool(forKey: "hard") {
            labelLevelNode.text = "Hard"
        }
        else {
            labelLevelNode.text = "Easy"
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            
            if nodesArray.first?.name == "newGameBtn" {
                let transition = SKTransition.flipVertical(withDuration: 0.5)
                let gameScene = GameScene(size: UIScreen.main.bounds.size)
                self.view?.presentScene(gameScene, transition: transition)
            }
            else if nodesArray.first?.name == "levelBtn" {
                changelvl()
            }
        }
    }
    func changelvl() {
        let userlvl = UserDefaults.standard
        
        if labelLevelNode.text == "Easy" {
            labelLevelNode.text = "Hard"
            userlvl.set(true, forKey: "hard")
        } else {
            labelLevelNode.text = "Easy"
            userlvl.set(false, forKey: "hard")
        }
        userlvl.synchronize()
    }
}
