//
//  GameScene.m
//  PattyCakeFighter
//
//  Created by Giuseppe Lapenta on 26/05/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene



- (id)init {
    
    self = [super init];
    
    if (self) {
        
        BackgroundGameLayer* layer = [BackgroundGameLayer node];
        
        [self addChild:layer z:0];
               
        GamePlayLayer* gamePlayLayer = [GamePlayLayer node];
        
        [self addChild:gamePlayLayer z:5];
        
        HUDLayer* hudLayer = [HUDLayer node];
        
        [self addChild:hudLayer z:6 tag:10];
        
        gamePlayLayer.hudLayer = hudLayer;
        
        [hudLayer setDelegate:gamePlayLayer];
        
    }
    return self;
}


@end
