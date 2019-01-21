//
//  GameScene.swift
//  Flappy Birb
//
//  Created by Charles Martin Reed on 1/20/19.
//  Copyright © 2019 Charles Martin Reed. All rights reserved.
//

import SpriteKit
import GameplayKit

class LevelScene: SKScene {
    
    //MARK:- Properties
    var birb = SKSpriteNode()
    var levelBG = SKSpriteNode()
    var pipe = SKSpriteNode()
    
    var levelIsActive = true
    let bgAnimationDuration: TimeInterval = 5.0
    var pipeGenerationTimer: Timer!
    var pipeSpawnFrequency: TimeInterval = 3.0
    
    //MARK:- Collision properties
    let birbCategory: UInt32 = 0x1 << 1 //1
    let pipeCategory: UInt32 = 0x1 << 2 //2
    let boundingCategory: UInt32 = 0x1 << 4 //8
    
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        initalizeMainGameScene()
     
    }
    
    //MARK:- Game init methods
    func initalizeMainGameScene() {
        if levelIsActive {
            //MARK:- Add birb
            let birbTexture = SKTexture(imageNamed: "flappy1")
            let birbTexture2 = SKTexture(imageNamed: "flappy2")
            
            //animate the birb, perpetualy
            let birbAnimation = SKAction.animate(with: [birbTexture, birbTexture2], timePerFrame: 0.1)
            let makeBirbFlap = SKAction.repeatForever(birbAnimation)
            
            birb = SKSpriteNode(texture: birbTexture)
            
            //MARK:- Physics methods
            birb.physicsBody = SKPhysicsBody(circleOfRadius: birbTexture.size().height / 2)
            birb.physicsBody?.isDynamic = false //changed when the first touch is registered via touches began
            birb.physicsBody?.categoryBitMask = birbCategory
            birb.physicsBody?.contactTestBitMask = pipeCategory | boundingCategory
            birb.physicsBody?.collisionBitMask = 0 //not colliding, but instead falling through. But we'll use the collision notification to end the game
            
            birb.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            birb.zPosition = 1
            birb.run(makeBirbFlap)
            
            addChild(birb)
            
            //MARK:- Add level background, animate the background slow to the left
            let backgroundTexture = SKTexture(imageNamed: "bg")
            
            let moveBGOut = SKAction.moveBy(x: -backgroundTexture.size().width, y: 0, duration: bgAnimationDuration)
            let moveBGIn = SKAction.moveBy(x: backgroundTexture.size().width, y: 0, duration: 0)
            //let moveBGOut = SKAction.moveTo(x: -self.frame.width, duration: 5)
            //let moveBGIn = SKAction.moveTo(x: self.frame.width, duration: 0)
            let moveBGSequence = SKAction.sequence([moveBGOut, moveBGIn])
            
            //creating 3 backgrounds
            for i in 0...2 {
                levelBG = SKSpriteNode(texture: backgroundTexture)
                levelBG.size.height = self.frame.height
                levelBG.position = CGPoint(x: backgroundTexture.size().width * CGFloat(i), y: self.frame.midY) //first bg is aligned to the left of frame, subsequent ones are aligned to the right of the preceeding bg
                levelBG.run(SKAction.repeatForever(moveBGSequence))
                addChild(levelBG)
            }
            
            createLevelBounds()
            pipeGenerationTimer = Timer.scheduledTimer(timeInterval: pipeSpawnFrequency, target: self, selector: #selector(generatePipes), userInfo: nil, repeats: true)
        }
       
        
    }
    
    //MARK:- Creating a floor for the level
    func createLevelBounds() {
        let ground = SKNode() //just an invisible object
        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height / 2 - birb.size.height)
        
        //ground physics
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        ground.physicsBody?.isDynamic = false //fixed in position
        ground.physicsBody?.categoryBitMask = boundingCategory
        ground.physicsBody?.contactTestBitMask = birbCategory
        ground.physicsBody?.collisionBitMask = 0
        addChild(ground)
    }
    
    @objc func generatePipes() {
        //MARK:- Pipe positioning variables
        let gapHeight = birb.size.height * 4
        let movementAmount = arc4random() % UInt32(self.frame.height / 2) //between 0 and the remainder of our frame height
        let pipeOffset = CGFloat(movementAmount) - self.frame.height / 4 //between -1/4 and +1/4 of screen height
        
        let pipeAnimationDuration = Double(self.frame.width) / 100 //duration is scaled according to the screen size - 600 pixels / 100 = 6 seconds
        
        
        let pipeTexture1 = SKTexture(imageNamed: "pipe1")
        let pipeTexture2 = SKTexture(imageNamed: "pipe2")
        
        //animate the pipes
        let movePipes = SKAction.moveBy(x: -2 * self.frame.width, y: 0, duration: pipeAnimationDuration)
        
        
        let pipe1 = SKSpriteNode(texture: pipeTexture1)
        pipe1.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeTexture1.size().height / 2 + gapHeight / 2 + pipeOffset) //start just off screen
        
        //pipe1 physics setup
        pipe1.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture1.size())
        pipe1.physicsBody?.isDynamic = false
        pipe1.physicsBody?.affectedByGravity = false
        pipe1.physicsBody?.categoryBitMask = pipeCategory
        pipe1.physicsBody?.contactTestBitMask = birbCategory
        pipe1.physicsBody?.collisionBitMask = 0
        
        pipe1.zPosition = 1
        pipe1.run(movePipes) {
            pipe1.removeFromParent()
        }
        addChild(pipe1)
        
        let pipe2 = SKSpriteNode(texture: pipeTexture2)
        pipe2.position = CGPoint(x: self.frame.midX + self.frame.width, y: -self.frame.midY - pipeTexture2.size().height / 2 - gapHeight / 2 + pipeOffset)
        
        //pipe2 physics setup
        pipe2.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture2.size())
        pipe2.physicsBody?.isDynamic = false
        pipe2.physicsBody?.affectedByGravity = false
        pipe2.physicsBody?.categoryBitMask = pipeCategory
        pipe2.physicsBody?.contactTestBitMask = birbCategory
        pipe2.physicsBody?.collisionBitMask = 0
        
        pipe2.zPosition = 1
        pipe2.run(movePipes) {
            pipe2.removeFromParent()
        }
        addChild(pipe2)
    }
    
    //MARK:- End round methods
    func endLevel() {
        scene?.isPaused = true
        levelIsActive = false
        pipeGenerationTimer.invalidate()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        birb.physicsBody?.isDynamic = true
        birb.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 50))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //birb.texture = SKTexture(imageNamed: "flappy1")
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        
    }
}

extension LevelScene : SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
       //only bird makes contact
        print("We have contact")
        
        endLevel()
    }
}
