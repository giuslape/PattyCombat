//
//  BonusLevel.h
//  pattycombat
//
//  Created by Vincenzo Lapenta on 18/04/12.
//  Copyright 2012 Fratello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CommonProtocols.h"
#import "Constant.h"

#define kAnimationTouch 100
#define kHandNext 103
#define kLabelCountDown 300

@interface BonusLevel : CCLayer <GameplayLayerDelegate> {
 
    CCSpriteBatchNode* spriteBatchNode;
    
    CCAnimation* touchAnimation;
    
    int indexSprite;
    int scoreUp;
    int touchCount;
    int score;
    int scoreDown;
    int totalScore;
    BOOL isFinish;

    CGSize size;

}

@property(nonatomic, strong) CCAnimation* touchAnimation;

@end
