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
    NSSet *productIdentifiers = [NSSet setWithObjects:kProductTest4, nil];
    
    if ((self = [super initWithProductIdentifiers:productIdentifiers])) {}
    return self;
}

-(NSInteger)quantity{
    
    NSInteger quantity = 0;
    quantity = [[NSUserDefaults standardUserDefaults] integerForKey:kQuantityProductPurchased];
    return quantity;
}


-(NSInteger)updateQuantityForProduct:(NSString *)productIdentifier{
    
    NSInteger quantity = 0;
    NSInteger constant = 0;
    NSInteger value = 0;
    
    value = [self quantity];
    
    if ([productIdentifier isEqualToString:kProductPurchase5coins])constant = 5;
    
    quantity = constant + value;
    
    [[NSUserDefaults standardUserDefaults] setInteger:quantity forKey:kQuantityProductPurchased];  
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return quantity;
    
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
