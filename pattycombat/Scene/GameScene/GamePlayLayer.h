//
//  GamePlayLayer.h
//  PattyCakeFighter
//
//  Created by Giuseppe Lapenta on 08/09/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CommonProtocols.h"
#import "Constant.h"
#import "HUDLayer.h"
#import "Player.h"


@interface GamePlayLayer : CCLayer <PlayerDelegate, HUDDelegate>
{
    
    double    _currentTime;
    double    _elapsedTime;
    float     _bpm;
    int       _count;
    int       _gameTimeInit;
    BOOL      _isTouchInTime;

    HUDLayer* _hudLayer;
    Player*   _player;
}

@property (nonatomic, strong) Player * player;
@property (nonatomic, strong) HUDLayer* hudLayer;


-(void)gameOverHandler:(CharacterStates)gameOverState withScore:(NSNumber *)score;

@end
