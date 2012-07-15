//
//  TvBackgroundLayer.m
//  pattycombat
//
//  Created by Giuseppe Lapenta on 18/04/12.
//  Copyright 2012 All rights reserved.
//

#import "TvBackgroundLayer.h"


@implementation TvBackgroundLayer


#pragma mark -
#pragma mark ===  Init Methods  ===
#pragma mark -


- (id)init
{
    self = [super init];
    if (self) {
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
       // [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite * background = [CCSprite spriteWithFile:@"tv_bg.png"];
        [self addChild:background z:0];
        [background setPosition:ccp(winSize.width/2, winSize.height/2)];
       // [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        
    }
    return self;
}

@end
