//
//  FinalSceneLayer.h
//  pattycombat
//
//  Created by Vincenzo Lapenta on 12/04/12.
//  Copyright (c) 2012 Fratello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CreditsLayer.h"

@interface FinalSceneLayer : CCLayer <CreditsLayerProtocol>{
    
    CGSize size;
    
    CCLabelBMFont* _text;
    
    CCSprite* cloud1;
    CCSprite* cloud2;
}

@end
