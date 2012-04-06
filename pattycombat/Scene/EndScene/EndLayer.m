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



@implementation EndLayer

@synthesize labelScore;
@synthesize labelTimeBonus;
@synthesize labelTotalScore;


#pragma mark -
#pragma mark ===  Dealloc  ===
#pragma mark -

- (void)dealloc {
    
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    
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
                [tweetSheet setInitialText:[NSString stringWithFormat:@"I got %d points in Patty Combat Beat that!", _totalGameScore]];
                // Hide the HUD in the main tread 
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:[CCDirectorIOS sharedDirector].view animated:YES];
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
            }
            

           
        });       
        
    }else if (CGRectContainsPoint([nextLevel boundingBox], touchLocation)) {
        
        self.isTouchEnabled = NO;
        
        BOOL isLastLevel = [[GameManager sharedGameManager]isLastLevel];
        
        (isLastLevel || !_thresholdReached) ? [[GameManager sharedGameManager]runSceneWithID:kGamelevel1] : [[GameManager sharedGameManager]runSceneWithID:kIntroScene];
                        
        return YES;
        
        }
    else if(CGRectContainsPoint([menuBtn boundingBox], touchLocation)) {
        
        self.isTouchEnabled = NO;

        [[GameManager sharedGameManager] runSceneWithID:kMainMenuScene];
       // [[PattyCombatIAPHelper sharedHelper] coinWillUsed];
    
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
    
    perfectOrKo.opacity = 255;
    
    tweetBtn.opacity = 255;
            
    nextLevel.opacity = 255;
        
    CCSprite* menuBtn = (CCSprite *)[_spriteBatchNode getChildByTag:kMenuBtnTagValue];

            if (!_thresholdReached) menuBtn.opacity = 255;

            else [menuBtn removeFromParentAndCleanup:YES];
            
                       
            [self unscheduleUpdate];
            [[GameManager sharedGameManager] setTotalScore:_totalGameScore];

                
    if (_bestScore < _totalGameScore) {
        
        CCSprite* newRecord = (CCSprite *)[_spriteBatchNode getChildByTag:kNewRecordTagValue];
        
        newRecord.opacity = 255;
        
        [[GameManager sharedGameManager] setBestScore:_totalGameScore];
        
        int64_t score = (int64_t)(_totalGameScore * 1000.0f);
        
        [[GCHelper sharedInstance] reportScore:kPattyLeaderboard score:score];
        
    }
    
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
    
    [self addChild:background z:0];
    
}


-(void)detectState{
    
    GameStates gameState = [[GameManager sharedGameManager] gameState];
    
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
        
        int _elapsedTime = [[GameManager sharedGameManager] elapsedTime];
        
        _scoreUpTimeBonus = 0;
        
        _timeBonus = lrint(roundf((GAMETIME - _elapsedTime) * 20));
        
        labelTimeBonus = [CCLabelBMFont labelWithString:@"0" fntFile:FONTFEEDBACK];
        
        [labelTimeBonus setAnchorPoint:ccp(1, 0)];
        
        [labelTimeBonus setPosition:ccp(size.width * 0.85f , size.height * 0.57f)];
        
        [self addChild:labelTimeBonus z:1];

    }
    
    int currentLevel = [[GameManager sharedGameManager] currentLevel];

    [[GameManager sharedGameManager] setLevelReached:currentLevel];
    
    [self loadBackgroundAtLevel:currentLevel andWin:_thresholdReached];
    
    [self sendAchievementsForLevel:currentLevel];
    
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
    
    id seq = [CCSequence actionOne:delay two:func];
    
    [self runAction:seq];
    
    self.isTouchEnabled = TRUE;

    [[GameManager sharedGameManager] playBackgroundTrack:BACKGROUND_TRACK_MAIN_MENU];


}

-(void)sendAchievementsForLevel:(int)currentLevel{
    
    if (currentLevel == 1) {
        
        CCLOG(@"Finished level 1");
         
        if (![GameState sharedInstance].completedLevel1) {
            
            [GameState sharedInstance].completedLevel1 = true;
            [[GameState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:kAchievementLevel1
                                         percentComplete:100.0];
            
        }
    }
    
}

- (id)init {
    
    self = [super init];
    
    if (self) {
        
         [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Feedback_default.plist"];
        
         _spriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"Feedback_default.png"];
        
        [self addChild:_spriteBatchNode z:2 tag:2];
        
        size = [CCDirector sharedDirector].winSize;
                
        [self detectState];
        
        _currentLevelScore = [[GameManager sharedGameManager] currentScore];
        
        _totalGameScore = [[GameManager sharedGameManager] totalScore];
        
        _bestScore = [[GameManager sharedGameManager] bestScore];
        
        _scoreUp = 0;
        
        _scoreUpTotalScore = _totalGameScore;
        
        labelScore = [CCLabelBMFont labelWithString:@"0" fntFile:FONTFEEDBACK];
        
        [labelScore setAnchorPoint:ccp(1, 0)];
        
        [labelScore setPosition:ccp(size.width * 0.85f, size.height * 0.51f)];
        
        [self addChild:labelScore z:kLabelLevelScoreZValue tag:kLabelLevelScoreTagValue];
        
        labelTotalScore = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d", _totalGameScore] fntFile:FONTFEEDBACK];
        
        [labelTotalScore setAnchorPoint:ccp(1, 0)];
        
        [labelTotalScore setPosition:ccp(size.width * 0.85f,size.height* 0.4f)];
        
        [self addChild:labelTotalScore z:kLabelTotalLevelScoreZValue tag:kLabelTotalLevelScoreTagValue];
        
        _totalGameScore += _currentLevelScore + _timeBonus;
        
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        
        
        CCSprite* nextLevel =  (_thresholdReached) ? [CCSprite spriteWithSpriteFrameName:@"next_btn.png"] :[CCSprite spriteWithSpriteFrameName:@"retry_btn.png"];
        
        [nextLevel setPosition:ccp (size.width* 0.87f , size.height * 0.1f)];
        [nextLevel setAnchorPoint:ccp(0, 0.5f)];
        [_spriteBatchNode addChild:nextLevel z:kNextLevelZValue tag:kNextLevelTagValue];
        
        nextLevel.opacity = 0;
        
        CCSprite* menuBtn = [CCSprite spriteWithSpriteFrameName:@"menu_btn.png"];
        [menuBtn setPosition:ccp(size.width * 0.08f, size.height * 0.1f)];
        [_spriteBatchNode addChild:menuBtn z:kMenuBtnZValue tag:kMenuBtnTagValue];
        
        menuBtn.opacity = 0;
        
        if (_bestScore < _totalGameScore) {
                    
        CCSprite * newBestScore = [CCSprite spriteWithSpriteFrameName:@"record_label.png"];
        
        [newBestScore setAnchorPoint:ccp(0, 1)];
        
        [newBestScore setPosition:ccp(size.width * 0.75f, size.height * 0.3f)];
        
        [_spriteBatchNode addChild:newBestScore z:kNewRecordZValue tag:kNewRecordTagValue];
        
        newBestScore.opacity = 0;
            
        }
        
        CCSprite* twitterBtn = [CCSprite spriteWithSpriteFrameName:@"tweet_btn.png"];
        
        [twitterBtn setPosition:ccp(size.width * 0.95f, size.height * 0.3f)];
        
        [_spriteBatchNode addChild:twitterBtn z:kTweetBtnZValue tag:kTweetBtnTagValue];
        
        twitterBtn.opacity = 0;
        
           
    }
    return self;
}

@end
