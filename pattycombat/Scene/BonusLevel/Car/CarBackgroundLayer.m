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
        
     //   [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        
        CCSprite * background = [CCSprite spriteWithFile:@"pickup_bg.png"];
        
        [self addChild:background z:0];
        
       // [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

        [background setPosition:ccp(winSize.width/2, winSize.height/2)];
        
    }
    return self;
}

@end
