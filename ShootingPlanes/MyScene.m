//
//  MyScene.m
//  ShootingPlanes
//
//  Created by 刘彦超 on 14-9-22.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import "MyScene.h"
#import "GameOverScene.h"

@interface MyScene () <SKPhysicsContactDelegate>
@property (nonatomic) SKSpriteNode * bgi;
@property (nonatomic) SKSpriteNode * player;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) int shootInterval;
@property (nonatomic) int planesShootedDown;
@property (nonatomic) int MshootInterval;
@end

static const uint32_t projectileCategory     =  0x1 << 0;
static const uint32_t monsterCategory        =  0x1 << 1;
static const uint32_t playerCategory         =  0x1 << 2;
static const uint32_t bulletCategory         =  0x1 << 3;

static inline CGPoint rwAdd(CGPoint a,CGPoint b) {
    return CGPointMake(a.x+b.x, a.y+b.y);
}
static inline CGPoint rwSub(CGPoint a,CGPoint b) {
    return CGPointMake(a.x-b.x, a.y-b.y);
}
static inline CGPoint rwMult(CGPoint a,float b) {
    return CGPointMake(a.x * b, a.y * b);
}
static inline float rwLength(CGPoint a){
    return sqrtf(a.x*a.x+a.y*a.y);
}
//矢量运算方法

static inline CGPoint rwNormalize(CGPoint a){
    float length = rwLength(a);
    return CGPointMake(a.x/length, a.y/length);
}//单位长度的矢量


@implementation MyScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        self.bgi = [SKSpriteNode spriteNodeWithImageNamed:@"Orchestra.jpg"];
        self.bgi.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [self addChild:self.bgi];
        
        self.player = [SKSpriteNode spriteNodeWithImageNamed:@"plane"];
        self.player.position = CGPointMake(self.frame.size.width/2, self.player.size.height);
        [self addChild:self.player];
        
        self.player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.player.size];
        self.player.physicsBody.dynamic = YES;
        self.player.physicsBody.categoryBitMask = playerCategory;
        self.player.physicsBody.contactTestBitMask = monsterCategory;
        self.player.physicsBody.collisionBitMask = 0;
        
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.planesShootedDown = 0;
        self.physicsWorld.contactDelegate = self;
    }
    return self;
}

- (void)enemyShoot:(SKSpriteNode*) monster{
    SKSpriteNode* bullet = [SKSpriteNode spriteNodeWithImageNamed:@"bullet"];
    bullet.position = monster.position;
    [self addChild:bullet];
    NSLog(@"begin shoot pos:%f,%f",monster.position.x,monster.position.y);
    bullet.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:bullet.size.height/2];
    bullet.physicsBody.dynamic = YES;
    bullet.physicsBody.categoryBitMask = bulletCategory;
    bullet.physicsBody.contactTestBitMask = playerCategory;
    bullet.physicsBody.collisionBitMask = 0;
    bullet.physicsBody.usesPreciseCollisionDetection=YES;
    
    CGPoint offset = rwSub(self.player.position, bullet.position);
    //得到子弹位置到触控位置的偏移量
    
    CGPoint direction = rwNormalize(offset);
    //得到子弹方向
    
    CGPoint shootAmount = rwMult(direction, 1024);
    //在矢量方向上乘以1000，足够位置超出屏幕
    
    CGPoint realDest = rwAdd(shootAmount, bullet.position);
    //相加后得到终止位置
    
    float velocity = 600.0/1.0;
    float realMoveDuration = abs(offset.y) / velocity;
    SKAction * actionMove = [SKAction moveTo:realDest duration:realMoveDuration];
    SKAction *actionMoveDone =[SKAction removeFromParent];
    [bullet runAction:[SKAction sequence:@[actionMove,actionMoveDone]]];
    //创建动作
}

- (void)addMonster {
    
    // Create sprite
    SKSpriteNode * monster = [SKSpriteNode spriteNodeWithImageNamed:@"enemyplane"];
    
    // Determine where to spawn the monster along the Y axis
    int minX = monster.size.width / 2;
    int maxX = self.frame.size.width - monster.size.width / 2;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    monster.position = CGPointMake(actualX,self.frame.size.height + monster.size.height/2);
    [self addChild:monster];
    
    monster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monster.size];
    monster.physicsBody.dynamic = YES;
    monster.physicsBody.categoryBitMask = monsterCategory;
    monster.physicsBody.contactTestBitMask = projectileCategory;
    monster.physicsBody.contactTestBitMask = playerCategory;
    monster.physicsBody.collisionBitMask = 0;
    monster.physicsBody.usesPreciseCollisionDetection=YES;
    
    // Determine speed of the monster
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the actions
    
    SKAction * actionMove = [SKAction moveTo:CGPointMake(actualX,-monster.size.height/2) duration:actualDuration];
    
    SKAction * MonsterShoot = [SKAction runBlock:^{
        int delay=0;
        while (delay<900) {
            delay++;
        }
        [self enemyShoot:monster];
        NSLog(@"enemy Shoot %f %f",monster.position.x,monster.position.y);
    }];
    
    SKAction * actionsGroup = [SKAction group:@[actionMove,MonsterShoot]];
    //创建actionsGroup使两个动作同时运行
    
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [monster runAction:[SKAction sequence:@[actionsGroup,actionMoveDone]]];
    
}

- (void)toShoot{
    [self runAction:[SKAction playSoundFileNamed:@"pew-pew-lei.caf" waitForCompletion:NO]];
    SKSpriteNode * projectile = [SKSpriteNode spriteNodeWithImageNamed:@"projectile.png"];
    projectile.position = self.player.position;
    [self addChild:projectile];
    CGPoint realDest = CGPointMake(projectile.position.x, self.frame.size.height+projectile.size.height/2);
    float velocity = 480.0/1.0;
    float realMoveDuration = (self.size.height-projectile.position.y) / velocity;
    SKAction * actionMove = [SKAction moveTo:realDest duration:realMoveDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    
    projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:projectile.size.width/2];
    projectile.physicsBody.dynamic = YES;
    projectile.physicsBody.categoryBitMask = projectileCategory;
    projectile.physicsBody.contactTestBitMask = monsterCategory;
    projectile.physicsBody.collisionBitMask = 0;
    projectile.physicsBody.usesPreciseCollisionDetection = YES;
    
    [projectile runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
}

- (void)projectile:(SKSpriteNode *)projectile didCollideWithMonster:(SKSpriteNode *)monster {
    NSLog(@"Hit");
    self.planesShootedDown++;
    [projectile removeFromParent];
    [monster removeFromParent];
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask & projectileCategory) != 0 &&
        (secondBody.categoryBitMask & monsterCategory) != 0)
    {
        [self projectile:(SKSpriteNode *) firstBody.node didCollideWithMonster:(SKSpriteNode *) secondBody.node];
    }
    
    if ((firstBody.categoryBitMask & playerCategory) !=0 && (secondBody.categoryBitMask & bulletCategory) != 0) {
        [self gameOver];
    }
    
    if ((firstBody.categoryBitMask & monsterCategory) !=0 && (secondBody.categoryBitMask & playerCategory) != 0) {
        [self gameOver];
    }
}

- (void) gameOver{
    SKAction * loseAction = [SKAction runBlock:^{
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size deadplanes:self.planesShootedDown];
        [self.view presentScene:gameOverScene transition: reveal];
    }];
    [self runAction:loseAction];
}

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > 1) {
        self.lastSpawnTimeInterval = 0;
        [self addMonster];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint positionInScene = [touch locationInNode:self];
    CGPoint previousPosition = [touch previousLocationInNode:self];
    
    CGPoint moveDistance = CGPointMake(self.player.position.x+positionInScene.x-previousPosition.x, self.player.position.y+positionInScene.y-previousPosition.y);
    if ((moveDistance.y<self.frame.size.height)&&(moveDistance.y>0)&&(moveDistance.x>0)&&(moveDistance.x<self.frame.size.width)) {
        [self.player setPosition:moveDistance];
    }
}

- (void)update:(NSTimeInterval)currentTime {
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
    
    self.shootInterval++;
    if (self.shootInterval%20==0) {
        [self toShoot];
        self.shootInterval=0;
    }
    
    self.MshootInterval++;
    if (self.MshootInterval==30) {
        self.MshootInterval=0;
    }
}

@end
