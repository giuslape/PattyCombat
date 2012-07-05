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
#import "CCMenuItemSpriteIndependent.h"
#import "SocialHelper.h"

@interface MenuLayer ()

@property CGSize size;

-(void)goBack;
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
    
    NSLog(@"=========================================");
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    _darkLayer = nil;
    _purchaseMenu = nil;
    _hud = nil;
    
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProductsLoadedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProductPurchaseFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Social" object:nil];
    
    
}

#pragma mark -
#pragma mark === Init Methods ===
#pragma mark -


-(void)buildGetCoins{
    

    //Label Coins Purchased
    
    CCLabelBMFont* labelCoinsPurchased = [CCLabelBMFont labelWithString:@"Coins Held" fntFile:FONTHIGHSCORES];
    [labelCoinsPurchased setPosition:ccp(-size.width + size.width * 0.70f, size.height * 0.24f)];
    [self addChild:labelCoinsPurchased z:3];
    
    //Number of product purchased
    
    int quantity = [[PattyCombatIAPHelper sharedHelper] quantity];
    
    CCLabelBMFont* labelQuantity =
    [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d",quantity]
                           fntFile:FONTHIGHSCORES];
    
    [self addChild:labelQuantity z:kLabelCoinsReachedZValue tag:kLabelCoinsReachedTagValue];
    [labelQuantity setPosition:ccp(-size.width + size.width * 0.70f, size.height * 0.32f)];
    
    // Add Layer for explain purchase
    
    CCLayerColor* layerMenuPurchase = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 127) width:450 height:220];
    
    [self addChild:layerMenuPurchase z:2];
    
    [layerMenuPurchase setPosition:ccp(- size.width + 15, size.height * 0.11f)];
    
      CCLabelTTF* labelDescription = [CCLabelTTF labelWithString:@"Coins are useful if you want to retry a level without restarting from the beginning.\n\n By buying coins you are also funding our work and helping us to come up with new games in the future!" dimensions:CGSizeMake(210, 110) hAlignment:UITextAlignmentCenter fontName:@"Helvetica" fontSize:12];
    
    [labelDescription setPosition:ccp(-size.width + size.width * 0.70f, size.height * 0.55f)];
    
    [self addChild:labelDescription z:2];
    
    // Add Store logo
    
    CCSprite* storeLogo = [CCSprite spriteWithFile:@"store_logo.png"];
    
    [storeLogo setPosition:ccp(-size.width * 0.5f, size.height * 0.9f)];
    
    [self addChild:storeLogo z:2];
        
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
        [alertView setTag:kAlertViewSocial];
        
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

    [self addChild:_purchaseMenu z:kPurchaseMenuZValue tag:kPurchaseMenuTagValue];
    
    _purchaseMenu.position = ccp(-size.width + size.width * 0.25, size.height * 0.44);
    
    [_purchaseMenu alignItemsVerticallyWithPadding:3];
    
    _purchaseMenu.isTouchEnabled = NO;
    
    CCTexture2DPixelFormat defaultPixelFormat = [CCTexture2D defaultAlphaPixelFormat];
    
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
    
    //Add background
    
    CCSprite* getCoinsBackground = [CCSprite spriteWithFile:@"menu_01.png"];
    [self addChild:getCoinsBackground z:kGetCoinsBackgroundZValue tag:kGetCoinsBackgroundTagValue];
    [getCoinsBackground setPosition:ccp(-size.width/2, size.height/2)];
    
    [CCTexture2D setDefaultAlphaPixelFormat:defaultPixelFormat];
}

-(void)buildStats{
    
    CCTexture2DPixelFormat defaultPixelFormat = [CCTexture2D defaultAlphaPixelFormat];
    
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
    
    // Add background Stats
    CCSprite* highscoresBackground = [CCSprite spriteWithFile:@"menu_03.png"];
    [self addChild:highscoresBackground z:kStatsBackgroundZValue tag:kStatsBackgroundTagValue];
    [highscoresBackground setPosition:ccp(1.5*size.width, size.height/2)];
    
    [CCTexture2D setDefaultAlphaPixelFormat:defaultPixelFormat];
    
    // Position of Menu
    
    float xPosition = size.width + size.width * 0.2;
    
    // Label Highscore
    
    CCLabelBMFont* labelHighscores = [CCLabelBMFont labelWithString:@"Highscores" fntFile:FONTHIGHSCORES];
    [labelHighscores setPosition:ccp(xPosition, size.height * 0.8)];
    [labelHighscores setAnchorPoint:ccp(0.5f, 0)];
    [self addChild:labelHighscores z:3];
    
    // Label Highscore Value
    
    int highScore = [[GameManager sharedGameManager] bestScore];
    
    CCLabelBMFont* highScoreLabelValue = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d", highScore] fntFile:FONTHIGHSCORES];
    [highScoreLabelValue setPosition:ccp(xPosition, size.height * 0.7)];
    [highScoreLabelValue setAnchorPoint:ccp(0.5f, 0)];
    [self addChild:highScoreLabelValue z:kHighScoreLabelZValue tag:kHighScoreLabelTagValue];
    
    // Add Leaderboard Button
    
    CCSprite* leaderboard = [CCSprite spriteWithSpriteFrameName:@"leaderboard_btn.png"];
    [leaderboard setPosition:ccp(xPosition, size.height * 0.53)];
    [leaderboard setAnchorPoint:ccp(0.5f, 0)];
    [self addChild:leaderboard z:3];
    CCSprite* leaderboardSelected = [CCSprite spriteWithSpriteFrameName:@"leaderboard_btn_over.png"];
    [leaderboardSelected setPosition:ccp(xPosition, size.height * 0.53)];
    [leaderboardSelected setAnchorPoint:ccp(0.5f, 0)];
    [self addChild:leaderboardSelected z:3];
    
    CCMenuItemSpriteIndependent* leaderboardButton = [CCMenuItemSpriteIndependent itemWithNormalSprite:leaderboard
                                                                                        selectedSprite:leaderboardSelected
                                                                                                target:self
                                                                                              selector:@selector(showLeaderboard)];
    
    // Label Level Reached
    
    CCLabelBMFont* labelLevelReached = [CCLabelBMFont labelWithString:@"Level Reached" fntFile:FONTHIGHSCORES];
    [labelLevelReached setPosition:ccp(xPosition, size.height * 0.4)];
    [labelLevelReached setAnchorPoint:ccp(0.5f, 0)];
    [self addChild:labelLevelReached z:3];
    
    // Label Level Reached Value
    
    CCLabelBMFont* levelReachedValue = [CCLabelBMFont
                                        labelWithString:[NSString stringWithFormat:@"%d", [[GameManager sharedGameManager] levelReached]] 
                                            fntFile:FONTHIGHSCORES];
    
    [levelReachedValue setPosition:ccp(xPosition, size.height * 0.3)];
    [levelReachedValue setAnchorPoint:ccp(0.5f, 0)];
    [self addChild:levelReachedValue z:kLevelReachedValueZValue tag:kLevelReachedValueTagValue];
    
        
    // Add Achievement Button
    
    CCSprite* achievement = [CCSprite spriteWithSpriteFrameName:@"achievements_btn.png"];
    [achievement setPosition:ccp(xPosition, size.height * 0.125)];
    [achievement setAnchorPoint:ccp(0.5f, 0)];
    [self addChild:achievement z:3];
    CCSprite* achievementSelected = [CCSprite spriteWithSpriteFrameName:@"achievements_btn_over.png"];
    [achievementSelected setPosition:ccp(xPosition,size.height * 0.125)];
    [achievementSelected setAnchorPoint:ccp(0.5f, 0)];
    [self addChild:achievementSelected z:3];


    
    CCMenuItemSpriteIndependent* achievementButton = [CCMenuItemSpriteIndependent 
                                                         itemWithNormalSprite:achievement 
                                                            selectedSprite:achievementSelected 
                                                                target:self
                                                                    selector:@selector(showAchievements)];
    
    // Menu Stats
    
    CCMenu* menuStats = [CCMenu menuWithItems:achievementButton,leaderboardButton, nil];
    [self addChild:menuStats z:3];
    
    
    
    CCSprite* reset = [CCSprite spriteWithSpriteFrameName:@"reset_btn.png"];
    [reset setPosition:ccp(size.width + size.width * 0.9, size.height * 0.07)];
    [self addChild:reset z:kResetZValue tag:kResetTagValue];
}

-(void)buildMainMenu{
    
    float xPosition = size.width * 0.7;
    
    CCTexture2DPixelFormat defaultPixelFormat = [CCTexture2D defaultAlphaPixelFormat];
    
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
    
    // Main Menu Background
    CCSprite* mainMenuBackground = [CCSprite spriteWithFile:@"menu_02.png"];
    [self addChild:mainMenuBackground z:kMainMenuBackgroundZValue tag:kMainMenuBackgroundTagValue];
    [mainMenuBackground setPosition:ccp(size.width/2, size.height/2)];
    
    [CCTexture2D setDefaultAlphaPixelFormat:defaultPixelFormat];

    
    // Actor Myagi
    
   // [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
    
    CCSprite* myagi = [CCSprite spriteWithFile:@"myagi.png"];
    
    myagi.anchorPoint = ccp(0, 0);
    
    myagi.position = ccp(size.width * 0.2, - myagi.contentSize.height * 0.14);
    
    [self addChild:myagi z:kPlayerMiaghiZValue tag:kPlayerMiaghiTagValue];
    
    //Play button
    
    CCSprite* play = (![[GameManager sharedGameManager] isExtreme]) ? [CCSprite spriteWithSpriteFrameName:@"play_btn.png"] : [CCSprite spriteWithSpriteFrameName:@"playExtreme_btn.png"] ;
    play.anchorPoint = ccp(0.5f,0);
    CCSprite* playSelected = (![[GameManager sharedGameManager] isExtreme]) ? [CCSprite spriteWithSpriteFrameName:@"play_btn_over.png"] :[CCSprite spriteWithSpriteFrameName:@"playExtreme_btn_over.png"];
    playSelected.anchorPoint = ccp(0.5f,0);
    CCNode* nodePlay = [CCNode node];
    nodePlay.contentSize = play.contentSize;
    [nodePlay addChild:play];
    [nodePlay addChild:playSelected];
    [self addChild:nodePlay z:kItemPlayNodeZValue tag:kItemPlayNodeTagValue];
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
    [self addChild:nodeGetCoins z:kItemGetCoinsZValue tag:kItemGetCoinsTagValue];
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
    [self addChild:nodeStats z:kItemStatsZValue tag:kItemStatsTagValue];
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
    [self addChild:nodeCredits z:kItemCreditsZValue tag:kItemCreditsTagValue];
    nodeCredits.position = ccp(xPosition ,size.height);
    
    CCMenuItemSpriteIndependent* creditsButton = [CCMenuItemSpriteIndependent
                                                    itemWithNormalSprite:credits 
                                                        selectedSprite:creditsSelected
                                                            target:self 
                                                                selector:@selector(itemCreditsTouched)];
    
    
    // Main Menu 
    CCMenu* mainMenu = [CCMenu menuWithItems:playButton,getCoinsButton,statsButton,creditsButton, nil];
    
    [self addChild:mainMenu z:kMainMenuZValue tag:kMainMenuTagValue];
    
    mainMenu.isTouchEnabled = FALSE;
}


// Dark Layer

-(void)addDarkLayer{
    
    _darkLayer = [CCLayerGradient layerWithColor:ccc4(50, 21 , 46, 0) 
                                                            fadingTo:ccc4(50, 21, 46, 153)
                                                                alongVector:ccp(0, 1)];
    
    [_darkLayer setAnchorPoint:ccp(0, 0)];
    
    [_darkLayer setPosition:ccp(-size.width, 0)];
    
    [_darkLayer setContentSize:CGSizeMake(2*size.width + size.width * 0.49, size.height)];
    
    [self addChild:_darkLayer z:kDarkLayerZValue tag:kDarkLayerTagValue];
        
}


// Effect Neon Dark Layer

-(void)doEffectNeon:(ccTime)delta{
    
    _elapsedTime += delta;
    
    if (_elapsedTime > _neonEffectInterval) {
        
        _neonEffectInterval = arc4random() % 8;
        
        _elapsedTime = 0;
    
        id fadeIn = [CCFadeIn actionWithDuration:0.05];
    
        id fadeOut = [fadeIn reverse];
    
        [_darkLayer runAction:[CCRepeat actionWithAction:[CCSequence actionOne:fadeOut two:fadeIn] times:6]];
        
    }
    
}


-(id) init
{
	if ((self = [super init]))
        
	{
        // Add Sprite at cache 
        
        _neonEffectInterval = 0;
        
        _elapsedTime = 0;
        
       // [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
        CCTexture2D* texture = [[CCTextureCache sharedTextureCache] addImage:@"MenuAtlas.pvr.ccz"];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache]
         addSpriteFramesWithFile:@"MenuAtlas.plist" texture:texture];
        
        size = [[CCDirector sharedDirector] winSize];
        
        // Add Logo
        
        CCSprite* logo = [CCSprite spriteWithFile:@"logo.png"];
        
        [logo setAnchorPoint:ccp(0.5f, 1)];
        [logo setPosition:ccp(size.width * 0.7f, size.height * 0.97f)];
        [self addChild:logo z:3];
        
        // Add Dark Layer
        
        [self addDarkLayer];
        
        // Build Menu GetCoins
        
        [self buildGetCoins];
        
        //Build Main Menu
        
        [self buildMainMenu];
        
        // Build Menu Stats
        
        [self buildStats];
        
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
        
       // [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                selector:@selector(updateLabelForSocialCoin:) 
                                                    name:@"Social" 
                                                        object:nil];
        
	}
	return self;
}

#pragma mark On Enter 

-(void)onEnterTransitionDidFinish{
    
    //Play Theme music
    
    [[GameManager sharedGameManager] playBackgroundTrack:BACKGROUND_TRACK_MAIN_MENU];
    
    // Action of Miaghi (Rotate + Move)
    
    CCSprite* myagi = (CCSprite*)[self getChildByTag:kPlayerMiaghiTagValue];
    
    CCRotateTo* rotate = [CCRotateTo actionWithDuration:0.05f angle:-20];
    
    id move = [CCMoveBy actionWithDuration:0.05f position:CGPointMake(5, 0)];
    id movereverse = [move reverse];
    
    [myagi runAction:[CCSequence actions:rotate,[CCRepeat actionWithAction:[CCSequence actions:move,movereverse, nil] times:1], nil]];
    
    [self scheduleUpdate];
    
    //Test Flight Level Reached
    
    CCLabelBMFont* levelReachedValue = (CCLabelBMFont *)[self getChildByTag:kLevelReachedValueTagValue];
    
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"Livello Raggiunto %@",levelReachedValue.string]];

}

#pragma mark -
#pragma mark === Update ===
#pragma mark -

-(void) update:(ccTime)delta
{
    
    CCSprite* miaghi = (CCSprite*)[self getChildByTag:kPlayerMiaghiTagValue];
    
    if ([miaghi numberOfRunningActions] == 0) {
                
        [self unscheduleAllSelectors];
        
        CCNode* nodePlay =     [self getChildByTag:kItemPlayNodeTagValue];
        CCNode* nodeGetCoins = [self getChildByTag:kItemGetCoinsTagValue];
        CCNode* nodeStats =    [self getChildByTag:kItemStatsTagValue];
        CCNode* nodeCredits =  [self getChildByTag:kItemCreditsTagValue];
        CCMenu* mainMenu =     (CCMenu *)[self getChildByTag:kMainMenuTagValue];
        
        // Move down the menu's buttons
        
        float xPosition = size.width * 0.7;
        float yPosition = size.height * 0.125f;

        CCMoveTo* moveDown = [CCMoveTo actionWithDuration:0.1f position:ccp(xPosition, yPosition)];
        
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
        
        [self schedule:@selector(doEffectNeon:) interval:0.01 repeat:-1 delay:1];
    }
    
    
}


-(void)resetStats{
    
    // Reset Level Reached
    
    [[GameManager sharedGameManager] setLevelReached:0];
    
    // Reset Achievements
    
    [[GCHelper sharedInstance] resetAchievements];
    
    // Reset Best Score
    
    [[GameManager sharedGameManager] resetBestScore];
    
    // Reset Labels
    
    CCLabelBMFont* levelReachedValue = (CCLabelBMFont *)[self getChildByTag:kLevelReachedValueTagValue];
    
    CCLabelBMFont* highscoreValue = (CCLabelBMFont *)[self getChildByTag:kHighScoreLabelTagValue];
    
    [levelReachedValue setString:@"0"];
    [highscoreValue setString:@"0"];

    
}


#pragma mark -
#pragma mark === Touch Dispatcher ===
#pragma mark -

-(void) registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0
     
                                              swallowsTouches:YES];
}

-(BOOL)ccTouchBegan:(UITouch*)touch withEvent:(UIEvent *)event
{
	CGPoint touchLocation = [touch locationInView:[touch view]];
    
    touchLocation = [[CCDirector sharedDirector]convertToGL:touchLocation];
    
    touchLocation = [self convertToNodeSpace:touchLocation];
    
    CCSprite* mainMenuBackground = (CCSprite *)[self getChildByTag:kMainMenuBackgroundTagValue];
        
    CGRect boundingBox = CGRectMake(2*size.width * 0.9f, size.height * 0.03f, 80, 60);
    
    CCLOG(@"Touch: %@",NSStringFromCGPoint(touchLocation));
    
    if (CGRectContainsPoint(boundingBox, touchLocation)) {
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Reset Score"
                                                        message:@"Are you sure you want to reset your progress?" 
                                                        delegate:self
                                                        cancelButtonTitle:@"No"
                                                        otherButtonTitles:@"Yes", nil];
        
        [alert show];
        [alert setTag:kALertViewReset];
              
        return YES;
        
    }  else if (!CGRectContainsPoint([mainMenuBackground boundingBox], touchLocation)) {
        
        [self goBack];
        return YES;
    }  
    return NO;
    
}

// Called when GetCoins Button is touched

- (void) itemGetCoinsTouched
{
    CCLOG(@"Sono in Credits Touched");
    
    CCMenu * mainMenu = (CCMenu *)[self getChildByTag:kMainMenuTagValue];
    
    mainMenu.enabled = false;
    
    self.isTouchEnabled = false;

    //TestFlight
    [TestFlight passCheckpoint:@"Controllo gettoni"];
    TFLog(@"Controllo gettoni");
    
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
            self.isTouchEnabled = true;

        } else { 
            
            if ([PattyCombatIAPHelper sharedHelper].products == nil) {
                
                [[PattyCombatIAPHelper sharedHelper] requestProducts];
                _hud = [MBProgressHUD showHUDAddedTo:[CCDirector sharedDirector].view animated:YES];
                _hud.labelText = @"Loading coins...";
                [self performSelector:@selector(timeout:) withObject:nil afterDelay:60.0];
            }
            else {
                    for (CCMenuItemSprite* item in _purchaseMenu.children) item.opacity = 255;
                
                    _purchaseMenu.isTouchEnabled = TRUE; 
                
                    self.isTouchEnabled = true;
                }
        }
    
    })];
	[self runAction:[CCSequence actionOne:ease two:blockLoadingPurchase]];
        
}

// Called when Stats Button is touched

- (void) itemStatsTouched
{
    CCLOG(@"Sono in High Scores Touched");
    
    CCMenu * mainMenu = (CCMenu *)[self getChildByTag:kMainMenuTagValue];
    
    mainMenu.enabled = false;
    
    //TestFlight
    [TestFlight passCheckpoint:@"Controllo statistiche"];
    TFLog(@"Controllo statistiche");

    CCMoveTo* move = [CCMoveTo actionWithDuration:1 position:CGPointMake(-size.width, 0)];
	CCEaseExponentialOut* ease = [CCEaseExponentialOut actionWithAction:move];
	[self runAction:ease];
    
}


// Called when Credits Button is Touched

-(void) itemCreditsTouched{
    
    //TestFlight
    [TestFlight passCheckpoint:@"Controllo crediti"];
    TFLog(@"Controllo crediti");

    
    CreditsLayer* creditsLayer = [CreditsLayer layerWithColor:ccc4(0, 0, 0, 0) width:size.width height:size.height];
    
    [self addChild:creditsLayer z:kCreditsBackgroundZValue tag:kCreditsBackgroundTagValue];
    [creditsLayer setDelegate:self];
    
    CCFadeTo* fade = [CCFadeTo actionWithDuration:1 opacity:170];
    [creditsLayer runAction:fade];
    
    // Disabled Touch for Main Menu
    CCMenu* mainMenu = (CCMenu *)[self getChildByTag:kMainMenuTagValue];
    mainMenu.isTouchEnabled = false;
        
}

// Return to the Main Menu

-(void) goBack
{
    
    CCLOG(@"sono in GoBack");
    CCMoveTo* move = [CCMoveTo actionWithDuration:1 position:CGPointZero];
	CCEaseExponentialOut* ease = [CCEaseExponentialOut actionWithAction:move];
	[self runAction:ease];
    
    CCMenu * mainMenu = (CCMenu *)[self getChildByTag:kMainMenuTagValue];
    
    mainMenu.enabled = true;
    
}


#pragma mark -
#pragma mark === Play Game ===
#pragma mark -


-(void)playGame{
    
    CCMenu* mainMenu = (CCMenu *)[self getChildByTag:kMainMenuTagValue];
    [mainMenu removeFromParentAndCleanup:YES];
    [[GameManager sharedGameManager] stopBackgroundMusic];
    [[GameManager sharedGameManager] runSceneWithID:kIntroScene];
    
}


#pragma mark -
#pragma mark ===  Game Center  ===
#pragma mark -

-(void)showAchievements{
    
    // Test Flight
    [TestFlight passCheckpoint:@"Controllo achievement"];
    TFLog(@"Controllo achievement");

    
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
    
    // Test Flight
    [TestFlight passCheckpoint:@"Controllo Leaderboard"];
    TFLog(@"Controllo leaderboard");
    
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


-(void)updateLabelForSocialCoin:(NSNotification *)notification{
    
    [self updateLabelCoinsForProductIdentifier:kProductPurchaseSocialCoins];
}

// Called when purchase is done for update label coins 

-(void)updateLabelCoinsForProductIdentifier:(NSString *)productIdentifier{
    
    [[PattyCombatIAPHelper sharedHelper] updateQuantityForProductIdentifier:productIdentifier];
    CCLabelBMFont* label = (CCLabelBMFont *)[self getChildByTag:kLabelCoinsReachedTagValue];
    
    [label setString:[NSString stringWithFormat:@"%d", [[PattyCombatIAPHelper sharedHelper] quantity]]];
    
}

// Notification CallBack when product is purchased

- (void)productPurchased:(NSNotification *)notification {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
    
    [self dismissHUD:self];    
    
    NSString *productIdentifier = (NSString *) notification.object;
    [self updateLabelCoinsForProductIdentifier:productIdentifier];
       
    // Test Flight
    TFLog(@"Prodotto comprato: %@", productIdentifier);
    
            
}

// Notification Callback when purchase is failed

- (void)productPurchaseFailed:(NSNotification *)notification {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
    [self dismissHUD:self];    
    
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
    
   self.isTouchEnabled = YES;
    _purchaseMenu.isTouchEnabled = YES;
    
   [MBProgressHUD hideHUDForView:[CCDirector sharedDirector].view animated:YES];
    self.hud = nil;
    self.isTouchEnabled = true;
    
}

//Callback when products are loaded

- (void)productsLoaded:(NSNotification *)notification {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
    self.isTouchEnabled = true;
    [self dismissHUD:self];
    
    for (CCMenuItemSprite* item in _purchaseMenu.children)
        item.opacity = 255;
    
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
    
    NSString* identifier = product.productIdentifier;
                
    TFLog(@"Comprando %@",product.productIdentifier);
        
    [[PattyCombatIAPHelper sharedHelper] buyProductIdentifier:identifier];
    
    self.hud = [MBProgressHUD showHUDAddedTo:[CCDirectorIOS sharedDirector].view animated:YES];
    _hud.labelText = @"Buying Coins...";
    [self performSelector:@selector(timeout:) withObject:nil afterDelay:60];
        
    self.isTouchEnabled = FALSE;
        
    _purchaseMenu.isTouchEnabled = FALSE;
    
    }
    
}


#pragma mark -
#pragma mark ===  Alert View Delegate   ===
#pragma mark -


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:NO];
    
    if (alertView.tag == kAlertViewSocial) {
        
    switch (buttonIndex) {
        case 0:
            break;
        case 1:
            [[SocialHelper sharedHelper] loginToFacebook:self];
            break;
        case 2:
            [[SocialHelper sharedHelper] postOnTwitter:self];
            break;
        default:
            break;
        }
    }
    
    if (alertView.tag == kALertViewReset) {
        
        switch (buttonIndex) {
            case 1:
                [self resetStats];
                break;
            default:
                break;
        }
    }
}

#pragma mark -
#pragma mark ===  Credits Delegate  ===
#pragma mark -

-(void)creditsLayerDidClose:(CreditsLayer *)layer{
    
    layer.delegate = nil;
    [self removeChild:layer cleanup:YES];
    
    CCMenu* mainMenu = (CCMenu *)[self getChildByTag:kMainMenuTagValue];
    mainMenu.isTouchEnabled = TRUE;
    
}

@end

