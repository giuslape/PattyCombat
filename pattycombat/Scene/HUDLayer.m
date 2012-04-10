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
    
    // The match is win and check if is Ko or Perfect for this level
    
    if ([[GameManager sharedGameManager] isPerfectForLevel]) [[GameManager sharedGameManager] updateGameState:kStatePerfect];
        else [[GameManager sharedGameManager] updateGameState:kStateKo];
    
    // Change state of bell
    
    [tempBell changeState:[NSNumber numberWithInt:kStateBellGongFinish]];
    
    [_delegate gameOverHandler:bar.characterState withScore:[NSNumber numberWithInt:_score]];
    
}


-(void)bellDidFinishTime:(Bell *)bell{
    
    if (_barProgress == 100) [[GameManager sharedGameManager] updateGameState:kStateKo];
        else if(_barProgress >= _threshold) [[GameManager sharedGameManager] updateGameState:kStateThresholdReached];
                else [[GameManager sharedGameManager] updateGameState:kStateLose];

    
    [_delegate gameOverHandler:bell.characterState withScore:[NSNumber numberWithInt:_score]];
    
}


#pragma mark -
#pragma mark ===  Update Methods  ===
#pragma mark -

-(void)updateStateWithDelta:(ccTime)deltaTime{
    
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
        
        CGSize size = [[CCDirectorIOS sharedDirector] winSize];
        
        isPause = FALSE;
        
        // Load Common Elements in Cache
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Common.plist"];
        
        _commonElements = [CCSpriteBatchNode batchNodeWithFile:@"Common.png"];
        
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
        
        CCMenuItemSprite* restart = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"restart_btn.png"]
                                                            selectedSprite:[CCSprite spriteWithSpriteFrameName:@"restart_btn_over.png"] 
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
                
    [[CDAudioManager sharedManager] pauseBackgroundMusic];
        
    [[CCDirectorIOS sharedDirector] pause];
        
        CCMenu* pauseMenu = (CCMenu *)[self getChildByTag:kPauseMenuTagValue];
        
        pauseMenu.opacity = 255;
        
        pauseMenu.isTouchEnabled = TRUE;
            
    }

}

-(void)resumeGame:(id)sender{
    
    isPause = FALSE;
    
    CCMenu* pauseMenu = (CCMenu *)[self getChildByTag:kPauseMenuTagValue];
    
    pauseMenu.opacity = 0;
            
    pauseMenu.isTouchEnabled = FALSE;
    
    [[CCDirectorIOS sharedDirector] resume];
    [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
    
}

-(void)mainMenu:(id)sender{
    
    CCMenu* pauseMenu = (CCMenu *)[self getChildByTag:kPauseMenuTagValue];
        
    pauseMenu.isTouchEnabled = FALSE;
        
    [self removeChild: pauseMenu cleanup:YES]; 
    
    [[CCDirectorIOS sharedDirector] resume];
    [[CDAudioManager sharedManager] stopBackgroundMusic];
    [[GameManager sharedGameManager] runSceneWithID:kMainMenuScene];
    
}

-(void)restartTapped:(id)sender{
    
    CCMenu* pauseMenu = (CCMenu *)[self getChildByTag:kPauseMenuTagValue];
    
  //  pauseMenu.isTouchEnabled = FALSE;
        
    if ([[PattyCombatIAPHelper sharedHelper] quantity] == 0) {
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Patty Coins esauriti"
                                                        message:@"Compra altri Patty Coins per continuare"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel" 
                                              otherButtonTitles:@"Compra", nil];
        
        [alert show];
        
        return;
    }
    
    [[PattyCombatIAPHelper sharedHelper] coinWillUsedinView:[CCDirector sharedDirector].view];
           
    [self removeChild: pauseMenu cleanup:YES];     
    
    [[CCDirectorIOS sharedDirector] resume];
    [[CDAudioManager sharedManager] stopBackgroundMusic];
    [[GameManager sharedGameManager] runSceneWithID:kGamelevel1];
}

#pragma mark -
#pragma mark ===  Dealloc  ===
#pragma mark -


- (void)dealloc {
    
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), self);
    
    _commonElements = nil;
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
    
    [MBProgressHUD hideHUDForView:[CCDirector sharedDirector].view animated:YES];
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:[CCDirector sharedDirector].view animated:YES];
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
	hud.mode = MBProgressHUDModeCustomView;
	hud.labelText = @"Completed";
    [hud hide:YES afterDelay:1];
    
    NSString *productIdentifier = (NSString *) notification.object;
    
    [[PattyCombatIAPHelper sharedHelper] updateQuantityForProductIdentifier:productIdentifier];
    
    NSLog(@"Purchased: %@", productIdentifier);
    
    [[CCDirector sharedDirector] pause];
    
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


//Callback when products are loaded

- (void)productsLoaded:(NSNotification *)notification {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
    [MBProgressHUD hideHUDForView:[CCDirector sharedDirector].view animated:YES];
    [[PattyCombatIAPHelper sharedHelper] coinWillUsedinView:[CCDirectorIOS sharedDirector].view];
}


#pragma mark -
#pragma mark ===  Alert View Delegate  ===
#pragma mark -

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:NO];
    
    switch (buttonIndex) {
        case 0:
            break;
        case 1:
            [[PattyCombatIAPHelper sharedHelper] coinWillUsedinView:[CCDirector sharedDirector].view];
            break;
        default:
            break;
    }
}


@end
