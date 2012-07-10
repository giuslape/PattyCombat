//
//  EndLayer.h
//  PattyCombat
//
//  Created by Giuseppe Lapenta on 08/10/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameState.h"
#import "UIAlertTableView.h"



@interface EndLayer : CCLayer <UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    
    CGSize size;
    
    CCSpriteBatchNode* _spriteBatchNode;
    
    UIAlertTableView* _alert;
    
    NSString* _productId;
    
    int _totalGameScore;
    int _currentLevelScore;
    int _bestScore;
    int _timeBonus;
    int _scoreUp;
    int _scoreUpTimeBonus;
    int _scoreUpTotalScore;
    
    BOOL _thresholdReached;
    BOOL _isKo;
    BOOL _isPerfect;
}

@property (nonatomic, strong)CCLabelBMFont* labelScore;
@property (nonatomic, strong)CCLabelBMFont* labelTimeBonus;
@property (nonatomic, strong)CCLabelBMFont* labelTotalScore;


-(void)sendAchievementsForLevel:(int)currentLevel;

@end
