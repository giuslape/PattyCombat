//
//  IntroScene.m
//  PattyCakeFighter
//
//  Created by Giuseppe Lapenta on 19/05/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import "IntroScene.h"
#import "BackgroundIntro.h"
#import "GamePlayIntroLayer.h"

@implementation IntroScene



- (id)init {
    
    if ((self = [super init])) {
        
        CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
        
        BackgroundIntro* introBackground = [BackgroundIntro node];
        [self addChild:introBackground z:0];
        
        GamePlayIntroLayer* gamePlayIntroLayer = [GamePlayIntroLayer node];
        [self addChild:gamePlayIntroLayer z:5];
    }
    return self;
}



@end
