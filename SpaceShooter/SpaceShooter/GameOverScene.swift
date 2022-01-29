//
//  GameOverScene.swift
//  SpaceShooter
//
//  Created by Тим on 29.01.2022.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    var restartBtn: UIButton!
    
    override func didMove(to view: SKView) {
        scene?.backgroundColor = UIColor.white
        
        restartBtn = UIButton(frame: CGRect(x:0, y:0, width: view.frame.width / 3, height: 50))
        restartBtn.center = CGPoint(x: frame.width / 2, y: frame.height / 6)
        restartBtn.setTitle("Restart", for: UIControl.State.normal)
        restartBtn.setTitleColor(UIColor.darkGray, for: UIControl.State.normal)
        restartBtn.addTarget(self, action: Selector(("Restart")), for: UIControl.Event.touchUpInside)
        self.view?.addSubview(restartBtn)
    }
    func Restart() {
        let transition = SKTransition.flipVertical(withDuration: 0.5)
        let gameScene = GameScene(size: UIScreen.main.bounds.size)
        self.view?.presentScene(gameScene, transition: transition)
        restartBtn.removeFromSuperview()
    }
}
