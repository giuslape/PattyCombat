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
#import "CreditsLayer.h"


@interface MenuLayer :CCLayer  <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate, FBSessionDelegate, FBDialogDelegate, UIAlertViewDelegate, CreditsLayerProtocol>{
    
    MBProgressHUD* _hud;
    CCMenu* _purchaseMenu;
    NSArray* _permissions;
    CCLayerGradient* _darkLayer;
    
    float _elapsedTime;
    float _neonEffectInterval;

}

@property (strong)MBProgressHUD* hud;


@end
