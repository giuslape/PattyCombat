//
//  CarGamePlayLayer.h
//  PattyCombat
//
//  Created by Giuseppe Lapenta on 04/12/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Constant.h"
#import "CommonProtocols.h"

@interface CarGamePlayLayer : CCLayer <GameplayLayerDelegate>{
    
    CCSpriteBatchNode* spriteBatchNode;
    
    CCAnimation* touchAnimation;
    
    CGSize size;
    
}

@property(nonatomic, strong)CCAnimation* touchAnimation;


@end
