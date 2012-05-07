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
    
#if __has_feature(objc_arc_weak)
    __weak id <CreditsLayerProtocol> _delegate;
#elif __has_feature(objc_arc)
    __unsafe_unretained id <CreditsLayerProtocol> _delegate;
#else
        id <CreditsLayerProtocol> _delegate;   
#endif

}

#if __has_feature(objc_arc_weak)
@property (nonatomic, weak) id <CreditsLayerProtocol> delegate;
#elif __has_feature(objc_arc)
@property (nonatomic, unsafe_unretained) id <CreditsLayerProtocol> delegate;
#else
@property (nonatomic, assign) id <CreditsLayerProtocol> delegate;
#endif


@end
