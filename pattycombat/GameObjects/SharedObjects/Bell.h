//
//  Bell.h
//  PattyCombat
//
//  Created by Giuseppe Lapenta on 08/10/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameCharacter.h"
#import "CommonProtocols.h"

@protocol BellDelegate

-(void)bellDidFinish:(id)bell;

@end

@interface Bell : GameCharacter {
    
    CCAnimation* _bellAnimation;
    CCAnimation* _gongAnimation;
    
    __weak id <BellDelegate> _delegate;
}

@property (nonatomic, strong)CCAnimation* bellAnimation;
@property (nonatomic, strong)CCAnimation* gongAnimation;
@property (nonatomic, weak) id <BellDelegate> delegate;

@end


