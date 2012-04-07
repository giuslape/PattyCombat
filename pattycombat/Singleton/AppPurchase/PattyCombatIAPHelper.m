//
//  PattyCombatIAPHelper.m
//  PattyCombat
//
//  Created by Giuseppe Lapenta on 15/03/12.
//  Copyright (c) 2012 Fratello. All rights reserved.
//

#import "PattyCombatIAPHelper.h"

@implementation PattyCombatIAPHelper


static PattyCombatIAPHelper * _sharedHelper;

+(PattyCombatIAPHelper *)sharedHelper{
    
    if (_sharedHelper != nil) {
        return _sharedHelper;
    }
    _sharedHelper = [[PattyCombatIAPHelper alloc] init];
    return _sharedHelper;
    
}


- (id)init
{
    NSSet *productIdentifiers = [NSSet setWithObjects:kProductPurchase25coins,kProductPurchse75coins,kProductPurchase200coins,kProductTest, nil];
    
    if ((self = [super initWithProductIdentifiers:productIdentifiers])) {}
    return self;
}

-(NSInteger)quantity{
    
    NSInteger quantity = 0;
    quantity = [[NSUserDefaults standardUserDefaults] integerForKey:kQuantityProductPurchased];
    return quantity;
}


-(void)updateQuantityForProductIdentifier:(NSString *)productIdentifier{
    
    NSInteger quantity = 0;
    NSInteger constant = 0;
    NSInteger value = 0;
    
    value = [self quantity];
    
    if ([productIdentifier isEqualToString:kProductPurchaseFacebookCoins]) constant = 3;
        else if ([productIdentifier isEqualToString:kProductPurchase25coins])constant = 1;
            else if([productIdentifier isEqualToString:kProductPurchse75coins]) constant = 75;
                    else if ([productIdentifier isEqualToString:kProductPurchase200coins])constant = 200;
    
    quantity = constant + value;
    
    [[NSUserDefaults standardUserDefaults] setInteger:quantity forKey:kQuantityProductPurchased];  
    [[NSUserDefaults standardUserDefaults] synchronize];
        
}

-(void)coinWillUsed{
    
    int quantity = [self quantity];
    
    if (quantity > 0) {
        
        quantity--;
        [[NSUserDefaults standardUserDefaults] setInteger:quantity forKey:kQuantityProductPurchased];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

@end
