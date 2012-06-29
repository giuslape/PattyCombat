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
#define kProductPurchase25coins @"com.tadaa.pattycombat.purchase.25coins"
#define kProductPurchse75coins @"com.tadaa.pattycombat.purchase.75coins"
#define kProductPurchase200coins @"com.tadaa.pattycombat.purchase.200coins"
#define kProductTest @"com.tadaa.pattycombat.purchase.test7"


@interface PattyCombatIAPHelper : IAPHelper

+ (PattyCombatIAPHelper *) sharedHelper;

-(NSInteger)quantity;
-(void)updateQuantityForProductIdentifier:(NSString *)productIdentifier;
-(void)coinWillUsedinView:(UIView *)view forProductIdentifier:(NSString *)productId;

@end
