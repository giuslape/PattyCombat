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
    
	CCSprite* tempSprite = (CCSprite*)[self getChildByTag:10];
    CCSprite* tempRetry = (CCSprite *)[self getChildByTag:11];
    
    if (CGRectContainsPoint([tempSprite boundingBox], touchLocation)) {
        
    self.isTouchEnabled = NO;
        
    BOOL isLastLevel = [[GameManager sharedGameManager]isLastLevel];
        
    (isLastLevel || !_playerIsDied) ? [[GameManager sharedGameManager]runSceneWithID:kMainMenuScene] : [[GameManager sharedGameManager]runSceneWithID:kIntroScene];
                        
	return YES;
        
    }
    else if(CGRectContainsPoint([tempRetry boundingBox], touchLocation)) {
        
        [[GameManager sharedGameManager] runSceneWithID:kGamelevel1];
        [[PattyCombatIAPHelper sharedHelper] coinWillUsed];
    
    }else{
        
        if (_scoreUp <= _currentLevelScore) _scoreUp = _currentLevelScore;
        else if(_scoreUpTimeBonus <= _timeBonus) _scoreUpTimeBonus = _timeBonus;
        else if(_scoreUpTotalScore <= _totalGameScore)_scoreUpTotalScore = _totalGameScore;
                
        return YES;
    }
    
    return NO;
}


#pragma mark -
#pragma mark ===  Update  ===
#pragma mark -


-(void) update:(ccTime)delta
{
    
    CCSprite* nextMatch = nil;

    
        if (_scoreUp <= _currentLevelScore) {
        
            [labelScore setString:[NSString stringWithFormat:@"%d", _scoreUp]];
            _scoreUp++;
            return;
        
        }else if(_scoreUpTimeBonus <= _timeBonus){
        
        [labelTimeBonus setString:[NSString stringWithFormat:@"%d",_scoreUpTimeBonus]];
        _scoreUpTimeBonus++;
            return;
            
        }else if(_scoreUpTotalScore <= _totalGameScore){
        
        [labelTotalScore setString:[NSString stringWithFormat:@"%d",_scoreUpTotalScore]];
        _scoreUpTotalScore++;
            return;
            
        }else {
    
            nextMatch =  (_playerIsDied) ? [CCSprite spriteWithFile:@"next_btn.png"] :[CCSprite spriteWithFile:@"menu_btn.png"];
            [nextMatch setPosition:ccp (size.width - nextMatch.boundingBox.size.width , nextMatch.boundingBox.size.height)];
            [nextMatch setAnchorPoint:ccp(0, 1)];
            [self addChild:nextMatch z:0 tag:10];
            
            CCSprite* retry = [CCSprite spriteWithFile:@"menu_btn.png"];
            [retry setPosition:ccp(size.width/2, size.height/2)];
            [self addChild:retry z:1 tag:11];
            
            [self unscheduleUpdate];
            [[GameManager sharedGameManager] setTotalScore:_totalGameScore];


        }
    
    if (_bestScore < _totalGameScore) {
        
        [[GameManager sharedGameManager] setBestScore:_totalGameScore];
        
        CCSprite * newBestScore = [CCSprite spriteWithFile:@"newRecord.png"];
        
        [newBestScore setAnchorPoint:ccp(0, 1)];
        
        [newBestScore setPosition:ccp(715/2, size.height - (150/2))];
        
        [self addChild:newBestScore z:1];
        
        int64_t score = (int64_t)(_totalGameScore * 1000.0f);
        
        [[GCHelper sharedInstance] reportScore:kPattyLeaderboard score:score];
        
    }
    
}

#pragma mark -
#pragma mark ===  Init Methods  ===
#pragma mark -


-(void)onEnterTransitionDidFinish{
    
    id delay = [CCDelayTime actionWithDuration:0.5];
    
    id func = [CCCallFunc actionWithTarget:self selector:@selector(scheduleUpdate)];
    
    id seq = [CCSequence actionOne:delay two:func];
    
    [self runAction:seq];
    
    self.isTouchEnabled = TRUE;

    [[GameManager sharedGameManager] playBackgroundTrack:BACKGROUND_TRACK_MAIN_MENU];


}

-(void)sendAchievements{
    
    if (_currentLevel == 1 && _playerIsDied) {
        
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
        
        size = [CCDirector sharedDirector].winSize;
        
        _playerIsDied = [[GameManager sharedGameManager] hasPlayerDied];
        
        _currentLevel = [[GameManager sharedGameManager] currentLevel];
        
        CCSprite* background = [CCSprite spriteWithFile:[[[GameManager sharedGameManager]dao]
                                                         loadBackgroundEnd:@"BackgroundEnd" 
                                                         atLevel:_currentLevel 
                                                         andWin:_playerIsDied]];
        
        int _elapsedTime = [[GameManager sharedGameManager] elapsedTime];
        
        _currentLevelScore = [[GameManager sharedGameManager] currentScore];
        
        _totalGameScore = [[GameManager sharedGameManager] totalScore];
        
        _bestScore = [[GameManager sharedGameManager] bestScore];
        
        _scoreUp = 0;
        
        _scoreUpTotalScore = _totalGameScore;
        
        if (_playerIsDied) {
            
            _scoreUpTimeBonus = 0;
            
            _timeBonus = lrint(roundf((GAMETIME - _elapsedTime) * 20));
            
            labelTimeBonus = [CCLabelBMFont labelWithString:@"0" fntFile:FONTFEEDBACK];
            
            [labelTimeBonus setAnchorPoint:ccp(0, 0)];
            
            [labelTimeBonus setPosition:ccp(696/2 , size.height - 170)];
            
            [self addChild:labelTimeBonus z:1];
            
            [[GameManager sharedGameManager] setLevelReached:_currentLevel];
            
        }
        
        labelScore = [CCLabelBMFont labelWithString:@"0" fntFile:FONTFEEDBACK];
        
        [labelScore setAnchorPoint:ccp(0, 0)];
        
        [labelScore setPosition:ccp(696/2, size.height - 153)];
        
        [self addChild:labelScore z:1];
        
        labelTotalScore = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d", _totalGameScore] fntFile:FONTFEEDBACK];
        
        [labelTotalScore setAnchorPoint:ccp(0, 0)];
        
        [labelTotalScore setPosition:ccp(696/2,size.height - 203)];
        
        [self addChild:labelTotalScore z:1];
        
        _totalGameScore += _currentLevelScore + _timeBonus;
        
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        
        [background setPosition:ccp(size.width/2, size.height/2)];
        
        [self addChild:background z:0];
        
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        
        [self sendAchievements];
        
    }
    return self;
}

@end
