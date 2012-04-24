//
//  CarBackgroundLayer.m
//  PattyCombat
//
//  Created by Giuseppe Lapenta on 04/12/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import "CarBackgroundLayer.h"


@implementation CarBackgroundLayer


- (id)init {
    self = [super init];
    if (self) {
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        

        CCSprite * background = [CCSprite spriteWithFile:@"pickup_bg.png"];
        
        [self addChild:background z:0];

        [background setPosition:ccp(winSize.width/2, winSize.height/2)];
        
    }
    return self;
}

@end
