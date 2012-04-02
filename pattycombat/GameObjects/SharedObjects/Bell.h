//
//  Bell.h
//  PattyCombat
//
//  Created by Giuseppe Lapenta on 08/10/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameCharacter.h"
#import "CommonProtocols.h"

@class Bell;

@protocol BellDelegate

-(void)bellDidFinishTime:(Bell *)bell;

@optional
-(void)bellDidInitGong:(Bell *)bell;
-(void)bellDidFinishGong:(Bell *)bell;
@end


@interface Bell : GameCharacter {
    
    float _elapsedTime;
    float _delayBetweenFrames;
    float _oldElapsedTime;
    float _gameTime;
    
    int   _currentFrame;
    BOOL  _isBonusLevel;
    
    CCAnimation* _bellAnimation;
    CCAnimation* _gongAnimation;
    
    __weak id <BellDelegate> _delegate;
}

@property (nonatomic, strong)CCAnimation* bellAnimation;
@property (nonatomic, strong)CCAnimation* gongAnimation;
@property (nonatomic, weak) id <BellDelegate> delegate;

@end


