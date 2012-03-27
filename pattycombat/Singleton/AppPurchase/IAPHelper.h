//
//  IAPHelper.h
//  PattyCombat
//
//  Created by Vincenzo Lapenta on 15/03/12.
//  Copyright (c) 2012 Fratello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StoreKit/StoreKit.h"

#define kProductsLoadedNotification         @"ProductsLoaded"
#define kProductPurchasedNotification       @"ProductPurchased"
#define kProductPurchaseFailedNotification  @"ProductPurchaseFailed"

@interface IAPHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
    NSSet * _productIdentifiers;    
    NSArray * _products;
    NSMutableSet * _purchasedProducts;
    SKProductsRequest * _request;
}

@property (strong) NSSet *productIdentifiers;
@property (strong) NSArray * products;
@property (strong) NSMutableSet *purchasedProducts;
@property (strong) SKProductsRequest *request;

- (void)requestProducts;
- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)buyProductIdentifier:(SKProduct *)productIdentifier;


@end