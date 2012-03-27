//
//  CarScene.m
//  PattyCombat
//
//  Created by Giuseppe Lapenta on 04/12/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import "CarScene.h"
#import "CarBackgroundLayer.h"
#import "CarGamePlayLayer.h"


@implementation CarScene

- (id)init {
    self = [super init];
    if (self) {
        
        CarBackgroundLayer* backgroundLayer = [CarBackgroundLayer node];
        
        [self addChild:backgroundLayer z:0];
        
        CarGamePlayLayer* gamePlayLayer = [CarGamePlayLayer node];
        
        [self addChild:gamePlayLayer z:1];
        
    }
    return self;
}

@end
