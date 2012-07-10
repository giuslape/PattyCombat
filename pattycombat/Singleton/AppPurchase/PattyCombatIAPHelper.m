//
//  PattyCombatIAPHelper.m
//  PattyCombat
//
//  Created by Giuseppe Lapenta on 15/03/12.
//  Copyright (c) 2012 Fratello. All rights reserved.
//

#import "PattyCombatIAPHelper.h"
#import "Reachability.h"
#import "MBProgressHUD.h"

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
    NSSet *productIdentifiers = [NSSet setWithObjects:kProductPurchase30coins,kProductPurchase90coins,kProductPurchase300coins,kProductTest, nil];
    
    bool firstCoin = [[NSUserDefaults standardUserDefaults] boolForKey:@"FirstCoin"];
    
    if (!firstCoin) {
        
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:kQuantityProductPurchased];  
        firstCoin = YES;
        [[NSUserDefaults standardUserDefaults] setBool:firstCoin forKey:@"FirstCoin"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
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
    
    if ([productIdentifier isEqualToString:kProductPurchaseSocialCoins]) constant = 5;
        else if ([productIdentifier isEqualToString:kProductPurchase30coins])constant = 30;
            else if([productIdentifier isEqualToString:kProductPurchase90coins]) constant = 90;
                    else if ([productIdentifier isEqualToString:kProductPurchase300coins])constant = 300;
    
    quantity = constant + value;
    
    [[NSUserDefaults standardUserDefaults] setInteger:quantity forKey:kQuantityProductPurchased];  
    [[NSUserDefaults standardUserDefaults] synchronize];
        
}

-(BOOL)coinWillUsedinView:(UIView *)view forProductIdentifier:(NSString *)productId{
    
    int quantity = [self quantity];
    
    if (quantity > 0) {
        
        quantity--;
        [[NSUserDefaults standardUserDefaults] setInteger:quantity forKey:kQuantityProductPurchased];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
    
    if (quantity == 0) {
        
        // Check if internet connection is available 
        
            Reachability *reach = [Reachability reachabilityForInternetConnection];	
            NetworkStatus netStatus = [reach currentReachabilityStatus];    
            if (netStatus == NotReachable) { 
                
                NSLog(@"No internet connection!");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" 
                                                                message:@"No internet Connection" 
                                                               delegate:nil 
                                                      cancelButtonTitle:@"OK" 
                                                      otherButtonTitles:nil];
                [alert show];
                return NO;
                
            } else if (self.products == nil) {
                
                [self requestProducts];
                MBProgressHUD* _hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
                _hud.labelText = @"Loading coins...";
                [self performSelector:@selector(timeout:) withObject:view afterDelay:60.0f];
                
            }else {
                
                if ([self.products count] > 0) {
                    
                MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
                hud.labelText = @"Buying Coins";
                [self buyProductIdentifier:productId];
                [self performSelector:@selector(timeout:) withObject:view afterDelay:60.0f];
                    
                } else if ([self.products count] == 0)
                    return NO;
            }
    } 
    return YES;
}

- (void)dismissHUD:(id)arg {
    
    [MBProgressHUD hideHUDForView:arg animated:YES];
    
}

- (void)timeout:(id)arg {
    
    arg = (UIView *)arg;
    [self performSelector:@selector(dismissHUD:) withObject:arg afterDelay:1];
    
}

@end
