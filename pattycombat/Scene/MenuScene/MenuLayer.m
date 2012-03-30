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

-(void) goBack;
-(void)playGame;
-(void)itemStatsTouched;
-(void)itemGetCoinsTouched;
-(void)showAchievements;
-(void)showLeaderboard;
@end


@implementation MenuLayer

@synthesize size;
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
#pragma mark === Init Methods ===
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

-(void)buildMainMenu{
    
    float xPosition = size.width * 0.7;
    
    // Main Menu Background
    
    CCSprite* mainMenuBackground = [CCSprite spriteWithFile:@"menu_02.png"];
    [self addChild:mainMenuBackground z:kMainMenuBackgroundZValue tag:kMainMenuBackgroundTagValue];
    [mainMenuBackground setPosition:ccp(size.width/2, size.height/2)];
    
    // Actor Myagi
    
    CCSprite* myagi = [CCSprite spriteWithFile:@"myagi.png"];
    
    myagi.anchorPoint = ccp(0, 0);
    
    myagi.position = ccp(size.width * 0.2, - myagi.contentSize.height * 0.14);
    
    [mainMenuBackground addChild:myagi z:kPlayerMiaghiZValue tag:kPlayerMiaghiTagValue];
    
    //Play button
    
    CCSprite* play = [CCSprite spriteWithSpriteFrameName:@"play_btn.png"];
    play.anchorPoint = ccp(0.5f,0);
    CCSprite* playSelected = [CCSprite spriteWithSpriteFrameName:@"play_btn_over.png"];
    playSelected.anchorPoint = ccp(0.5f,0);
    CCNode* nodePlay = [CCNode node];
    nodePlay.contentSize = play.contentSize;
    [nodePlay addChild:play];
    [nodePlay addChild:playSelected];
    [mainMenuBackground addChild:nodePlay z:kItemPlayNodeZValue tag:kItemPlayNodeTagValue];
    nodePlay.position = ccp(xPosition ,size.height);
    
    CCMenuItemSpriteIndependent* playButton = [CCMenuItemSpriteIndependent 
                                               itemWithNormalSprite:play
                                                    selectedSprite:playSelected 
                                                        target:self 
                                                            selector:@selector(playGame)];
    // Get Coins Button
    
    CCSprite* getCoins = [CCSprite spriteWithSpriteFrameName:@"getcoins_btn.png"];
    getCoins.anchorPoint = ccp(0.5f,0);
    CCSprite* getCoinsSelected = [CCSprite spriteWithSpriteFrameName:@"getcoins_btn_over.png"];
    getCoinsSelected.anchorPoint = ccp(0.5f,0);
    CCNode* nodeGetCoins = [CCNode node];
    [nodeGetCoins addChild:getCoins];
    [nodeGetCoins addChild:getCoinsSelected];
    [mainMenuBackground addChild:nodeGetCoins z:kItemGetCoinsZValue tag:kItemGetCoinsTagValue];
    nodeGetCoins.position = ccp(xPosition,size.height);
    
    CCMenuItemSpriteIndependent* getCoinsButton = [CCMenuItemSpriteIndependent
                                                    itemWithNormalSprite:getCoins 
                                                        selectedSprite:getCoinsSelected
                                                            target:self 
                                                                selector:@selector(itemGetCoinsTouched)];
    
    // Stats Button
    
    CCSprite* stats = [CCSprite spriteWithSpriteFrameName:@"stats_btn.png"];
    stats.anchorPoint = ccp(0.5f,0);
    CCSprite* statsSelected = [CCSprite spriteWithSpriteFrameName:@"stats_btn_over.png"];
    statsSelected.anchorPoint = ccp(0.5f,0);
    CCNode* nodeStats = [CCNode node];
    [nodeStats addChild:stats];
    [nodeStats addChild:statsSelected];
    [mainMenuBackground addChild:nodeStats z:kItemStatsZValue tag:kItemStatsTagValue];
    nodeStats.position = ccp(xPosition ,size.height);
    
    CCMenuItemSpriteIndependent* statsButton = [CCMenuItemSpriteIndependent
                                                   itemWithNormalSprite:stats 
                                                   selectedSprite:statsSelected
                                                   target:self 
                                                   selector:@selector(itemStatsTouched)];
    
    // Credits Button
    
    CCSprite* credits = [CCSprite spriteWithSpriteFrameName:@"credits_btn.png"];
    credits.anchorPoint = ccp(0.5f,0);
    CCSprite* creditsSelected = [CCSprite spriteWithSpriteFrameName:@"credits_btn_over.png"];
    creditsSelected.anchorPoint = ccp(0.5f,0);
    CCNode* nodeCredits = [CCNode node];
    [nodeCredits addChild:credits];
    [nodeCredits addChild:creditsSelected];
    [mainMenuBackground addChild:nodeCredits z:kItemCreditsZValue tag:kItemCreditsTagValue];
    nodeCredits.position = ccp(xPosition ,size.height);
    
    CCMenuItemSpriteIndependent* creditsButton = [CCMenuItemSpriteIndependent
                                                    itemWithNormalSprite:credits 
                                                        selectedSprite:creditsSelected
                                                            target:self 
                                                                selector:@selector(itemCreditsTouched)];
    
    
    // Main Menu 
    CCMenu* mainMenu = [CCMenu menuWithItems:playButton,getCoinsButton,statsButton,creditsButton, nil];
    
    [mainMenuBackground addChild:mainMenu z:kMainMenuZValue tag:kMainMenuTagValue];
    
    mainMenu.isTouchEnabled = FALSE;
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
        
        //Build Main Menu
        
        [self buildMainMenu];
        
        // Build Menu GetCoins
        
        [self buildGetCoins];
        
        // Build Menu Stats
        
        [self buildStats];
        
        // Add Credits Background (maybe will be a layer)
        
        CCSprite* creditsBackground= [CCSprite spriteWithFile:@"credits_window.png"];
        creditsBackground.opacity = 0;
        [self addChild:creditsBackground z:kCreditsBackgroundZValue tag:kCreditsBackgroundTagValue];
        [creditsBackground setPosition:ccp(size.width/2, size.height/2)];

        
        // Add Observer for Purchase Notification
                
        [[NSNotificationCenter defaultCenter]    addObserver:self
                                                 selector:@selector(productPurchased:)
                                                 name:kProductPurchasedNotification
                                                 object:nil];
        
        [[NSNotificationCenter defaultCenter]    addObserver:self 
                                                 selector: @selector(productPurchaseFailed:)
                                                 name:kProductPurchaseFailedNotification 
                                                 object: nil];
        
        [[NSNotificationCenter defaultCenter]    addObserver:self
                                                 selector:@selector(productsLoaded:)
                                                 name:kProductsLoadedNotification 
                                                 object:nil];       
        
	}
	return self;
}

#pragma mark On Enter 

-(void)onEnterTransitionDidFinish{
    
    //Play Theme music
    
    [[GameManager sharedGameManager] playBackgroundTrack:BACKGROUND_TRACK_MAIN_MENU];
    
    // Action of Miaghi (Rotate + Move)
    
    CCSprite* mainMenuBackground = (CCSprite *)[self getChildByTag:kMainMenuBackgroundTagValue];
    CCSprite* myagi = (CCSprite*)[mainMenuBackground getChildByTag:kPlayerMiaghiTagValue];
    
    CCRotateTo* rotate = [CCRotateTo actionWithDuration:0.05f angle:-20];
    
    id move = [CCMoveBy actionWithDuration:0.05f position:CGPointMake(5, 0)];
    id movereverse = [move reverse];
    
    [myagi runAction:[CCSequence actions:rotate,[CCRepeat actionWithAction:[CCSequence actions:move,movereverse, nil] times:1], nil]];
    
    [self scheduleUpdate];
    
}

#pragma mark -
#pragma mark === Update ===
#pragma mark -

-(void) update:(ccTime)delta
{
    
    CCSprite* mainMenuBackground = (CCSprite *)[self getChildByTag:kMainMenuBackgroundTagValue];
    CCSprite* miaghi = (CCSprite*)[mainMenuBackground getChildByTag:kPlayerMiaghiTagValue];
    
    if ([miaghi numberOfRunningActions] == 0) {
                
        [self unscheduleAllSelectors];
        
        CCNode* nodePlay =     [mainMenuBackground getChildByTag:kItemPlayNodeTagValue];
        CCNode* nodeGetCoins = [mainMenuBackground getChildByTag:kItemGetCoinsTagValue];
        CCNode* nodeStats =    [mainMenuBackground getChildByTag:kItemStatsTagValue];
        CCNode* nodeCredits =  [mainMenuBackground getChildByTag:kItemCreditsTagValue];
        CCMenu* mainMenu =     (CCMenu *)[mainMenuBackground getChildByTag:kMainMenuTagValue];
        
        // Move down the menu's buttons
        
        float xPosition = size.width * 0.7;
        float yPosition = size.height * 0.125f;

        CCMoveTo* moveDown = [CCMoveTo actionWithDuration:0.2f position:ccp(xPosition, yPosition)];
        
        ccTime d1 = [moveDown duration];
        
        float height = nodePlay.contentSize.height;
        float padding = 0;

        [nodeCredits runAction:[CCSequence actionOne:moveDown two:[CCCallBlock actionWithBlock:^{
            
            float heightStats = height;  
            
            CCMoveTo* moveStats = [CCMoveTo actionWithDuration:d1 position:ccp(xPosition, heightStats + padding + yPosition)];
            
                [nodeStats runAction:[CCSequence actionOne:moveStats two:[CCCallBlock actionWithBlock:^{
                    
                    float heightGetCoins = 2*height;
                    
                    CCMoveTo* moveGetCoins = [CCMoveTo actionWithDuration:d1 position:ccp(xPosition, heightGetCoins + padding + yPosition)];
                    
                    [nodeGetCoins runAction:[CCSequence actionOne:moveGetCoins two:[CCCallBlock actionWithBlock:^{
                        
                        float heightPlay = 3*height;
                        
                        CCMoveTo* movePlay = [CCMoveTo actionWithDuration:d1 position:ccp(xPosition, heightPlay + padding + yPosition)];
                        
                        [nodePlay runAction:movePlay];
                         
                    }]]];
                    
                }]]];
            
        }]]];
        
        mainMenu.isTouchEnabled = TRUE;
        self.isTouchEnabled = TRUE;
        
    }
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
    
    CCSprite* mainMenuBackground = (CCSprite *)[self getChildByTag:kMainMenuBackgroundTagValue];
    
    CCSprite* creditsBackground = (CCSprite *)[self getChildByTag:kCreditsBackgroundTagValue];
    
   // CGRect boundingBox = CGRectMake(900, 0, 50, 50);
    
    CCLOG(@"Touch: %@",NSStringFromCGPoint(touchLocation));
    
    if (!CGRectContainsPoint([mainMenuBackground boundingBox], touchLocation)) {
        
        [self goBack];
        
    }else if (CGRectContainsPoint([creditsBackground boundingBox], touchLocation) && creditsBackground.opacity == 255) {
        
        // Fade Out of Credits Background and enable main menu
        
        CCMenu* mainMenu = (CCMenu *)[mainMenuBackground getChildByTag:kMainMenuTagValue];
        
        CCFadeOut* fadeOut = [CCFadeOut actionWithDuration:1];
        
        [creditsBackground runAction:[CCSequence actionOne:fadeOut two:[CCCallBlock actionWithBlock:^{
            
            mainMenu.isTouchEnabled = YES;

        }]]];
        
        
    }
        
  /*  if(CGRectContainsPoint(boundingBox, touchLocation)){
        
        [[GameManager sharedGameManager] resetBestScore];
        
        CCLabelBMFont* highScoreLabel = (CCLabelBMFont *)[background getChildByTag:kHighScoreLabelTagValue];
        
        [highScoreLabel setString:@"0"];
        
        [[GCHelper sharedInstance] resetAchievements];
       
        return YES;
        
    }else if (!CGRectContainsPoint([mainMenuSprite boundingBox], touchLocation) ) {
        
        [self goBack];
        
        return YES;
    }*/
    
    return YES;
    
}

// Called when GetCoins Button is touched

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

// Called when Stats Button is touched

- (void) itemStatsTouched
{
    CCLOG(@"Sono in High Scores Touched");
    
    CCMoveTo* move = [CCMoveTo actionWithDuration:1 position:CGPointMake(-(size.width), 0)];
	CCEaseExponentialOut* ease = [CCEaseExponentialOut actionWithAction:move];
	[self runAction:ease];
    
}


// Called when Credits Button is Touched

-(void) itemCreditsTouched{
    
    CCSprite* creditsBackground = (CCSprite *)[self getChildByTag:kCreditsBackgroundTagValue];
    
    CCFadeIn* fade = [CCFadeIn actionWithDuration:1];
    [creditsBackground runAction:fade];
    
    // Disabled Touch for Main Menu
    CCSprite* mainMenuBackground = (CCSprite *)[self getChildByTag:kMainMenuBackgroundTagValue];
    CCMenu* mainMenu = (CCMenu *)[mainMenuBackground getChildByTag:kMainMenuTagValue];
    mainMenu.isTouchEnabled = FALSE;
    
}

// Return to the Main Menu

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


// Called when purchase is done for update label coins 


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

