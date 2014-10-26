//
//  GameOverScene.h
//  ShootingPlanes
//
//  Created by 刘彦超 on 14-10-9.
//  Copyright (c) 2014年 刘彦超. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameOverScene : SKScene

@property SKLabelNode *next;

-(id)initWithSize:(CGSize)size deadplanes:(int)planesShootedDown;

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

@end
