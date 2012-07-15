//
//  FinalScene.m
//  pattycombat
//
//  Created by Vincenzo Lapenta on 12/04/12.
//  Copyright (c) 2012 Fratello. All rights reserved.
//

#import "FinalScene.h"
#import "FinalSceneLayer.h"

@implementation FinalScene


- (id)init
{
    self = [super init];
    if (self) {
        
        FinalSceneLayer* layer = [FinalSceneLayer node];
        
        [self addChild:layer];
        
    }
    return self;
}

@end
