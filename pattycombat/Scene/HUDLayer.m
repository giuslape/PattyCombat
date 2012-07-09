//
//  HUDLayer.m
//  PattyCombat
//
//  Created by Giuseppe Lapenta on 15/02/12.
//

#import "HUDLayer.h"
#import "SimpleAudioEngine.h"
#import "Constant.h"
#import "GameManager.h"
#import "PattyCombatIAPHelper.h"
#import "MBProgressHUD.h"
#import "LoadingScene.h"
#import "SocialHelper.h"


@implementation HUDLayer

@synthesize pauseButton = _pauseButton;
@synthesize delegate = _delegate;
@synthesize score = _score;
@synthesize comboMoltiplicator = _comboMoltiplicator;
@synthesize scoreLabel = _scoreLabel;


#pragma mark -
#pragma mark === Score ===
#pragma mark -

-(int)score{
    
    int signValue = (_touchIsOk) ? 1: 0;
    int signValueProgress = (_touchIsOk) ? 1 : -2;
    int moltiplicator = self.comboMoltiplicator;
    
    _barProgress += (signValueProgress * kScore * moltiplicator);
    
    if (_barProgress < 0) _barProgress = 0;
    
    _score += (signValue * kScore * moltiplicator);
    
    if (_score < 0) _score = 0;
    
    return _score;
}


-(void)setScore:(int)newScore{
    
    _score = newScore;
}


#pragma mark -
#pragma mark === Combo Moltiplicator ===
#pragma mark -

-(int)comboMoltiplicator{
    
    if (_touchIsOk)_comboMoltiplicator++;
    else _comboMoltiplicator = 1;
    
    return _comboMoltiplicator;
}

-(void)setComboMoltiplicator:(int)comboMoltiplicatorValue{
    
    _comboMoltiplicator = comboMoltiplicatorValue;
}

#pragma mark -
#pragma mark ===  Protocol Methods  ===
#pragma mark -

-(void)barDidEmpty:(GPBar *)bar{
    
    Bell* tempBell = (Bell *)[_commonElements getChildByTag:kBellTagValue];
    [tempBell changeState:[NSNumber numberWithInt:kStateBellGongFinish]];
        
}


-(void)bellDidFinishTime:(Bell *)bell{
    
    if ([[GameManager sharedGameManager] isPerfectForLevel] && _barProgress >= 100)
        [[GameManager sharedGameManager] updateGameState:kStatePerfect];
    else if (_barProgress >= 100) 
            [[GameManager sharedGameManager] updateGameState:kStateKo];
        else if(_barProgress >= _threshold)
                [[GameManager sharedGameManager] updateGameState:kStateThresholdReached];
                else [[GameManager sharedGameManager] updateGameState:kStateLose];
    
    [_delegate gameOverHandler:bell.characterState withScore:[NSNumber numberWithInt:_score]];
    
}


#pragma mark -
#pragma mark ===  Update Methods  ===
#pragma mark -

-(void)updateStateWithDelta:(ccTime)deltaTime{
    
    _elapsedTime += deltaTime;
    
    if (_elapsedTime > 10 && [[GameManager sharedGameManager] isTutorial] && _barProgress < 20 && _helpAlert) {
        
        _helpAlert = NO;
        
        [self onPause:self];
    }
    
    GameCharacter* bellChar = (GameCharacter*)[_commonElements getChildByTag:kBellTagValue];
    
    [bellChar updateStateWithDeltaTime:deltaTime];
    
}

-(void)updateHealthBar:(BOOL)touch{
   
    _touchIsOk = touch;
    
    GPBar* bar = (GPBar *)[self getChildByTag:kHealthTagValue];
    
    int currentScore = self.score;
            
    if (_touchIsOk) [_scoreLabel setString:[NSString stringWithFormat:@"%d",currentScore]];
    
    [bar setProgress:_barProgress];
    
}


#pragma mark -
#pragma mark ===  Init Methods  ===
#pragma mark -


-(void)createObjectOfType:(GameObjectType)objectType 
               atLocation:(CGPoint)spawnLocation
               withZValue:(int)ZValue{
    
    
    if (kObjectTypeBell == objectType) {
        
        Bell* bell = [Bell spriteWithSpriteFrameName:@"gong_0001.png"];
        [bell setPosition:spawnLocation];
        [_commonElements addChild:bell z:ZValue tag:kBellTagValue];
        
        [bell setDelegate:self];
    }
    if (kObjectTypeHealth == objectType) {
        
        NSString* namePlayer = [[GameManager sharedGameManager] formatPlayerNameTypeToString];
        GPBar* bar = [GPBar barWithBarFrameName:@"bar_red.png" insetFrameName:@"bar_mask.png" maskFrameName:@"bar_mask.png"];
        [bar setPosition:spawnLocation];
        [self  addChild:bar z:ZValue tag:kHealthTagValue];
        [bar setDelegate:self];
        
        CCLabelBMFont* namePlayerLabel = [CCLabelBMFont labelWithString:namePlayer fntFile:FONTHIGHSCORES];
        [namePlayerLabel setPosition:ccp(240, 290)];
        [self addChild:namePlayerLabel z:3];
        [namePlayerLabel setScale:0.8f];
    }
    if (kObjectTypeScoreLabel == objectType){
        
        _scoreLabel = [CCLabelBMFont labelWithString:@"0" fntFile:FONTHIGHSCORES];
        
        [self addChild:_scoreLabel z:ZValue tag:kLabelScoreTagValue];
        [_scoreLabel setAnchorPoint:ccp(1, 0)];
        [_scoreLabel setPosition:spawnLocation];
        [_scoreLabel setScale:0.8];
        
    }
    
}

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        _threshold = 60;
                
        _score = 0;
        
        _barProgress = 0;
        
        _helpAlert = ([[GameManager sharedGameManager] isTutorial]) ? YES : NO;
        CGSize size = [[CCDirectorIOS sharedDirector] winSize];
        
        isPause = FALSE;
        
        // Load Common Elements in Cache
        
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Common.plist" textureFilename:@"Common.pvr.ccz"];
        
        _commonElements = [CCSpriteBatchNode batchNodeWithFile:@"Common.pvr.ccz"];
        
        [self addChild:_commonElements];
                        
        [self createObjectOfType:kObjectTypeBell
                      atLocation:ccp(size.width * 0.083f , size.height* 0.92f) 
                      withZValue:kBellZValue];
        
        [self createObjectOfType:kObjectTypeHealth
                      atLocation:ccp(0, size.height * 0.44f)
                      withZValue:kHealthZValue];
        
        [self createObjectOfType:kObjectTypeScoreLabel
                      atLocation:ccp(size.width * 0.98f, size.height * 0.92f)
                      withZValue:kLabelScoreZValue];
        
        
        // Add Pause Button
        _pauseButton = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"pause_btn.png"]];
        
        [_commonElements addChild:_pauseButton z:10 tag:11];
        
        _pauseButton.position = ccp(size.width * 0.96f, size.height * 0.0625f);
        
        _pauseButton.flipX = YES;
        
        // Add Menu pause

        CCMenuItemSprite* resume = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"resume_btn.png"] 
                                                           selectedSprite:[CCSprite spriteWithSpriteFrameName:@"resume_btn_over.png"] 
                                                                   target:self 
                                                                        selector:@selector(resumeGame:)];
        
        NSInteger currentLevel = [[GameManager sharedGameManager] currentLevel];
        
        NSString* nameSprite = (currentLevel == 1) ? [NSString stringWithString:@"restart_free_btn.png"] : [NSString stringWithString:@"restart_btn.png"];
        
        NSString* nameSpriteOver = (currentLevel == 1) ? [NSString stringWithString:@"restart_free_btn_over.png"] : [NSString stringWithString:@"restart_btn_over.png"];
        
        CCMenuItemSprite* restart = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:nameSprite]
                                                            selectedSprite:[CCSprite spriteWithSpriteFrameName:nameSpriteOver] 
                                                                    target:self selector:@selector(restartTapped:)];
                                                                       
        
        CCMenuItemSprite* mainMenu = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"giveup_btn.png"] 
                                                             selectedSprite:[CCSprite spriteWithSpriteFrameName:@"giveup_btn_over.png"] 
                                                                     target:self 
                                                                        selector:@selector(mainMenu:)];
        
        CCMenu *pauseMenu = [CCMenu menuWithItems:resume,restart,mainMenu, nil];
        
        [pauseMenu alignItemsVerticallyWithPadding:20];
        
        [self addChild:pauseMenu z:kPauseMenuZValue tag:kPauseMenuTagValue];
        
        pauseMenu.opacity = 0;
        
        pauseMenu.position = ccp(size.width/2,size.height/2);
        
        pauseMenu.isTouchEnabled = FALSE;
        
        self.isTouchEnabled = YES;
        
        
        // Add Observer for Purchase Notification
        
        [[NSNotificationCenter defaultCenter]    addObserver:self
                                                    selector:@selector(productPurchased:)
                                                        name:kProductPurchasedNotification
                                                      object:nil];
        
        [[NSNotificationCenter defaultCenter]       addObserver:self 
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


#pragma mark -
#pragma mark ===  Touch Handler  ===
#pragma mark -

-(void) registerWithTouchDispatcher
{
    [[[CCDirectorIOS sharedDirector] touchDispatcher] addTargetedDelegate:self priority:-1 swallowsTouches:YES];
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    
    CGPoint touchLocation = [touch locationInView:[touch view]];
    
    touchLocation = [[CCDirectorIOS sharedDirector] convertToGL:touchLocation];
    touchLocation = [self convertToNodeSpace:touchLocation];
    
    // Mi serve per fermate la catena di Responder
    
    if (isPause) return YES;
    
    if (CGRectContainsPoint([_pauseButton boundingBox], touchLocation)) {
        
        [self onPause:self];
        return YES;
    }
    
    return NO;
}


#pragma mark -
#pragma mark ===  Events Handler  ===
#pragma mark -


-(void)onPause:(id)sender{
    
    if (!isPause) {
        
        isPause = TRUE;
    
        [_delegate pauseDidEnter:self];
        
        [[CCDirectorIOS sharedDirector] pause];
        
        [[CDAudioManager sharedManager] pauseBackgroundMusic];
        
        CCMenu* pauseMenu = (CCMenu *)[self getChildByTag:kPauseMenuTagValue];
        
        pauseMenu.opacity = 255;
        
        pauseMenu.isTouchEnabled = TRUE;
            
        //TestFlight
        TFLog(@"Pausa nel gioco");
        

    }

}

-(void)resumeGame:(id)sender{
    
    //TestFlight
    TFLog(@"Resume");
        
    [[GameManager sharedGameManager] resumeBackgroundMusic];
        
    isPause = FALSE;
    
    CCMenu* pauseMenu = (CCMenu *)[self getChildByTag:kPauseMenuTagValue];
    
    pauseMenu.opacity = 0;
            
    pauseMenu.isTouchEnabled = FALSE;
    
    [[CCDirectorIOS sharedDirector] resume];
    
    [_delegate pauseDidExit:self];

}

-(void)mainMenu:(id)sender{
    
    //TestFlight
    TFLog(@"Ritorno al main menu");
    
    [_delegate pauseDidExit:self];
    
    CCMenu* pauseMenu = (CCMenu *)[self getChildByTag:kPauseMenuTagValue];
        
    pauseMenu.isTouchEnabled = FALSE;
        
    [self removeChild:pauseMenu cleanup:YES]; 
    
    [[CCDirectorIOS sharedDirector]  resume];
    [[GameManager sharedGameManager] stopBackgroundMusic];
    LoadingScene* scene = [LoadingScene sceneWithTargetScene:kMainMenuScene];
    [[CCDirectorIOS sharedDirector] replaceScene:scene];
}

-(void)restartTapped:(id)sender{
    
    //TestFlight
    TFLog(@"Restart");
    
    NSInteger currentLevel = [[GameManager sharedGameManager] currentLevel];
    
    if (currentLevel == 1) {
    
        CCMenu* pauseMenu = (CCMenu *)[self getChildByTag:kPauseMenuTagValue];
        [self removeChild: pauseMenu cleanup:YES];
        [[CCDirectorIOS sharedDirector]  resume];
        [[GameManager sharedGameManager] stopBackgroundMusic];
        LoadingScene* scene = [LoadingScene sceneWithTargetScene:kGamelevel1];
        [[CCDirector sharedDirector] replaceScene:scene];
        return;
    }
    
    NSInteger quantity = [[PattyCombatIAPHelper sharedHelper] quantity];
        
    if (quantity == 0) {
        
        _alert = [[UIAlertTableView alloc] initWithTitle:@"You've run out of coins" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        ;                
        _alert.tag = kAlertViewCoinsFinished;
        
        [_alert setTableDelegate:self];
        [_alert setDataSource:self];
        
        [_alert show];

        return;
    }
    
    if (quantity == 1) {
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"One Coin Left"
                                                        message:@"Want to use your last coin now? \n Remember You can get more coins in the Store"
                                                       delegate:self
                                              cancelButtonTitle:@"No" 
                                              otherButtonTitles:@"Yes",nil];
        
        [alert show];
        
        alert.tag = kAlertViewLastCoin;
        
    }
    
    if (quantity > 1) {
        
        [[PattyCombatIAPHelper sharedHelper]
         coinWillUsedinView:[CCDirector sharedDirector].view forProductIdentifier:nil];
        CCMenu* pauseMenu = (CCMenu *)[self getChildByTag:kPauseMenuTagValue];
        [self removeChild: pauseMenu cleanup:YES];
        [[CCDirectorIOS sharedDirector]  resume];
        [[GameManager sharedGameManager] stopBackgroundMusic];
        LoadingScene* scene = [LoadingScene sceneWithTargetScene:kGamelevel1];
        [[CCDirectorIOS sharedDirector] replaceScene:scene];

    }

}

#pragma mark -
#pragma mark ===  Dealloc  ===
#pragma mark -


- (void)dealloc {
    
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), self);
    
    _delegate = nil;
    _commonElements = nil;
    _productId = nil;
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"Common.plist"];

    [[[CCDirectorIOS sharedDirector] touchDispatcher] removeDelegate:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProductsLoadedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProductPurchaseFailedNotification object:nil];

}

#pragma mark -
#pragma mark ===  App Purchase  ===
#pragma mark -

// Notification CallBack when product is purchased

- (void)productPurchased:(NSNotification *)notification {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
    CCMenu* pauseMenu = (CCMenu *)[self getChildByTag:kPauseMenuTagValue];
    
    pauseMenu.isTouchEnabled = TRUE;
    
    [MBProgressHUD hideHUDForView:[CCDirector sharedDirector].view animated:YES];
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:[CCDirector sharedDirector].view animated:YES];
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
	hud.mode = MBProgressHUDModeCustomView;
	hud.labelText = @"Completed";
    [hud hide:YES afterDelay:1];
    
    NSString *productIdentifier = (NSString *) notification.object;
    
    [[PattyCombatIAPHelper sharedHelper] updateQuantityForProductIdentifier:productIdentifier];
    
    NSLog(@"Purchased: %@", productIdentifier);
    //TestFlight
    [TestFlight passCheckpoint:@"Comprati 30 gettoni nel gioco"];
        
}

// Notification Callback when purchase is failed

- (void)productPurchaseFailed:(NSNotification *)notification {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
    [MBProgressHUD hideHUDForView:[CCDirector sharedDirector].view animated:YES];
    
    CCMenu* pauseMenu = (CCMenu *)[self getChildByTag:kPauseMenuTagValue];
    
    pauseMenu.isTouchEnabled = TRUE;
    
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


//Callback when products are loaded

- (void)productsLoaded:(NSNotification *)notification {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
    [MBProgressHUD hideHUDForView:[CCDirector sharedDirector].view animated:YES];
    bool reach = [[PattyCombatIAPHelper sharedHelper] coinWillUsedinView:[CCDirectorIOS sharedDirector].view forProductIdentifier:_productId];
    if (!reach) {
        CCMenu* pauseMenu = (CCMenu *)[self getChildByTag:kPauseMenuTagValue];
        pauseMenu.isTouchEnabled = true;
    }
}


#pragma mark -
#pragma mark ===  Alert View Delegate  ===
#pragma mark -

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:NO];
      
    if (alertView.tag == kAlertViewLastCoin) {
        
        switch (buttonIndex) {
            case 0:
                break;
            case 1:
            {
                [[PattyCombatIAPHelper sharedHelper]
                 coinWillUsedinView:[CCDirector sharedDirector].view forProductIdentifier:nil];
                CCMenu* pauseMenu = (CCMenu *)[self getChildByTag:kPauseMenuTagValue];
                [[CCDirectorIOS sharedDirector]  resume];
                [self removeChild: pauseMenu cleanup:YES];    
                [[GameManager sharedGameManager] stopBackgroundMusic];
                LoadingScene* scene = [LoadingScene sceneWithTargetScene:kGamelevel1];
                [[CCDirectorIOS sharedDirector] replaceScene:scene];
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark ===  Table Alert View  ===
#pragma mark -


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    	
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	
    NSString* text = [NSString string];
    
    bool isFirstPostFb = [[NSUserDefaults standardUserDefaults] boolForKey:@"FirstPostFacebook"]; 
    
    bool isFirstPostTw = [[NSUserDefaults standardUserDefaults] boolForKey:@"FirstPostTw"];
    
    switch (indexPath.row) {
        case 0:
            if (!isFirstPostFb)text = @"5 free coins - Facebook";
            else if (!isFirstPostTw)text = @"5 free coins - Twitter";
            else text = @"Buy 30 coins";
            break;
        case 1:
            if (!isFirstPostFb && !isFirstPostTw) text = @"5 free coins - Twitter";
            else if (!isFirstPostTw || !isFirstPostFb) text = @"Buy 30 coins";
            else text = @"Buy 90 coins";
            break;
        case 2:
            if (!isFirstPostFb && !isFirstPostTw) text = @"Buy 30 coins";
            else if (!isFirstPostTw || !isFirstPostFb) text = @"Buy 90 coins";
            else text = @"Buy 300 coins";
            break;
        case 3:
            if (!isFirstPostFb && !isFirstPostTw) text = @"Buy 90 coins";
            else if (!isFirstPostTw || !isFirstPostFb) text = @"Buy 300 coins";
            break;
        case 4:
            text = @"Buy 300 coins";
            break;
        default:
            break;
    }
    
	[cell.textLabel setText:text];
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    bool isFirstPostFb = [[NSUserDefaults standardUserDefaults] boolForKey:@"FirstPostFacebook"]; 
    
    bool isFirstPostTw = [[NSUserDefaults standardUserDefaults] boolForKey:@"FirstPostTw"];
    
    if (!isFirstPostFb && !isFirstPostTw) return 5;
    else if (!isFirstPostFb || !isFirstPostTw) return 4; 
    else return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString* text = cell.textLabel.text;
    
    if ([text isEqualToString:@"Facebook"])    [[SocialHelper sharedHelper] loginToFacebook:self];
    else if([text isEqualToString:@"Twitter"]) [[SocialHelper sharedHelper] postOnTwitter:self];
    else if([text isEqualToString:@"Buy 30 coins"]) 
        _productId = kProductPurchase30coins;
    else if([text isEqualToString:@"Buy 90 coins"]) 
        _productId = kProductPurchase90coins;
    else if([text isEqualToString:@"Buy 300 coins"]) 
        _productId = kProductPurchase300coins;
    
    [_alert dismissWithClickedButtonIndex:indexPath.row animated:YES];
    if (_productId) {
        CCMenu* pauseMenu = (CCMenu *)[self getChildByTag:kPauseMenuTagValue];
        pauseMenu.isTouchEnabled = false;
        bool reach = [[PattyCombatIAPHelper sharedHelper] coinWillUsedinView:[CCDirector sharedDirector].view 
                                           forProductIdentifier:_productId];
        if (!reach) {
            pauseMenu.isTouchEnabled = true;
        }
    }
    
}



@end
