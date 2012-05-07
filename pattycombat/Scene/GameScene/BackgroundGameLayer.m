//
//  BackgroundGameLayer.m
//  PattyCombat
//
//  Created by Giuseppe Lapenta on 12/11/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import "BackgroundGameLayer.h"
#import "GameManager.h"


@implementation BackgroundGameLayer

- (id)init {
    
    self = [super init];
    if (self) {

        CGSize size = [[CCDirector sharedDirector]winSize];
        
       NSString* backgroundName = [[[GameManager sharedGameManager]dao]loadBackgroundGame:NSStringFromClass([self class]) atLevel:[[GameManager sharedGameManager]currentLevel]];
        
        if (backgroundName) {
            
        //    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
            CCSprite* background = [CCSprite spriteWithFile:backgroundName];
            background.position = CGPointMake(size.width/2, size.height/2);
            [self addChild:background z:1 tag:10];
         //   [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        }
    }
    return self;
}


- (void)dealloc {
    
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), self);

}
@end
