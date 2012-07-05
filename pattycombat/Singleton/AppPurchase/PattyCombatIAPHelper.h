//
//  PattyCombatIAPHelper.h
//  PattyCombat
//
//  Created by Giuseppe Lapenta on 15/03/12.
//  Copyright (c) 2012 Fratello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAPHelper.h"

#define kQuantityProductPurchased @"quantity"
#define kProductPurchaseSocialCoins @"social"
#define kProductPurchase30coins @"com.tadaa.pattycombat.purchase.30coins"
#define kProductPurchase90coins @"com.tadaa.pattycombat.purchase.90coins"
#define kProductPurchase300coins @"com.tadaa.pattycombat.purchase.300coins"
#define kProductTest @"com.tadaa.pattycombat.purchase.test7"


@interface PattyCombatIAPHelper : IAPHelper

+ (PattyCombatIAPHelper *) sharedHelper;

-(NSInteger)quantity;
-(void)updateQuantityForProductIdentifier:(NSString *)productIdentifier;
-(BOOL)coinWillUsedinView:(UIView *)view forProductIdentifier:(NSString *)productId;

@end
