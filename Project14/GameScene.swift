//
//  GameScene.swift
//  Project14
//
//  Created by Edwin Przeźwiecki Jr. on 30/08/2022.
//

import SpriteKit

class GameScene: SKScene {
    
    var slots = [WhackSlot]()
    
    var popupTime = 0.85
    
    var gameScore: SKLabelNode!
    
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    var numRounds = 0
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Score: 0"
        gameScore.position = CGPoint(x: 8, y: 8)
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        for i in 0..<5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 410)) }
        for i in 0..<4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 320)) }
        for i in 0..<5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 230)) }
        for i in 0..<4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 140)) }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.createEnemy()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        /* for node in tappedNodes {
            if node.name == "charFriend" {
                guard let whackSlot = node.parent?.parent as? WhackSlot else { continue }
                if !whackSlot.isVisible { continue }
                if whackSlot.isHit { continue }
                
                whackSlot.hit()
                score -= 5
                
                run(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false))
            } else if node.name == "charEnemy" {
                guard let whackSlot = node.parent?.parent as? WhackSlot else { continue }
                if !whackSlot.isVisible { continue }
                if whackSlot.isHit { continue }
                
                whackSlot.charNode.xScale = 0.85
                whackSlot.charNode.yScale = 0.85
                
                whackSlot.hit()
                score += 1
                
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
            } */
        
        for node in tappedNodes {
            
            guard let whackSlot = node.parent?.parent as? WhackSlot else { continue }
            
            if !whackSlot.isVisible { continue }
            if whackSlot.isHit { continue }
            whackSlot.hit()
            
            if node.name == "charFriend" {
                score -= 5
                
                run(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false))
            } else if node.name == "charEnemy" {
                /// Challenge 3:
                if let smokeParticles = SKEmitterNode(fileNamed: "whackedHard") {
                    smokeParticles.position = touch.location(in: self)
                    addChild(smokeParticles)
                }
                
                whackSlot.charNode.xScale = 0.85
                whackSlot.charNode.yScale = 0.85
                
                score += 1
                
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
            }
        }
        
        for node in tappedNodes {
            if node.name == "playAgain" {
                restart()
                return
            }
        }
    }
    
    func createSlot(at position: CGPoint) {
        
        let slot = WhackSlot()
        slot.configure(at: position)
        addChild(slot)
        
        slots.append(slot)
    }
    
    func createEnemy() {
        
        numRounds += 1
        
        if numRounds >= 30 {
            for slot in slots {
                slot.hide()
            }
            
            let gameOver = SKSpriteNode(imageNamed: "gameOver")
            gameOver.name = "gameOver"
            gameOver.position = CGPoint(x: 512, y: 384)
            gameOver.zPosition = 1
            addChild(gameOver)
            
            /// Challenge 2:
            let finalScore = SKLabelNode(fontNamed: "Chalkduster")
            finalScore.name = "finalScore"
            finalScore.text = "Your score: \(score)"
            finalScore.position = CGPoint(x: 512, y: 310)
            finalScore.zPosition = 1
            addChild(finalScore)
            
            let playAgain = SKLabelNode(fontNamed: "Futura-CondensedExtraBold")
            playAgain.name = "playAgain"
            playAgain.text = "Play again!"
            playAgain.position = CGPoint(x: 512, y: 266)
            playAgain.zPosition = 1
            addChild(playAgain)
            
            /// Challenge 1:
            run(SKAction.playSoundFileNamed("gameOver.m4a", waitForCompletion: false))
            
            return
        }
        
        popupTime *= 0.991
        
        slots.shuffle()
        
        slots[0].show(hideTime: popupTime)
        
        if Int.random(in: 0...12) > 4 { slots[1].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 8 { slots[2].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 10 { slots[3].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 11 { slots[4].show(hideTime: popupTime) }
        
        let minDelay = popupTime / 2.0
        let maxDelay = popupTime * 2
        let delay = Double.random(in: minDelay...maxDelay)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.createEnemy()
        }
    }
    
    func restart() {
        
        // removeAllChildren()
        for child in children {
            if child.name == "gameOver" || child.name == "finalScore" || child.name == "playAgain" {
                removeChildren(in: [child])
            }
        }
        
        popupTime = 0.85
        score = 0
        numRounds = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.createEnemy()
        }
    }
}
