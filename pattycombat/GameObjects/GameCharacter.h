//
//  GameCharacter.h
//  PattyCakeFighter
//
//  Created by Giuseppe Lapenta on 11/08/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameObject.h"


@interface GameCharacter : GameObject {
    
   CharacterStates currentState;
}

@property(readwrite)CharacterStates currentState;

-(void)handleHit:(CGPoint)location;
-(void)handleHitsWithTouches:(NSArray*)touches;
-(void)initGame;

@end
