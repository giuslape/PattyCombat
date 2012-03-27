//
//  MenuScene.h
//  PattyCakeFighter
//
//  Created by Giuseppe Lapenta on 29/04/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import <GameKit/GameKit.h>
#import "MBProgressHUD.h"
#import "FBConnect.h"


@interface MenuLayer :CCLayer  <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate, FBSessionDelegate, FBDialogDelegate>{
    
    MBProgressHUD* _hud;
    CCMenu* _purchaseMenu;
    NSArray* _permissions;
    CCMenu* _mainMenu;
    CCSpriteBatchNode* _spriteBatchNode;
}

@property (strong)MBProgressHUD* hud;


@end
