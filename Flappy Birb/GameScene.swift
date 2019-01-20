//
//  GameScene.swift
//  Flappy Birb
//
//  Created by Charles Martin Reed on 1/20/19.
//  Copyright © 2019 Charles Martin Reed. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    //MARK:- Properties
    var birb = SKSpriteNode()
    var levelBG = SKSpriteNode()
    
    override func didMove(to view: SKView) {
        
        initalizeMainGameScene()
     
    }
    
    func initalizeMainGameScene() {
        //add birb
        let birbTexture = SKTexture(imageNamed: "flappy1")
        let birbTexture2 = SKTexture(imageNamed: "flappy2")
        
        //animate the birb, perpetualy
        let birbAnimation = SKAction.animate(with: [birbTexture, birbTexture2], timePerFrame: 0.1)
        let makeBirbFlap = SKAction.repeatForever(birbAnimation)
        
        birb = SKSpriteNode(texture: birbTexture)
        
        birb.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        birb.zPosition = 1
        birb.run(makeBirbFlap)
        
        addChild(birb)
        
        //add the background, animate the background slow to the left
        let backgroundTexture = SKTexture(imageNamed: "bg")
        
        let moveBGOut = SKAction.moveBy(x: -backgroundTexture.size().width, y: 0, duration: 5)
        let moveBGIn = SKAction.moveBy(x: backgroundTexture.size().width, y: 0, duration: 0)
        //let moveBGOut = SKAction.moveTo(x: -self.frame.width, duration: 5)
        //let moveBGIn = SKAction.moveTo(x: self.frame.width, duration: 0)
        let moveBGSequence = SKAction.sequence([moveBGOut, moveBGIn])
        
        //using 3 backgrounds
        for i in 0...2 {
            levelBG = SKSpriteNode(texture: backgroundTexture)
            levelBG.size.height = self.frame.height
            levelBG.position = CGPoint(x: backgroundTexture.size().width * CGFloat(i), y: self.frame.midY) //first bg is aligned to the left of frame, subsequent ones are aligned to the right of the preceeding bg
            levelBG.run(SKAction.repeatForever(moveBGSequence))
            addChild(levelBG)
        }
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //birb.texture = SKTexture(imageNamed: "flappy2")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //birb.texture = SKTexture(imageNamed: "flappy1")
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        
    }
}
