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
#if __has_feature(objc_arc_weak)
    __weak id <BellDelegate> _delegate;
#elif __has_feature(objc_arc)
    __unsafe_unretained id <BellDelegate> _delegate;
#else
     id <BellDelegate> _delegate;
#endif
}

@property (nonatomic, strong)CCAnimation* bellAnimation;
@property (nonatomic, strong)CCAnimation* gongAnimation;

#if __has_feature(objc_arc_weak)
@property (nonatomic, weak) id <BellDelegate> delegate;
#elif __has_feature(objc_arc)
@property (nonatomic, unsafe_unretained) id <BellDelegate> delegate;
#else
@property (nonatomic, assign) id <BellDelegate> delegate;
#endif


@end


