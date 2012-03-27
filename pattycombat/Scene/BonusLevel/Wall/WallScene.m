//
//  WallScene.m
//  PattyCombat
//
//  Created by Giuseppe Lapenta on 23/11/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import "WallScene.h"
#import "WallLayer.h"
#import "WallLayerBackground.h"


@implementation WallScene


- (id)init {
    self = [super init];
    
    if (self) {
        
        WallLayerBackground* background = [WallLayerBackground node];
        
        [self addChild:background z:0];
        
        WallLayer* layer = [WallLayer node];
        
        [self addChild:layer z:1];
        
    }
    return self;
}
@end
