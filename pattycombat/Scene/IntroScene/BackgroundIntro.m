//
//  BackgroundIntro.m
//  PattyCombat
//
//  Created by Giuseppe Lapenta on 10/10/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import "BackgroundIntro.h"
#import "GameManager.h"



@implementation BackgroundIntro

- (id)init {
    
    self = [super init];
    if (self) {
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        NSString* introBackground = [[[GameManager sharedGameManager]dao]loadBackgroundIntro:NSStringFromClass([self class]) atLevel:[[GameManager sharedGameManager]currentLevel]];
        
        if (introBackground) {
        
        CCSprite* background = [CCSprite spriteWithFile:introBackground];
        background.position = CGPointMake(size.width/2, size.height/2);
        [self addChild:background z:1 tag:10];
            
        }
        
        //TestFlight
        TFLog(@"Livello: %d",[[GameManager sharedGameManager]currentLevel]);
        
    }
    return self;
}

- (void)dealloc {
    
    //[self removeChildByTag:10 cleanup:YES];
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), self);

}

@end
