//
//  MenuScene.m
//  PattyCombat
//
//  Created by Giuseppe Lapenta on 15/11/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import "MenuScene.h"
#import "MenuLayer.h"


@implementation MenuScene


- (id)init {
    self = [super init];
    if (self) {
                
        MenuLayer* menuLayer = [MenuLayer node];
        [self addChild:menuLayer z:0];
        
             
    }
    return self;
}

@end
