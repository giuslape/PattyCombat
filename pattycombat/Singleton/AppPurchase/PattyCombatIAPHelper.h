//
//  PattyCombatIAPHelper.h
//  PattyCombat
//
//  Created by Vincenzo Lapenta on 15/03/12.
//  Copyright (c) 2012 Fratello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAPHelper.h"

#define kQuantityProductPurchased @"quantity"
#define kProductPurchase5coins @"com.tadaa.pattycombat.fivecoins"
#define kProductTest @"com.tadaa.pattycombat.test3"
#define kProductTest4 @"com.tadaa.pattycombat.test4"


@interface PattyCombatIAPHelper : IAPHelper

+ (PattyCombatIAPHelper *) sharedHelper;

-(NSInteger)quantity;
-(NSInteger)updateQuantityForProduct:(NSString *)productIdentifier;
-(void)coinWillUsed;

@end
