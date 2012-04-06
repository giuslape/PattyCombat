//
//  WallLayer.h
//  PattyCombat
//
//  Created by Giuseppe Lapenta on 23/11/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CommonProtocols.h"

@interface WallLayer : CCLayer <GameplayLayerDelegate> {
    
    CCSpriteBatchNode* spriteBatchNode;
    
    CCAnimation* touchAnimation;
    
    CGSize size;
}

@property(nonatomic, strong) CCAnimation* touchAnimation;



@end
