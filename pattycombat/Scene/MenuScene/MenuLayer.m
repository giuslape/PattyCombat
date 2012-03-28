//
//  MenuScene.m
//  PattyCakeFighter
//
//  Created by Giuseppe Lapenta on 29/04/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import "MenuLayer.h"
#import "IntroScene.h"
#import "SimpleAudioEngine.h"
#import "GameManager.h"
#import "GCHelper.h"
#import "PattyCombatIAPHelper.h"
#import "Reachability.h"
#import "AppDelegate.h"
#import <Twitter/Twitter.h>
#import "CCMenuItemSpriteIndependent.h"

@interface MenuLayer ()

@property CGSize size;
@property (nonatomic, strong)CCSprite* play;
@property (nonatomic, strong)CCSprite* highScores;
@property (nonatomic, strong)CCSprite* credits;

-(void) goBack;
-(void)playGame;
-(void)itemStatsTouched;
-(void)itemGetCoinsTouched;
-(void)showAchievements;
-(void)showLeaderboard;
@end


@implementation MenuLayer

@synthesize size;
@synthesize play,highScores,credits;
@synthesize hud = _hud;

#pragma mark -
#pragma mark ===  Dealloc  ===
#pragma mark -

- (void)dealloc {
    
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    
    [[GameManager sharedGameManager] stopBackgroundMusic];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProductsLoadedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProductPurchaseFailedNotification object:nil];
    
    
}

#pragma mark -
#pragma mark === Init ===
#pragma mark -


-(void)buildGetCoins{
        
    //Add background
    
    CCSprite* getCoinsBackground = [CCSprite spriteWithFile:@"menu_01.png"];
    [self addChild:getCoinsBackground z:kGetCoinsBackgroundZValue tag:kGetCoinsBackgroundTagValue];
    [getCoinsBackground setPosition:ccp(-size.width/2, size.height/2)];
    
    //Label Coins Purchased
    
    CCLabelBMFont* labelCoinsPurchased = [CCLabelBMFont labelWithString:@"Coins" fntFile:FONTHIGHSCORES];
    [labelCoinsPurchased setPosition:ccp(size.width * 0.8, size.height * 0.4)];
    [getCoinsBackground addChild:labelCoinsPurchased];
    
    //Number of product purchased
    
    int quantity = [[PattyCombatIAPHelper sharedHelper] quantity];
    
    CCLabelBMFont* labelQuantity =
    [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d",quantity]
                           fntFile:FONTHIGHSCORES];
    
    [getCoinsBackground addChild:labelQuantity z:kLabelCoinsReachedZValue tag:kLabelCoinsReachedTagValue];
    [labelQuantity setPosition:ccp(size.width * 0.8, size.height * 0.3)];
    
    
    //  Store Button for post to Social Network
    
    CCSprite* facebook = [CCSprite spriteWithSpriteFrameName:@"store1_btn.png"];
    CCSprite* facebookSelected = [CCSprite spriteWithSpriteFrameName:@"store1_btn_over.png"];
    
    
    CCMenuItemSprite* facebookButton = 
    [CCMenuItemSprite  itemWithNormalSprite:facebook selectedSprite:facebookSelected block:^(id sender) {
        
        // Alert View for choise Social Network where post.
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Social Network" 
                                                            message:@""
                                                           delegate:self 
                                                  cancelButtonTitle:@"Cancel" 
                                                  otherButtonTitles:@"Facebook",@"Twitter", nil];
        
        
        [alertView show];
        //[self postToFacebook:self];
        
    }];
                                            
    facebookButton.tag = kFacebookItemTagValue;
    
    // Store Button 25 coins
    
    CCSprite* firstPurchase = [CCSprite spriteWithSpriteFrameName:@"store2_btn.png"];
    CCSprite* firstPurchaseSelected = [CCSprite spriteWithSpriteFrameName:@"store2_btn_over.png"];
    
    CCMenuItemSprite* firstPurchaseButton = 
    [CCMenuItemSprite  itemWithNormalSprite:firstPurchase
                            selectedSprite:firstPurchaseSelected
                                    target:self 
                                        selector:@selector(buyButtonTapped:)];
    
    firstPurchaseButton.tag = kFirstPurchaseItemTagValue;
    firstPurchase.opacity = 100;

    // Store Button 75 coins
    
    CCSprite* secondPurchase = [CCSprite spriteWithSpriteFrameName:@"store3_btn.png"];
    CCSprite* secondPurchaseSelected = [CCSprite spriteWithSpriteFrameName:@"store3_btn_over.png"];
    
    CCMenuItemSprite* secondPurchaseButton = 
    [CCMenuItemSprite itemWithNormalSprite:secondPurchase 
                                       selectedSprite:secondPurchaseSelected 
                                            target:self 
                                                selector:@selector(buyButtonTapped:)];
    
    secondPurchaseButton.tag = kSecondPurchaseItemTagValue;
    secondPurchase.opacity = 100;
    
    // Store Button 200 coins
    
    CCSprite* thirdPurchase = [CCSprite spriteWithSpriteFrameName:@"store4_btn.png"];
    CCSprite* thirdPurchaseSelected = [CCSprite spriteWithSpriteFrameName:@"store4_btn_over.png"];
    
    CCMenuItemSprite* thirdPurchaseButton =
    [CCMenuItemSprite   itemWithNormalSprite:thirdPurchase 
                                        selectedSprite:thirdPurchaseSelected 
                                             target:self 
                                                 selector:@selector(buyButtonTapped:)];
    
    thirdPurchaseButton.tag = kThirdPurchaseItemTagValue;
    thirdPurchase.opacity = 100;
    
    // Add Purchase Menu
    
    _purchaseMenu = [CCMenu menuWithItems:facebookButton,firstPurchaseButton,secondPurchaseButton,thirdPurchaseButton,nil];

    [getCoinsBackground addChild:_purchaseMenu];
    
    _purchaseMenu.position = ccp(size.width * 0.23, size.height * 0.4);
    
    [_purchaseMenu alignItemsVerticallyWithPadding:3];
    
    _purchaseMenu.isTouchEnabled = NO;
    
}

-(void)buildStats{
    
    CCSprite* highscoresBackground = [CCSprite spriteWithFile:@"menu_03.png"];
    [self addChild:highscoresBackground z:1 tag:kHighScoresTag];
    [highscoresBackground setPosition:ccp(1.5*size.width, size.height/2)];
    
    int highScore = [[GameManager sharedGameManager] bestScore];

    CCLabelBMFont* highScoreLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d", highScore] fntFile:FONTHIGHSCORES];
    [highScoreLabel setAnchorPoint:ccp(0.5,0.5)];
    [highScoreLabel setPosition:ccp(125, 155)];
    [highScoreLabel setScale:1.5];
    [highscoresBackground addChild:highScoreLabel z:1 tag:kHighScoreLabelTagValue];
    
    
    CCSprite* reset = [CCSprite spriteWithSpriteFrameName:@"reset_btn.png"];
    [reset setPosition:ccp(435,15)];
    [highscoresBackground addChild:reset z:1 tag:kResetTagValue];
    
    CCLabelBMFont* nextNameLabel = [CCLabelBMFont labelWithString:@"Achievements" fntFile:FONTHIGHSCORES];
    [nextNameLabel setScale:0.5];

    CCMenuItemAtlasFont* menuAchievement = [CCMenuItemAtlasFont itemWithLabel:nextNameLabel target:self selector:@selector(showAchievements)];
    
    CCLabelBMFont* leaderboard = [CCLabelBMFont labelWithString:@"Leaderboard" fntFile:FONTHIGHSCORES];
    [nextNameLabel setScale:0.5];
    
    CCMenuItemAtlasFont* menuLeaderboard = [CCMenuItemAtlasFont itemWithLabel:leaderboard target:self selector:@selector(showLeaderboard)];
    CCMenu* optionMenu = [CCMenu menuWithItems:menuAchievement,menuLeaderboard, nil];
    [optionMenu setPosition:ccp(125, 72)];
    [optionMenu alignItemsVertically];
    [highscoresBackground addChild:optionMenu z:3 tag:kNextLevelLabelTagValue];
    
}



-(id) init
{
	if ((self = [super init]))
        
	{
        
        // Reset First Post (for Test)
        
       /* [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FirstPost"];
        [[NSUserDefaults standardUserDefaults] synchronize];*/
        
        
        // Add Sprite at cache 
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"MenuAtlas.plist"];
        
        _spriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"MenuAtlas.png"];
        
        [self addChild:_spriteBatchNode z:kSpriteBatchNodeMenuZValue];
        
        _spriteBatchNode.anchorPoint = ccp(0, 0);
        
        _spriteBatchNode.position = ccp(0,0);
        
        AppController* delegate = (AppController *)[[UIApplication sharedApplication] delegate];
        
        [[delegate facebook] setSessionDelegate:self];
        
        size = [[CCDirector sharedDirector] winSize];
        
        // Main Menu
        
        CCSprite* background1 = [CCSprite spriteWithFile:@"menu_02.png"];
        [self addChild:background1 z:0 tag:kMenuSpriteTag];
        [background1 setPosition:ccp(size.width/2, size.height/2)];
        
        // Actor Myagi
        
        CCSprite* myagi = [CCSprite spriteWithFile:@"myagi.png"];
        
        myagi.anchorPoint = ccp(0, 1);
        
        myagi.position = ccp(size.width - 20, 0);
        
        [self addChild:myagi z:0 tag:13];
        
        // Build Menu GetCoins
        
        [self buildGetCoins];
        
        // Build Menu Stats
        
        [self buildStats];
        
        // Add Observer for Purchase Notification
                
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:kProductPurchasedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(productPurchaseFailed:) name:kProductPurchaseFailedNotification object: nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productsLoaded:) name:kProductsLoadedNotification object:nil];       
        
	}
	return self;
}

#pragma mark On Enter 

-(void)onEnterTransitionDidFinish{
    
    [[GameManager sharedGameManager] playBackgroundTrack:BACKGROUND_TRACK_MAIN_MENU];
    
    CCSprite* myagi = (CCSprite*)[self getChildByTag:13];
    
    CCRotateBy* rotate = [CCRotateBy actionWithDuration:0.2 angle:-180];
    
    id move = [CCMoveBy actionWithDuration:0.05f position:CGPointMake(5, 0)];
    id movereverse = [move reverse];
    
    [myagi runAction:[CCSequence actions:rotate,[CCRepeat actionWithAction:[CCSequence actions:move,movereverse, nil] times:1], nil]];
    
    [self scheduleUpdate];
    
}




#pragma mark -
#pragma mark === Touch Dispatcher ===
#pragma mark -

-(void) registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:-1
     
                                              swallowsTouches:YES];
}

-(BOOL)ccTouchBegan:(UITouch*)touch withEvent:(UIEvent *)event
{
	CGPoint touchLocation = [touch locationInView:[touch view]];
    
    touchLocation = [[CCDirector sharedDirector]convertToGL:touchLocation];
    
    touchLocation = [self convertToNodeSpace:touchLocation];
    
    CCSprite* mainMenuSprite = (CCSprite*)[self getChildByTag:kMenuSpriteTag];
    CCSprite* background = (CCSprite *)[self getChildByTag:kHighScoresTag];
    
    CGRect boundingBox = CGRectMake(900, 0, 50, 50);
    
    CCLOG(@"Touch: %@",NSStringFromCGPoint(touchLocation));

    
    if (CGRectContainsPoint([play boundingBox], touchLocation)) {
        
        [self playGame];
                
        return YES;
        
    }else if(CGRectContainsPoint([highScores boundingBox], touchLocation)){
        
        [self itemStatsTouched];
        
        CCLOG(@"Touch: %@",NSStringFromCGPoint(touchLocation));
        
        return YES;
        
    }else if(CGRectContainsPoint([credits boundingBox], touchLocation)){
        
        [self itemGetCoinsTouched];
        
        return YES;
        
    }else if(CGRectContainsPoint(boundingBox, touchLocation)){
        
        [[GameManager sharedGameManager] resetBestScore];
        
        CCLabelBMFont* highScoreLabel = (CCLabelBMFont *)[background getChildByTag:kHighScoreLabelTagValue];
        
        [highScoreLabel setString:@"0"];
        
        [[GCHelper sharedInstance] resetAchievements];
       
        return YES;
        
    }else if (!CGRectContainsPoint([mainMenuSprite boundingBox], touchLocation) ) {
        [self goBack];
        return YES;
    }
    
    return YES;
    
}


- (void) itemGetCoinsTouched
{
    CCLOG(@"Sono in Credits Touched");
    
    // Movement animation to Get Coins Area
    
    CCMoveTo* move = [CCMoveTo actionWithDuration:1 position:CGPointMake(size.width , 0)];
	CCEaseExponentialOut* ease = [CCEaseExponentialOut actionWithAction:move];
    CCCallBlock* blockLoadingPurchase = [CCCallBlock actionWithBlock:(^{
    
        // Check if internet connection is available 
        
        Reachability *reach = [Reachability reachabilityForInternetConnection];	
        NetworkStatus netStatus = [reach currentReachabilityStatus];    
        if (netStatus == NotReachable) { 
            
            NSLog(@"No internet connection!");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" 
                                                            message:@"No internet Connection" 
                                                           delegate:nil 
                                                  cancelButtonTitle:nil 
                                                  otherButtonTitles:@"OK", nil];
            [alert show];


        } else { 
            
            if ([PattyCombatIAPHelper sharedHelper].products == nil) {
                                
                [[PattyCombatIAPHelper sharedHelper] requestProducts];
                _hud = [MBProgressHUD showHUDAddedTo:[CCDirector sharedDirector].view animated:YES];
                _hud.labelText = @"Loading coins...";
                [self performSelector:@selector(timeout:) withObject:nil afterDelay:30.0];
            }
            else {
                    for (CCMenuItemSprite* item in _purchaseMenu.children) item.opacity = 255;
                
                    _purchaseMenu.isTouchEnabled = TRUE; 
                }
        }

    
    })];
	[self runAction:[CCSequence actionOne:ease two:blockLoadingPurchase]];
        
}

- (void) itemStatsTouched
{
    CCLOG(@"Sono in High Scores Touched");
    
    CCMoveTo* move = [CCMoveTo actionWithDuration:1 position:CGPointMake(-(size.width), 0)];
	CCEaseExponentialOut* ease = [CCEaseExponentialOut actionWithAction:move];
	[self runAction:ease];
    
}

-(void) goBack
{
    
    CCLOG(@"sono in GoBack");
    
    CCMoveTo* move = [CCMoveTo actionWithDuration:1 position:CGPointZero];
	CCEaseExponentialOut* ease = [CCEaseExponentialOut actionWithAction:move];
	[self runAction:ease];
    
}


#pragma mark -
#pragma mark === Play Game ===
#pragma mark -


-(void)playGame{
    
    self.isTouchEnabled = FALSE;
    
    [[GameManager sharedGameManager] runSceneWithID:kIntroScene];
    
}

#pragma mark -
#pragma mark === Update ===
#pragma mark -

-(void) update:(ccTime)delta
{
    
    CCSprite* miaghi = (CCSprite*)[self getChildByTag:13];
    
    if ([miaghi numberOfRunningActions] == 0) {
        
        [self unscheduleAllSelectors];
         
        CCFiniteTimeAction* scaleUp = [CCScaleTo actionWithDuration:0.1f scale:1.5];
        CCFiniteTimeAction* scaleDown = [CCScaleTo actionWithDuration:0.1f scale:1];
        
        ccTime d1 = [scaleUp duration];
        ccTime d2 = [scaleDown duration];
        
        CCFiniteTimeAction* delay = [CCDelayTime actionWithDuration:(d1 + d2)];
        
        id seq = [CCSequence actionOne:scaleUp two:scaleDown];

        play = [CCSprite spriteWithFile:@"play.png"];
        [self addChild:play z:1];
        [play setPosition:ccp(size.width/2 -10, size.height/2 -40)];
        [play setScale:0.01f];
        [play runAction:seq];

        
        highScores = [CCSprite spriteWithFile:@"highscore.png"];
        [self addChild:highScores z:1];
        [highScores setScale:0.01f];
        [highScores runAction:[CCSequence actionOne:delay two:[seq copy]]];
        highScores.position = ccp(size.width - 100 ,40);

        [delay setDuration:2*[delay duration]];
        
        credits = [CCSprite spriteWithFile:@"credits.png"];
        [self addChild:credits z:1];
        [credits setScale:0.01f];
        [credits runAction:[CCSequence actionOne:delay two:[seq copy]]];
        credits.position = ccp(80,40);
        
        self.isTouchEnabled = TRUE;
        
    }
}


#pragma mark -
#pragma mark ===  Game Center  ===
#pragma mark -

-(void)showAchievements{
    
    GKAchievementViewController* achievements = [[GKAchievementViewController alloc] init];
    
    if (achievements != NULL)
    {
        achievements.achievementDelegate = self;
        
        [[CCDirectorIOS sharedDirector] presentModalViewController:achievements animated:YES];
        [achievements shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait];
    }
    
}

- (void)achievementViewControllerDidFinish:
(GKAchievementViewController *)viewController {
    
    [[CCDirector sharedDirector] dismissModalViewControllerAnimated:YES];
}


-(void)showLeaderboard{
    
    GKLeaderboardViewController *leaderboardController =
    [[GKLeaderboardViewController alloc] init];
    if (leaderboardController != NULL)
    {
        leaderboardController.category = kPattyLeaderboard;
        leaderboardController.timeScope =
        GKLeaderboardTimeScopeAllTime;
        leaderboardController.leaderboardDelegate = self;
         [[CCDirector sharedDirector] presentModalViewController:leaderboardController
         animated:YES];
    }
    
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)
viewController
{
    [[CCDirector sharedDirector] dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark ===  App Purchase  ===
#pragma mark -


-(void)updateLabelCoinsForProductIdentifier:(NSString *)productIdentifier{
    
    NSInteger quantity = [[PattyCombatIAPHelper sharedHelper] updateQuantityForProductIdentifier:productIdentifier];
    CCSprite* getcoinsBackGround = (CCSprite *)[self getChildByTag:kGetCoinsBackgroundTagValue];
    CCLabelBMFont* label = (CCLabelBMFont *)[getcoinsBackGround getChildByTag:kLabelCoinsReachedTagValue];
    
    [label setString:[NSString stringWithFormat:@"%d", quantity]];
    
}

// Notification CallBack when product is purchased

- (void)productPurchased:(NSNotification *)notification {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
    [MBProgressHUD hideHUDForView:[CCDirector sharedDirector].view animated:YES];
    
    
    NSString *productIdentifier = (NSString *) notification.object;
    [self updateLabelCoinsForProductIdentifier:productIdentifier];
   
    NSLog(@"Purchased: %@", productIdentifier);
    
            
}

// Notification Callback when purchase is failed

- (void)productPurchaseFailed:(NSNotification *)notification {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
    [MBProgressHUD hideHUDForView:[CCDirector sharedDirector].view animated:YES];
    
    SKPaymentTransaction * transaction = (SKPaymentTransaction *) notification.object;    
    if (transaction.error.code != SKErrorPaymentCancelled) {    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" 
                                                         message:transaction.error.localizedDescription 
                                                        delegate:nil 
                                               cancelButtonTitle:nil 
                                               otherButtonTitles:@"OK", nil];
        
        [alert show];
    }
    
}

- (void)dismissHUD:(id)arg {
    
   [MBProgressHUD hideHUDForView:[CCDirector sharedDirector].view animated:YES];
    self.hud = nil;
    
}

//Callback when products are loaded

- (void)productsLoaded:(NSNotification *)notification {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
    [MBProgressHUD hideHUDForView:[CCDirector sharedDirector].view animated:YES];
    _purchaseMenu.isTouchEnabled = YES;

    for (CCMenuItemSprite* item in _purchaseMenu.children) {
        
        item.opacity = 255;
    }
}


- (void)timeout:(id)arg {
    
    _hud.labelText = @"Timeout!";
    _hud.detailsLabelText = @"Please try again later.";
    _hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.jpg"]];
	_hud.mode = MBProgressHUDModeCustomView;
    [self performSelector:@selector(dismissHUD:) withObject:nil afterDelay:3.0];
    
}

- (void)buyButtonTapped:(id)sender {
    
    CCMenuItem *buyButton = (CCMenuItem *)sender;
    
    if (buyButton.tag < [[PattyCombatIAPHelper sharedHelper].products count]) {
        
    SKProduct *product = [[PattyCombatIAPHelper sharedHelper].products objectAtIndex:buyButton.tag];
    
    NSLog(@"Buying %@...", product.productIdentifier);
    [[PattyCombatIAPHelper sharedHelper] buyProductIdentifier:product];
    
    self.hud = [MBProgressHUD showHUDAddedTo:[CCDirectorIOS sharedDirector].view animated:YES];
    _hud.labelText = @"Buying Coins...";
        [self performSelector:@selector(timeout:) withObject:nil afterDelay:60*5];
    
    }
    
}

#pragma mark -
#pragma mark ===  Check if is First Post  ===
#pragma mark -

-(void)updateSocialCoins{

    BOOL isFirstPost = [[NSUserDefaults standardUserDefaults] boolForKey:@"FirstPost"]; 
    
    if (!isFirstPost) {
        [self updateLabelCoinsForProductIdentifier:kProductPurchaseFacebookCoins];
        isFirstPost = YES;
        [[NSUserDefaults standardUserDefaults] setBool:isFirstPost forKey:@"FirstPost"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

}



#pragma mark -
#pragma mark ===  Alert View Social Delegate   ===
#pragma mark -


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:NO];
    
    switch (buttonIndex) {
        case 0:
            break;
        case 1:
            [self loginToFacebook:self];
            break;
        case 2:
            [self postOnTwitter:self];
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark ===  Facebook Delegate  ===
#pragma mark -

- (void)storeAuthData:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
}


//Callback login on Facebook

- (void)fbDidLogin {
    
    AppController* delegate = (AppController *)[[UIApplication sharedApplication] delegate];

    [self storeAuthData:[[delegate facebook] accessToken] expiresAt:[[delegate facebook] expirationDate]];
    
    [self postToFacebook:nil];
    
}
-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    
    NSLog(@"token extended");
    [self storeAuthData:accessToken expiresAt:expiresAt];
}


 // Called when the user canceled the authorization dialog.
 
-(void)fbDidNotLogin:(BOOL)cancelled {
    
    NSLog(@"%@", NSStringFromSelector(_cmd));

}


 // Called when the request logout has succeeded.
 
- (void)fbDidLogout {
    
    // Remove saved authorization information if it exists and it is
    // ok to clear it (logout, session invalid, app unauthorized)
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
}


// * Called when the session has expired.
 
- (void)fbSessionInvalidated {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Auth Exception"
                              message:@"Your session has expired."
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil,
                              nil];
    [alertView show];
    [self fbDidLogout];
}


// Call when button is pressed 

-(void)loginToFacebook:(id)sender{
    
    _permissions = [[NSArray alloc] initWithObjects:@"offline_access", nil];
    
    AppController* delegate = (AppController *)[[UIApplication sharedApplication] delegate];

    if (![[delegate facebook] isSessionValid]) {
        
        [[delegate facebook] authorize:_permissions];
        
    }else {
        
        [self postToFacebook:self];
    }

    
}


-(void)postToFacebook:(id)sender{
    
    SBJSON *jsonWriter = [SBJSON new];
    
    // The action links to be shown with the post in the feed
    NSArray* actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                                      @"Get Started",@"name",@"http://www.facebook.com/pages/Patty-Combat/269975746417125",@"link", nil], nil];
    NSString *actionLinksStr = [jsonWriter stringWithObject:actionLinks];
    
    // Dialog parameters
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"I'm using Patty Combat", @"name",
                                   @"Patty Combat.", @"caption",
                                   @"Test Patty Combat", @"description",
                                   @"http://www.facebook.com/pages/Patty-Combat/269975746417125", @"link",
                                   @"http://fbcdn-sphotos-a.akamaihd.net/hphotos-ak-ash4/420383_269975969750436_269975746417125_608460_1762786580_n.jpg", @"picture",
                                   actionLinksStr, @"actions",
                                   nil];
    
    AppController* delegate = (AppController *)[[UIApplication sharedApplication] delegate];

    [[delegate facebook] dialog:@"feed"
                      andParams:params
                    andDelegate:self];
}


#pragma mark -
#pragma mark ===  Facebook Dialog Delegate  ===
#pragma mark -

// Called when dialog is finish

- (void)dialogCompleteWithUrl:(NSURL *)url {
   
    if (![url query]) {
        NSLog(@"User canceled dialog or there was an error");
        return;
    }
    
    
    [self updateSocialCoins];

    NSLog(@"Dialog Complete");
}

- (void)dialogDidNotComplete:(FBDialog *)dialog {
    
    NSLog(@"Dialog dismissed.");
}

- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError *)error {
    NSLog(@"Error message: %@", [[error userInfo] objectForKey:@"error_msg"]);
    //[self showMessage:@"Oops, something went haywire."];
}



#pragma mark -
#pragma mark ===  Twitter  ===
#pragma mark -

-(void)postOnTwitter:(id)sender{
    
    
    if ([TWTweetComposeViewController canSendTweet])
    {
        TWTweetComposeViewController *tweetSheet =
        [[TWTweetComposeViewController alloc] init];
        tweetSheet.completionHandler = ^(TWTweetComposeViewControllerResult
                                         result){
            if (result == TWTweetComposeViewControllerResultCancelled)
            {
                NSLog(@"Cancelled the Tweet");
            }
            else
            {
                [self updateSocialCoins];
            }
            [[CCDirectorIOS sharedDirector] dismissModalViewControllerAnimated:YES];

        };
        [tweetSheet setInitialText:
         @"Tweeting from Patty Combat! :)"];
        [[CCDirectorIOS sharedDirector] presentModalViewController:tweetSheet animated:YES];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

@end

