//
//  GameObject.h
//  PattyCakeFighter
//
//  Created by Giuseppe Lapenta on 10/08/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CommonProtocols.h"
#import "Constant.h"

@interface GameObject : CCSprite {
    
    GameObjectType gameObjectType;
    CharacterStates characterState;
    CGSize screenSize;
    BOOL isActive;

}

@property (readwrite) GameObjectType gameObjectType;
@property (readwrite) CharacterStates characterState;
@property (readwrite) CGSize screenSize;


-(void)changeState:(NSNumber *)newState; 
-(void)updateStateWithDeltaTime:(ccTime)deltaTime;


@end
