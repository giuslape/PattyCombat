//
//  TvScene.m
//  pattycombat
//
//  Created by Vincenzo Lapenta on 18/04/12.
//  Copyright 2012 Fratello. All rights reserved.
//

#import "TvScene.h"
#import "TvBackgroundLayer.h"
#import "TvGamePlayLayer.h"

@implementation TvScene


- (id)init
{
    self = [super init];
    if (self) {
        
        TvBackgroundLayer* background = [TvBackgroundLayer node];
        
        [self addChild:background];
        
        TvGamePlayLayer* layerGamePlay = [TvGamePlayLayer node];
        
        [self addChild:layerGamePlay];
        
    }
    return self;
}

@end
