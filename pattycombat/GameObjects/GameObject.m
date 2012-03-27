//
//  GameObject.m
//  PattyCakeFighter
//
//  Created by Giuseppe Lapenta on 10/08/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import "GameObject.h"


@implementation GameObject

@synthesize gameObjectType, characterState, screenSize;

-(void)changeState:(NSNumber *)newState {
    //si può sovrascrivere
}

-(void)updateStateWithDeltaTime:(ccTime)deltaTime {
    //si può sovrascrivere
}


-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
    if( (self=[super initWithTexture:texture rect:rect])){
        
        CCLOG(@"GameObject init");
        screenSize = [CCDirector sharedDirector].winSize;
        isActive = TRUE;
        gameObjectType = kObjectTypeNone;
    }
    return self;
}


@end
