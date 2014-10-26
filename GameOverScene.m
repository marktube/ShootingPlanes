//
//  GameOverScene.m
//  ShootingPlanes
//
//  Created by 刘彦超 on 14-10-9.
//  Copyright (c) 2014年 刘彦超. All rights reserved.
//

#import "GameOverScene.h"
#import "MyScene.h"

@implementation GameOverScene

-(id)initWithSize:(CGSize)size deadplanes:(int)planesShootedDown{
    if (self = [super initWithSize:size]) {
        // 1
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        // 2
        NSString * message = [[NSString alloc]initWithFormat:@"胜败乃兵家常事，大侠您已打掉%d只飞机" ,planesShootedDown];
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        label.text = message;
        label.fontSize = 40;
        label.fontColor = [SKColor blackColor];
        label.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:label];
        
        NSString * m2 = @"我要报仇!";
        self.next = [SKLabelNode labelNodeWithFontNamed:@"Xingkai SC Light"];
        self.next.text = m2;
        self.next.fontSize = 50;
        self.next.fontColor = [SKColor redColor];
        self.next.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/3);
        [self addChild:self.next];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    //定位触控点位置
    
    SKSpriteNode* touchedNode = (SKSpriteNode*)[self nodeAtPoint:location];
    if ([self.next isEqual:touchedNode]) {
        [self runAction:
         [SKAction sequence:@[[SKAction runBlock:^{
             SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
             SKScene * myScene = [[MyScene alloc] initWithSize:self.size];
             [self.view presentScene:myScene transition: reveal];
         }]
                              ]]
         ];
    }
}

@end
