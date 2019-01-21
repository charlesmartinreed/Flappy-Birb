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
    var scoreLabel = SKLabelNode()
    var gameOverLabel = SKLabelNode()
    var newHighScoreLabel = SKLabelNode()
    
    var playerScore: Int = 0 {
        didSet {
            scoreLabel.text = "\(playerScore)"
        }
    }
    var playerTopScore: Int = 0
    
    var isGameOver = false
    let bgAnimationDuration: TimeInterval = 5.0
    var pipeGenerationTimer: Timer!
    var pipeSpawnFrequency: TimeInterval = 3.0
    
    //MARK:- Collision properties
    let birbCategory: UInt32 = 0x1 << 1 //1
    let pipeCategory: UInt32 = 0x1 << 2 //2
    let gapCategory: UInt32 = 0x1 << 3 //4
    let boundingCategory: UInt32 = 0x1 << 4 //8
    
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        initalizeMainGameScene()
        
        if let currentHighScore = UserDefaults.standard.value(forKey: "playerTopScore") as? Int {
            print("High score is: \(currentHighScore)")
        } else {
            print("No high score yet")
        }
        
    }
    
    //MARK:- Game init methods
    func initalizeMainGameScene() {
        playerScore = 0
        self.isPaused = false
        createBirbInScene()
        createLevelInScene()
        
        //start the timer for the generation of pipes
        pipeGenerationTimer = Timer.scheduledTimer(timeInterval: pipeSpawnFrequency, target: self, selector: #selector(generatePipesForLevel), userInfo: nil, repeats: true)
    }
    
    //MARK:- Add birb
    func createBirbInScene() {
        
        let birbTexture = SKTexture(imageNamed: "flappy1")
        let birbTexture2 = SKTexture(imageNamed: "flappy2")
        
        birb = SKSpriteNode(texture: birbTexture)
        birb.name = "birb"
        //animate the birb, perpetualy
        let birbAnimation = SKAction.animate(with: [birbTexture, birbTexture2], timePerFrame: 0.1)
        let makeBirbFlap = SKAction.repeatForever(birbAnimation)
        
        
        
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
    }
    
    //MARK:- Create level background
    func createLevelInScene() {
        //create score label
        scoreLabel = SKLabelNode(fontNamed: "Helvetica")
        scoreLabel.fontSize = 60
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height / 2 - 70)
        scoreLabel.zPosition = 1
        scoreLabel.text = "\(playerScore)"
        
        addChild(scoreLabel)
        
        scoreLabel.fontColor = SKColor.white
        
        //add level background, animate the background slow to the left
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
    
    @objc func generatePipesForLevel() {
        //MARK:- Pipe positioning variables
        let gapHeight = birb.size.height * 4
        let movementAmount = arc4random() % UInt32(self.frame.height / 2) //between 0 and the remainder of our frame height
        let pipeOffset = CGFloat(movementAmount) - self.frame.height / 4 //between -1/4 and +1/4 of screen height
        
        let pipeAnimationDuration = Double(self.frame.width) / 100 //duration is scaled according to the screen size - 600 pixels / 100 = 6 seconds
        
        let pipeTexture1 = SKTexture(imageNamed: "pipe1")
        let pipeTexture2 = SKTexture(imageNamed: "pipe2")
        
        //animate the pipes
        let moveAndRemovePipes = SKAction.moveBy(x: -2 * self.frame.width, y: 0, duration: pipeAnimationDuration)
        
        
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
        pipe1.run(moveAndRemovePipes) {
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
        pipe2.run(moveAndRemovePipes) {
            pipe2.removeFromParent()
        }
        addChild(pipe2)
        
        //create a invisible passthrough in the gap between pipes; when the player crosses this gap, they are granted a point
        //x position is same position as the pipes, y position is the center of the gap
        let gap = SKNode()
        gap.name = "gap"
        gap.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeOffset)
        
        //gap physics
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeTexture1.size().width, height: gapHeight))
        gap.physicsBody?.isDynamic = false
        gap.physicsBody?.affectedByGravity = false
        
        gap.physicsBody?.categoryBitMask = gapCategory
        gap.physicsBody?.contactTestBitMask = birbCategory
        gap.physicsBody?.collisionBitMask = gapCategory //allows bird to pass through
        
        gap.run(moveAndRemovePipes) {
            gap.removeFromParent()
        }
        addChild(gap)
    }
    
    //MARK:- End round methods
    func endLevel() {
        isGameOver = true
        scene?.isPaused = true
        pipeGenerationTimer.invalidate()
        
        //display the game over screen
        gameOverLabel = SKLabelNode(fontNamed: "Helvetica")
        gameOverLabel.fontSize = 40
        gameOverLabel.fontColor = UIColor.white
        gameOverLabel.text = "Game over! Tap to play again."
        gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        gameOverLabel.zPosition = 2
        addChild(gameOverLabel)
        
        //we'll also reset the scene here
        if let currentTopScore = UserDefaults.standard.value(forKey: "playerTopScore") as? Int {
            if playerScore > currentTopScore {
                //notify the player and write the new score
                newHighScoreLabel = SKLabelNode(fontNamed: "Helvetica")
                newHighScoreLabel.fontSize = 60
                newHighScoreLabel.fontColor = UIColor.red
                newHighScoreLabel.text = "New high score!"
                newHighScoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 70)
                newHighScoreLabel.zPosition = 2
                addChild(newHighScoreLabel)
                
                UserDefaults.standard.set(playerScore, forKey: "playerTopScore")
            }
        } else {
            //if no current top score, create it for the first time
            UserDefaults.standard.set(playerScore, forKey: "playerTopScore")
        }
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        if !isGameOver {
            birb.physicsBody?.isDynamic = true
            birb.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 50))
        } else {
            isGameOver = false
            scene?.removeAllChildren()
            initalizeMainGameScene()
        }
        
    }
}

extension LevelScene : SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
       //if birb makes contact with gap between pipes, add to the score
        if contact.bodyA.categoryBitMask == gapCategory || contact.bodyB.categoryBitMask == gapCategory {
            playerScore += 1
        } else {
            //if the birb touches ANYTHING else, game over!
            endLevel()
        }
    }
}
