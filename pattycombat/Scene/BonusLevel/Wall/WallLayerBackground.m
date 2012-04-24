//
//  WallLayerBackground.m
//  PattyCombat
//
//  Created by Giuseppe Lapenta on 23/11/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import "WallLayerBackground.h"


@implementation WallLayerBackground


- (id)init {
    self = [super init];
    if (self) {
        
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        

        CCSprite * background = [CCSprite spriteWithFile:@"muretto_bg.png"];
        
        [self addChild:background z:0];

        
        [background setPosition:ccp(winSize.width/2, winSize.height/2)];
        
    }
    return self;
}

@end
