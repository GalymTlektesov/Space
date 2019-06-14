import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //Компонеты необходимые для сцены
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var scorelabel: SKLabelNode!
    var score: Int = 0{
        didSet{
            scorelabel.text = "Счет \(score)"
        }
    }
    var gametimer: Timer!
    var aliens = ["alien", "alien2", "alien3"]
    let alienCategory: UInt32 = 0x1 << 1
    let bulletCategory: UInt32 = 0x1 << 0
    let playerCategory: UInt32 = 0x1 << 0
    let motionManager = CMMotionManager()
    var xAccelerate:CGFloat = 0
    //Компоненты необходимые для сцены
    
    
    //Добавление на сцену
    override func didMove(to view: SKView) {
        
        //Доваление звёзд
        starfield = SKEmitterNode(fileNamed: "Starfield")
        starfield.position = CGPoint(x: 0, y: 1472)
        starfield.advanceSimulationTime(12)
        self.addChild(starfield)
        
        starfield.zPosition = -1
        
        //Добавление игрока
        player = SKSpriteNode(imageNamed: "shuttle")
        player.position = CGPoint(x: UIScreen.main.bounds.width / 2, y: 40)
        
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = true

        
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.contactTestBitMask = alienCategory
        player.physicsBody?.collisionBitMask = 0
        
        
        self.addChild(player)
        
        //Немного физики
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        //Счет
        scorelabel = SKLabelNode(text: "Счет 0")
        scorelabel.fontName = "AmericanTypewriter-Bold"
        scorelabel.fontSize = 36
        scorelabel.fontColor = UIColor.white
        scorelabel.position = CGPoint(x: 100, y: UIScreen.main.bounds.height - 50)
        score = 0
        
        //Добавление пришельца
        self.addChild(scorelabel)
        
        //Игровая скорость
        var gameinterval = 0.75
        
        //Проверка на уровень сложности
        if UserDefaults.standard.bool(forKey: "hard"){
            gameinterval = 0.3
        }
        
        gametimer = Timer.scheduledTimer(timeInterval: gameinterval, target: self, selector: #selector(AddAlien), userInfo: nil, repeats: true)
        
        
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) {
            (data: CMAccelerometerData?, error: Error?) in
            if let acceleromtrdata = data {
                let acceleration = acceleromtrdata.acceleration
                self.xAccelerate = CGFloat(acceleration.x) * 0.75 + self.xAccelerate * 0.25
            }
        }
    }
    //Добавление на сцену
    
    
    //Управление акселерометром, для движение игрока
    override func didSimulatePhysics() {
        player.position.x += xAccelerate * 50
        
        if player.position.x < 0 {
            player.position = CGPoint(x: UIScreen.main.bounds.width, y: player.position.y)
        } else if player.position.x > UIScreen.main.bounds.width {
            player.position = CGPoint(x: 0, y: player.position.y)
        }
    }
    //Управление акселерометром, для движение игрока
    
    
    // Проверка столкновений
    func didBegin(_ contact: SKPhysicsContact) {
        var alienbody: SKPhysicsBody
        var bulletbody: SKPhysicsBody
        var playerbody: SKPhysicsBody
        
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            alienbody = contact.bodyB
            bulletbody = contact.bodyA
            playerbody = contact.bodyA
        } else {
            alienbody = contact.bodyA
            bulletbody = contact.bodyB
            playerbody = contact.bodyB
        }
        
        //Столкновние пришельца с пулей
        if (alienbody.categoryBitMask & alienCategory) != 0 && (bulletbody.categoryBitMask & bulletCategory) != 0 {
            collisionElements(bulletNode: bulletbody.node as! SKSpriteNode, alienNode: alienbody.node as! SKSpriteNode)
            score += 5
        }
        //Столкновение персонажа с пришельцем
        if (alienbody.categoryBitMask & playerCategory) != 0 && (bulletbody.categoryBitMask & alienCategory) != 0 {
            collisionElements(bulletNode: alienbody.node as! SKSpriteNode, alienNode: playerbody.node as! SKSpriteNode)
            let transition = SKTransition.flipVertical(withDuration: 0.5)
            let mainScene = MainMenu(size: UIScreen.main.bounds.size)
            self.view?.presentScene(mainScene, transition: transition)
        }
    }
    
    //Функия для врыва при столкновении двух объектов
    func collisionElements(bulletNode: SKSpriteNode, alienNode: SKSpriteNode) {
        
        let explosion = SKEmitterNode(fileNamed: "Vzriv")
        explosion?.position = alienNode.position
        self.addChild(explosion!)
        
        self.run(SKAction.playSoundFileNamed("vzriv.mp3", waitForCompletion: false))
        
        bulletNode.removeFromParent()
        alienNode.removeFromParent()
        
        self.run(SKAction.wait(forDuration: 2)){
            explosion?.removeFromParent()
        }
        
    }
    //Функиция для взрыва при столкновении двух объектов
    //Проверка столновений
    
    
    //Наша функция необходимо для добавление нового врага на сцену
    @objc func AddAlien(){
        aliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: aliens) as! [String]
        let alien = SKSpriteNode(imageNamed: aliens[0])
        let randomPos = GKRandomDistribution(lowestValue: 20, highestValue: Int(UIScreen.main.bounds.size.width - 20))
        let pos = CGFloat(randomPos.nextInt())
        alien.position = CGPoint(x: pos, y: UIScreen.main.bounds.size.height + alien.size.height)
        
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic = true
        
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = bulletCategory
        alien.physicsBody?.collisionBitMask = 0
        
        self.addChild(alien)
        
        let animDuration:TimeInterval = 6
        
        var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(x: pos, y: 0 - alien.size.height), duration: animDuration))
        actions.append(SKAction.removeFromParent())
        
        alien.run(SKAction.sequence(actions))
    }
    //Наша функиция необходима для добавление нового врага на сцену
    
    
    //Проверка на касание, выстрел
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        firebullet()
    }
    //Проверка на касание, выстрел
    
    
    //наша функция необходимо для выстрела
    func firebullet() {
        self.run(SKAction.playSoundFileNamed("bullet.mp3", waitForCompletion: false))
        
        let bullet = SKSpriteNode(imageNamed: "torpedo")
        bullet.position = player.position
        bullet.position.y += 5
        
        
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width / 2)
        bullet.physicsBody?.isDynamic = true
        
        bullet.physicsBody?.categoryBitMask = bulletCategory
        bullet.physicsBody?.contactTestBitMask = alienCategory
        bullet.physicsBody?.collisionBitMask = 0
        
        self.addChild(bullet)
        
        let animDuration:TimeInterval = 0.3
        
        var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(x: player.position.x, y: UIScreen.main.bounds.size.height + bullet.size.height), duration: animDuration))
        actions.append(SKAction.removeFromParent())
        
        bullet.run(SKAction.sequence(actions))
    }
    //Наша функция необходимо для выстрела
}
