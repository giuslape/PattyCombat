//
//  EndScene.m
//  PattyCombat
//
//  Created by Giuseppe Lapenta on 08/10/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import "EndScene.h"
#import "EndLayer.h"


@implementation EndScene

- (id)init {
    self = [super init];
    if (self) {
        
        EndLayer* layer = [EndLayer node];
        [self addChild:layer];
        
    }
    return self;
}

@end
