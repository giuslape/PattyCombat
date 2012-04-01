//
//  GamePlayIntroLayer.h
//  PattyCombat
//
//  Created by Giuseppe Lapenta on 10/10/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameManager.h"

@interface GamePlayIntroLayer : CCLayer {
    
    CCSpriteBatchNode* _spriteBatchNode;
    CharacterStates _state;
    CGPoint _firstTouchLocInView;
    NSTimeInterval _firstTouchTimeStamp;
    
    CCSprite* _leftHand;
    CCSprite* _rightHand;
    
    BOOL _isTouchInTime;
    BOOL _isLastLevel;
    int _patternIndex;
    int _feedIndex;

}

@property (nonatomic, strong) NSMutableArray* patternArray;
@property (nonatomic, strong) NSMutableArray* feedHand;
@property (nonatomic, strong) CCAnimation* animationHandRightOk;
@property (nonatomic, strong) CCAnimation* animationHandLeftOk;
@property (nonatomic, strong) CCAnimation* animationHandRightErr;
@property (nonatomic, strong) CCAnimation* animationHandLeftErr;
@property (nonatomic, strong) CCAnimation* animationFeedLeft;
@property (nonatomic, strong) CCAnimation* animationFeedRight;


-(void)handleHitWithTouch:(CGPoint)location;
-(void)handleHitsWithTouches:(NSArray*)touches;
-(void)showButtonAndFeed;

@end
