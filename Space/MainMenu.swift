import SpriteKit

class MainMenu: SKScene {
    
    var starfield: SKEmitterNode!
    var newGameBtnNode: SKSpriteNode!
    var levelBtnNode: SKSpriteNode!
    var labelLevelNode: SKLabelNode!
    
    
    override func didMove(to view: SKView) {
        
        starfield = self.childNode(withName: "starfieldanim") as! SKEmitterNode
        starfield.advanceSimulationTime(10)
        
        
        newGameBtnNode = self.childNode(withName: "newGameBtn") as! SKSpriteNode
        newGameBtnNode.texture = SKTexture(imageNamed: "newGameBtn")
        levelBtnNode = self.childNode(withName: "LevelBtn") as! SKSpriteNode
        levelBtnNode.texture = SKTexture(imageNamed: "levelBtn")
        labelLevelNode = self.childNode(withName: "LevelLabel") as! SKLabelNode
        
        let userlevel = UserDefaults.standard
        
        if userlevel.bool(forKey: "hard"){
            labelLevelNode.text = "Сложный"
        } else {
            labelLevelNode.text = "Легкий"
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
            } else if nodesArray.first?.name == "LevelBtn" {
                changeLevel()
            }
        }
    }
    
    func changeLevel(){
        let userlevel = UserDefaults.standard
        
        if labelLevelNode.text == "Легкий" {
            labelLevelNode.text = "Сложный"
            userlevel.set(true, forKey: "hard")
        } else if labelLevelNode.text == "Сложный" {
            labelLevelNode.text = "Легкий"
            userlevel.set(false, forKey: "hard")
        }
        
        userlevel.synchronize()
    }

}
