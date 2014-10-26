//
//  MyScene.h
//  ShootingPlanes
//

//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface MyScene : SKScene

- (void)addMonster;

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast;

- (void)toShoot;

- (void)enemyShoot:(SKSpriteNode *) monster;

- (void)projectile:(SKSpriteNode *)projectile didCollideWithMonster:(SKSpriteNode *)monster;

- (void)gameOver;

@end
