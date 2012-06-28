//
//  EndLayer.m
//  PattyCombat
//
//  Created by Giuseppe Lapenta on 08/10/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import "EndLayer.h"
#import "GameManager.h"
#import "GCHelper.h"
#import "GameState.h"
#import <Twitter/Twitter.h>
#import "PattyCombatIAPHelper.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "LoadingScene.h"



@implementation EndLayer

@synthesize labelScore;
@synthesize labelTimeBonus;
@synthesize labelTotalScore;


#pragma mark -
#pragma mark ===  Dealloc  ===
#pragma mark -

- (void)dealloc {
    
    
    _spriteBatchNode = nil;
    
    [self removeChildByTag:9 cleanup:YES];
    
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProductsLoadedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProductPurchaseFailedNotification object:nil];
    
}


#pragma mark -
#pragma mark ===  Touch Methods  ===
#pragma mark -


-(void) registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector]  touchDispatcher] addTargetedDelegate:self priority:-1
     
                                              swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch*)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInView:[touch view]];
    
    touchLocation = [[CCDirector sharedDirector]convertToGL:touchLocation];
    
	CCSprite* menuBtn = (CCSprite*)[_spriteBatchNode getChildByTag:kMenuBtnTagValue];
    CCSprite* nextLevel =  (CCSprite *)[_spriteBatchNode getChildByTag:kNextLevelTagValue];
    CCSprite* tweetBtn = (CCSprite *)[_spriteBatchNode getChildByTag:kTweetBtnTagValue];
    
    if (CGRectContainsPoint([tweetBtn boundingBox], touchLocation)) {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[CCDirectorIOS sharedDirector].view animated:YES];
        hud.labelText = @"Loading";
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            // Do a taks in the background
            if ([TWTweetComposeViewController canSendTweet])
            {
                
                self.isTouchEnabled = NO;
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
                        NSLog(@"Tweet sending");
                    }
                    
                    [[CCDirectorIOS sharedDirector] dismissModalViewControllerAnimated:YES];
                    self.isTouchEnabled = TRUE;
                    
                };
                [tweetSheet setInitialText:[NSString stringWithFormat:@"I got %d points in #PattyCombat Beat that! ", _totalGameScore]];
                // Hide the HUD in the main tread 
                dispatch_async(dispatch_get_main_queue(), ^{
                    [hud hide:YES];
                    [[CCDirectorIOS sharedDirector] presentViewController:tweetSheet animated:YES completion:nil];
                });
                
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
                [hud hide:YES];

            }
           
        });       
        
    }else if (CGRectContainsPoint([nextLevel boundingBox], touchLocation)) {
                
        
        if (!_thresholdReached) {
            
            NSInteger currentLevel = [[GameManager sharedGameManager] currentLevel];
            
            if (currentLevel == 1) {
             
                [[GameManager sharedGameManager] stopBackgroundMusic];
                LoadingScene* scene = [LoadingScene sceneWithTargetScene:kGamelevel1];
                [[CCDirector sharedDirector] replaceScene:scene];
                
                return YES;
            }
            
            else {
            
            NSInteger quantity = [[PattyCombatIAPHelper sharedHelper] quantity];
            
            if (quantity == 0) {
                
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Patty Coins esauriti"
                                                                message:@"Compra altri Patty Coins per continuare"
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel" 
                                                      otherButtonTitles:@"Compra", nil];
                
                [alert show];
                
                alert.tag = kAlertViewCoinsFinished;
                
                return YES;
            }
            
            if (quantity == 1) {
                
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Ultimo Gettone"
                                                                message:@"Puoi ottenere altri gettoni nello Store"
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel" 
                                                      otherButtonTitles:@"Continua",nil];
                
                [alert show];
                
                alert.tag = kAlertViewLastCoin;
                
                return YES;
                
            }
            
            if (quantity > 1) {
                    
                [[PattyCombatIAPHelper sharedHelper]
                 coinWillUsedinView:[CCDirector sharedDirector].view];
                
                [[GameManager sharedGameManager] stopBackgroundMusic];
                LoadingScene* scene = [LoadingScene sceneWithTargetScene:kGamelevel1];
                [[CCDirector sharedDirector] replaceScene:scene];

            }
        }

           

        } else{
            
            BOOL isLastLevel = [[GameManager sharedGameManager] isLastLevel];
            
            if (isLastLevel)   {
                
            [[GameManager sharedGameManager] runSceneWithID:kGamelevelFinal];
            return YES;
                
            }
            
            self.isTouchEnabled = FALSE;
            [[GameManager sharedGameManager]runSceneWithID:kIntroScene];
        }
                        
        return YES;
        
        }
    else if(CGRectContainsPoint([menuBtn boundingBox], touchLocation)) {
        
        self.isTouchEnabled = NO;
        LoadingScene* scene = [LoadingScene sceneWithTargetScene:kMainMenuScene];
        [[CCDirectorIOS sharedDirector] replaceScene:scene];
    }else{
        
        if (_scoreUpTimeBonus <= _timeBonus) _scoreUpTimeBonus = _timeBonus;
        else if(_scoreUp <= _currentLevelScore) _scoreUp = _currentLevelScore;
        else if(_scoreUpTotalScore <= _totalGameScore) _scoreUpTotalScore = _totalGameScore;
                
        return YES;
    }
    
    return NO;
}


#pragma mark -
#pragma mark ===  Update  ===
#pragma mark -


-(void) update:(ccTime)delta
{
    if(_scoreUpTimeBonus <= _timeBonus){
        
        [labelTimeBonus setString:[NSString stringWithFormat:@"%d",_scoreUpTimeBonus]];
        _scoreUpTimeBonus += 10;
        return;
        
    }else [labelTimeBonus setString:[NSString stringWithFormat:@"%d", _timeBonus]];
    
    
    if (_scoreUp <= _currentLevelScore) {
        
        [labelScore setString:[NSString stringWithFormat:@"%d", _scoreUp]];
        _scoreUp += 10;
        return;
        
    }else [labelScore setString:[NSString stringWithFormat:@"%d", _currentLevelScore]];
        
    if(_scoreUpTotalScore <= _totalGameScore){
        
        [labelTotalScore setString:[NSString stringWithFormat:@"%d",_scoreUpTotalScore]];
        _scoreUpTotalScore += 10;
            return;
            
    }else [labelTotalScore setString:[NSString stringWithFormat:@"%d", _totalGameScore]];
        
    CCSprite* nextLevel = (CCSprite *)[_spriteBatchNode getChildByTag:kNextLevelTagValue];
    CCSprite* tweetBtn = (CCSprite *)[_spriteBatchNode getChildByTag:kTweetBtnTagValue];
    CCSprite* perfectOrKo = (CCSprite *)[_spriteBatchNode getChildByTag:kPerfectOrKoTagValue];
    CCSprite* newBestRecord = (CCSprite *)[_spriteBatchNode getChildByTag:kNewRecordTagValue];
    
    perfectOrKo.opacity = 255;
    
    tweetBtn.opacity = 255;
            
    nextLevel.opacity = 255;
    
    newBestRecord.opacity = 255;
        
    CCSprite* menuBtn = (CCSprite *)[_spriteBatchNode getChildByTag:kMenuBtnTagValue];

            if (!_thresholdReached) menuBtn.opacity = 255;

            else [menuBtn removeFromParentAndCleanup:YES];
            
            [self unscheduleUpdate];
}

#pragma mark -
#pragma mark ===  Init Methods  ===
#pragma mark -

-(void)loadBackgroundAtLevel:(int)currentLevel andWin:(BOOL)win{
    
    
    CCSprite* background = [CCSprite spriteWithFile:[[[GameManager sharedGameManager]dao]
                                                     loadBackgroundEnd:@"BackgroundEnd" 
                                                     atLevel:currentLevel 
                                                     andWin:win]];
    
    [background setPosition:ccp(size.width/2, size.height/2)];
    
    [self addChild:background z:0 tag:9];
}


-(void)detectState{
    
    GameStates gameState = [[GameManager sharedGameManager] gameState];
    
    TFLog([NSString stringWithFormat:@"Game State: %d", gameState]);
    
    switch (gameState) {
            
        case kStateKo:
            _thresholdReached = YES;
            _isKo = YES;
            _isPerfect = NO;
            break;
        case kStatePerfect:
            _isPerfect = YES;
            _isKo = NO;
            _thresholdReached = YES;
            break;
        case kStateThresholdReached:
            _thresholdReached = YES;
            _isPerfect = NO;
            _isKo = NO;
            break;
        case kStateLose:
            _thresholdReached = NO;
            _isKo = NO;
            _isPerfect = NO;
            break;
        default:
            break;
    }
    

    if (_thresholdReached) {
                
        labelTimeBonus = [CCLabelBMFont labelWithString:@"0" fntFile:FONTFEEDBACK];
        
        [labelTimeBonus setAnchorPoint:ccp(1, 0)];
        
        [labelTimeBonus setPosition:ccp(size.width * 0.85f , size.height * 0.57f)];
        
        [self addChild:labelTimeBonus z:1];
                        
    }
                
    if (_isPerfect || _isKo) {
        
        NSString* nameOfLabel = nil;
        
        if (_isKo) nameOfLabel = @"ko_label.png";
        else if (_isPerfect) nameOfLabel = @"perfect_label.png";
        
        CCSprite* perfectOrKo = [CCSprite spriteWithSpriteFrameName:nameOfLabel];
        
        [perfectOrKo setPosition:ccp(size.width * 0.85f, size.height * 0.70f)];
        
        [_spriteBatchNode addChild:perfectOrKo z:kPerfectOrKoZValue tag:kPerfectOrKoTagValue];
        
        perfectOrKo.opacity = 0;
    }
    
}



-(void)onEnterTransitionDidFinish{
    
    id delay = [CCDelayTime actionWithDuration:0.5];
    
    id func = [CCCallFunc actionWithTarget:self selector:@selector(scheduleUpdate)];
    
    id play = [CCCallBlock actionWithBlock:^{
        
        (_thresholdReached) ? PLAYSOUNDEFFECT(win) : PLAYSOUNDEFFECT(lose);

    }];
    
    id seq = [CCSequence actions:delay,func,play,nil];
    
    [self runAction:seq];
    
    self.isTouchEnabled = TRUE;
    
}

-(void)sendAchievementsForLevel:(int)currentLevel{
    
    if (currentLevel == 1) {
        
        CCLOG(@"Finished level 1");
         
        if (![GameState sharedInstance].completedLevel1 && _thresholdReached) {
            
            [GameState sharedInstance].completedLevel1 = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kAchievementLevel1
                                         percentComplete:100.0];
            
            //TestFlight
            [TestFlight passCheckpoint:@"Livello 1 superato"];
        }        
    }else if (currentLevel == 2) {
        
        CCLOG(@"Finished level 2");
        
        if (![GameState sharedInstance].completedLevel2 && _thresholdReached) {
            
            [GameState sharedInstance].completedLevel2 = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kAchievementLevel2
                                         percentComplete:100.0];
            //TestFlight
            [TestFlight passCheckpoint:@"Livello 2 superato"];
        }        

    }else if (currentLevel == 3) {
        
        CCLOG(@"Finished level 3");
        
        if (![GameState sharedInstance].completedLevel3 && _thresholdReached) {
            
            [GameState sharedInstance].completedLevel3 = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kAchievementLevel3
                                         percentComplete:100.0];
            //TestFlight
            [TestFlight passCheckpoint:@"Livello 3 superato"];
        }        
        
    }else if (currentLevel == 5) {
        
        CCLOG(@"Finished level 4");
        
        if (![GameState sharedInstance].completedLevel4 && _thresholdReached) {
            
            [GameState sharedInstance].completedLevel4 = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kAchievementLevel4
                                         percentComplete:100.0];
            
                        [TestFlight passCheckpoint:@"Livello 4 superato"];
        }        
        
    }else if (currentLevel == 6) {
        
        CCLOG(@"Finished level 5");
        
        if (![GameState sharedInstance].completedLevel5 && _thresholdReached) {
            
            [GameState sharedInstance].completedLevel5 = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kAchievementLevel5
                                         percentComplete:100.0];
            
            [TestFlight passCheckpoint:@"Livello 5 superato"];
        }        
        
    }else if (currentLevel == 7) {
        
        CCLOG(@"Finished level 6");
        
        if (![GameState sharedInstance].completedLevel6 && _thresholdReached) {
            
            [GameState sharedInstance].completedLevel6 = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kAchievementLevel6
                                         percentComplete:100.0];
            
                        [TestFlight passCheckpoint:@"Livello 6 superato"];
        }        
        
    }else if (currentLevel == 9) {
        
        CCLOG(@"Finished level 7");
        
        if (![GameState sharedInstance].completedLevel7 && _thresholdReached) {
            
            [GameState sharedInstance].completedLevel7 = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kAchievementLevel7
                                         percentComplete:100.0];
            
            [TestFlight passCheckpoint:@"Livello 7 superato"];
        }        
        
    }else if (currentLevel == 10) {
        
        CCLOG(@"Finished level 8");
        
        if (![GameState sharedInstance].completedLevel8 && _thresholdReached) {
            
            [GameState sharedInstance].completedLevel8 = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kAchievementLevel8
                                         percentComplete:100.0];
            
                        [TestFlight passCheckpoint:@"Livello 8 superato"];
        }        
        
    }else if (currentLevel == 11) {
        
        CCLOG(@"Finished level 9");
        
        if (![GameState sharedInstance].completedLevel9 && _thresholdReached) {
            
            [GameState sharedInstance].completedLevel9 = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kAchievementLevel9
                                         percentComplete:100.0];
            
                        [TestFlight passCheckpoint:@"Livello 9 superato"];
        }        
        
    }else if (currentLevel == 13) {
        
        CCLOG(@"Finished level 10");
        
        if (![GameState sharedInstance].completedLevel10 && _thresholdReached) {
            
            [GameState sharedInstance].completedLevel10 = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kAchievementLevel10
                                         percentComplete:100.0];
            
            [TestFlight passCheckpoint:@"Gioco Terminato"];
            
            if (![GameState sharedInstance].extreme) {
                
                [GameState sharedInstance].extreme = true;
                [[GameState sharedInstance] save];
                [[GCHelper sharedInstance] reportAchievement:kAchievementExtreme 
                                             percentComplete:100.0];
            }
            
        }
        
        if (![GameState sharedInstance].perfect && [GameManager sharedGameManager].isPerfect) {
            
            [GameState sharedInstance].perfect = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kAchievementPerfect
                                         percentComplete:100.0];
            
                        [TestFlight passCheckpoint:@"Gioco terminato con Perfect"];
            
        }
        
        if (![GameState sharedInstance].ko && [GameManager sharedGameManager].isKo) {
            
            [GameState sharedInstance].ko = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kAchievementKO
                                         percentComplete:100.0];
            
                        [TestFlight passCheckpoint:@"gioco terminato con Ko"];

        }
        
    }


}

-(void)updatePoints{
    
    _currentLevelScore = [[GameManager sharedGameManager] currentScore];

    _totalGameScore    = [[GameManager sharedGameManager] totalScore];

    _bestScore         = [[GameManager sharedGameManager] bestScore];
    
    // Add Label total score
    
    labelTotalScore    = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d",_totalGameScore] fntFile:FONTFEEDBACK];
    
    [labelTotalScore setAnchorPoint:ccp(1, 0)];
    
    [labelTotalScore setPosition:ccp(size.width * 0.85f,size.height* 0.4f)];
    
    [self addChild:labelTotalScore z:kLabelTotalLevelScoreZValue tag:kLabelTotalLevelScoreTagValue];
    
    // Variables to scroll the score 
    
    _scoreUp = 0;
    
    _scoreUpTimeBonus = 0;
    
    int _elapsedTime = [[GameManager sharedGameManager] elapsedTime];
    
    int gameTime     = [[GameManager sharedGameManager] gameTime];
    
    // Time bonus (also 0)
    
    _timeBonus = lrint(roundf((gameTime - _elapsedTime) * 20));

    _totalGameScore += _currentLevelScore + _timeBonus;
    
    _scoreUpTotalScore = _totalGameScore;
    
    //  Total Game Score
        
    int score = (_thresholdReached) ? _totalGameScore : _totalGameScore - _currentLevelScore - _timeBonus;
    
    [[GameManager sharedGameManager] setTotalScore:score];
    
    // Check if is new record
    
    if (_bestScore < _totalGameScore) {
        
        CCSprite * newBestScore = [CCSprite spriteWithSpriteFrameName:@"record_label.png"];
        
        [newBestScore setAnchorPoint:ccp(0, 1)];
        
        [newBestScore setPosition:ccp(size.width * 0.68f, size.height * 0.35f)];
        
        [_spriteBatchNode addChild:newBestScore z:kNewRecordZValue tag:kNewRecordTagValue];
        
        newBestScore.opacity = 0;
        
        [[GameManager sharedGameManager] setBestScore:_totalGameScore];
        
        [[GCHelper sharedInstance] reportScore:kPattyLeaderboard score:_bestScore];
        
    }
    
    //TestFlight
    TFLog([NSString stringWithFormat:@"Level Score: %d", _currentLevelScore]);
    TFLog([NSString stringWithFormat:@"Total Score: %d", _totalGameScore]);
    TFLog([NSString stringWithFormat:@"Best Score: %d", _bestScore]);
    TFLog([NSString stringWithFormat:@"Time Bonus: %d", _timeBonus]);
}

- (id)init {
    
    self = [super init];
    
    if (self) {
        
         [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Feedback.plist" textureFilename:@"Feedback.pvr.ccz"];
        
         _spriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"Feedback.pvr.ccz"];
        
        [self addChild:_spriteBatchNode z:2 tag:2];
        
        size = [CCDirector sharedDirector].winSize;
                        
        // Detect the state of Game
        
        [self detectState];

        // Update Points in game
        
        [self updatePoints];
        
        int currentLevel = [[GameManager sharedGameManager] currentLevel];
        
        // Find out the achievement is active 
        
        [self sendAchievementsForLevel:currentLevel];
        
        // Load background for level
        
        [self loadBackgroundAtLevel:currentLevel andWin:_thresholdReached];
        
        // Set level reached
        
        if (_thresholdReached && [[GameManager sharedGameManager] levelReached] < currentLevel){
            
            if (currentLevel >= 4 && currentLevel < 8) currentLevel--;
            else if (currentLevel >= 8)currentLevel -= 2;
            
            [[GameManager sharedGameManager] setLevelReached:currentLevel];

        }
        
        // Add label score

        labelScore = [CCLabelBMFont labelWithString:@"0" fntFile:FONTFEEDBACK];
        
        [labelScore setAnchorPoint:ccp(1, 0)];
        
        [labelScore setPosition:ccp(size.width * 0.85f, size.height * 0.51f)];
        
        [self addChild:labelScore z:kLabelLevelScoreZValue tag:kLabelLevelScoreTagValue];
        
        // Add button next or retry
        
        CCSprite* nextLevel = [CCSprite node];
        
        if (!_thresholdReached && [[GameManager sharedGameManager] currentLevel] == 1) 
            nextLevel = [CCSprite spriteWithSpriteFrameName:@"retry_free_btn.png"];
        else if(!_thresholdReached) nextLevel = [CCSprite spriteWithSpriteFrameName:@"retry_btn.png"];
        else if (_thresholdReached)nextLevel = [CCSprite spriteWithSpriteFrameName:@"next_btn.png"];        
            
        [nextLevel setPosition:ccp(size.width* 0.87f , size.height * 0.1f)];
        [nextLevel setAnchorPoint:ccp(0, 0.5f)];
        [_spriteBatchNode addChild:nextLevel z:kNextLevelZValue tag:kNextLevelTagValue];
        
        nextLevel.opacity = 0;
        
        // Add menu button
        
        CCSprite* menuBtn = [CCSprite spriteWithSpriteFrameName:@"menu_btn.png"];
        [menuBtn setPosition:ccp(size.width * 0.08f, size.height * 0.1f)];
        [_spriteBatchNode addChild:menuBtn z:kMenuBtnZValue tag:kMenuBtnTagValue];
        
        menuBtn.opacity = 0;
        
        
        // Add twitter button
        
        CCSprite* twitterBtn = [CCSprite spriteWithSpriteFrameName:@"tweet_btn.png"];
        
        [twitterBtn setPosition:ccp(size.width * 0.95f, size.height * 0.3f)];
        
        [_spriteBatchNode addChild:twitterBtn z:kTweetBtnZValue tag:kTweetBtnTagValue];
        
        twitterBtn.opacity = 0;
        
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
#pragma mark ===  Alert View Delegate  ===
#pragma mark -

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:NO];
    
    if (alertView.tag == kAlertViewCoinsFinished) {
        
        switch (buttonIndex) {
            case 0:
                break;
            case 1:
                [[PattyCombatIAPHelper sharedHelper]
                 coinWillUsedinView:[CCDirector sharedDirector].view];
                break;
            default:
                break;
        }
    }
    
    if (alertView.tag == kAlertViewLastCoin) {
        
        switch (buttonIndex) {
            case 0:
                break;
            case 1:
            {
                [[PattyCombatIAPHelper sharedHelper]
                 coinWillUsedinView:[CCDirector sharedDirector].view];
                
                [[GameManager sharedGameManager] stopBackgroundMusic];
                LoadingScene* scene = [LoadingScene sceneWithTargetScene:kGamelevel1];
                [[CCDirector sharedDirector] replaceScene:scene];
            }
                break;
            default:
                break;
        }
    }

    
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



@end
