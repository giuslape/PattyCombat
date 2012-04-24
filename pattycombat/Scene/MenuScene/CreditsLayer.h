//
//  CreditsLayer.h
//  pattycombat
//
//  Created by Giuseppe Lapenta on 22/04/12.
//  Copyright 2012. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class CreditsLayer;

@protocol CreditsLayerProtocol

@required
-(void)creditsLayerDidClose:(CreditsLayer *)layer;
@end

@interface CreditsLayer : CCLayerColor {
    
    __weak id <CreditsLayerProtocol> _delegate;
}

@property (nonatomic, weak) id <CreditsLayerProtocol> delegate;

@end
