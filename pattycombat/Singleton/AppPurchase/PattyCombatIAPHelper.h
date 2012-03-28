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
#define kProductPurchaseFacebookCoins @"facebook"
#define kProductPurchase25coins @"com.tadaa.pattycombat.purchase.25coins"
#define kProductPurchse75coins @"com.tadaa.pattycombat.purchase.75coins"
#define kProductPurchase200coins @"com.tadaa.pattycombat.purchase.200coins"


@interface PattyCombatIAPHelper : IAPHelper

+ (PattyCombatIAPHelper *) sharedHelper;

-(NSInteger)quantity;
-(NSInteger)updateQuantityForProductIdentifier:(NSString *)productIdentifier;
-(void)coinWillUsed;

@end
