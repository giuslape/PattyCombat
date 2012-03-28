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
#import "PattyCombatIAPHelper.h"


@interface EndLayer()

@property (nonatomic, strong)CCLabelBMFont* labelScore;
@property (nonatomic, strong)CCLabelBMFont* labelTimeBonus;
@property (nonatomic, strong)CCLabelBMFont* labelTotalScore;
@property (readonly) int totalGameScore;
@property (readonly) int currentLevelScore;
@property (readonly) int bestScore;
@property (readonly) int timeBonus;
@property (readonly) int elapsedTime;
@property (readonly) int totalScore;
@property (readonly) int currentLevel;
@property int scoreUp;
@property int scoreUpTimeBonus;
@property int scoreUpTotalScore;
@property (readonly)BOOL playerIsDied;

-(void)sendAchievements;

@end

@implementation EndLayer

@synthesize labelScore;
@synthesize currentLevel;
@synthesize labelTimeBonus;
@synthesize totalGameScore;
@synthesize currentLevelScore;
@synthesize bestScore;
@synthesize scoreUp;
@synthesize timeBonus;
@synthesize elapsedTime;
@synthesize labelTotalScore;
@synthesize totalScore;
@synthesize scoreUpTimeBonus;
@synthesize scoreUpTotalScore;
@synthesize playerIsDied;


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
        
    (isLastLevel || !playerIsDied) ? [[GameManager sharedGameManager]runSceneWithID:kMainMenuScene] : [[GameManager sharedGameManager]runSceneWithID:kIntroScene];
                        
	return YES;
        
    }
    else if(CGRectContainsPoint([tempRetry boundingBox], touchLocation)) {
        
        [[GameManager sharedGameManager] runSceneWithID:kGamelevel1];
        [[PattyCombatIAPHelper sharedHelper] coinWillUsed];
    
    }else{
        
        if (scoreUp <= currentLevelScore) scoreUp = currentLevelScore;
        else if(scoreUpTimeBonus <= timeBonus) scoreUpTimeBonus = timeBonus;
        else if(scoreUpTotalScore <= totalGameScore)scoreUpTotalScore = totalGameScore;
                
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

    
        if (scoreUp <= currentLevelScore) {
        
            [labelScore setString:[NSString stringWithFormat:@"%d", scoreUp]];
            scoreUp++;
            return;
        
        }else if(scoreUpTimeBonus <= timeBonus){
        
        [labelTimeBonus setString:[NSString stringWithFormat:@"%d",scoreUpTimeBonus]];
        scoreUpTimeBonus++;
            return;
            
        }else if(scoreUpTotalScore <= totalGameScore){
        
        [labelTotalScore setString:[NSString stringWithFormat:@"%d",scoreUpTotalScore]];
        scoreUpTotalScore++;
            return;
            
        }else {
    
            nextMatch =  (playerIsDied) ? [CCSprite spriteWithFile:@"next_btn.png"] :[CCSprite spriteWithFile:@"menu_btn.png"];
            [nextMatch setPosition:ccp (screenSize.width - nextMatch.boundingBox.size.width , nextMatch.boundingBox.size.height)];
            [nextMatch setAnchorPoint:ccp(0, 1)];
            [self addChild:nextMatch z:0 tag:10];
            
            CCSprite* retry = [CCSprite spriteWithFile:@"menu_btn.png"];
            [retry setPosition:ccp(screenSize.width/2, screenSize.height/2)];
            [self addChild:retry z:1 tag:11];
            
            [self unscheduleUpdate];
            [[GameManager sharedGameManager] setTotalScore:totalGameScore];


        }
    
    if (bestScore < totalGameScore) {
        
        [[GameManager sharedGameManager] setBestScore:totalGameScore];
        
        CCSprite * newBestScore = [CCSprite spriteWithFile:@"newRecord.png"];
        
        [newBestScore setAnchorPoint:ccp(0, 1)];
        
        [newBestScore setPosition:ccp(715/2, screenSize.height - (150/2))];
        
        [self addChild:newBestScore z:1];
        
        int64_t score = (int64_t)(totalGameScore * 1000.0f);
        
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
    
    if (currentLevel == 1 && playerIsDied) {
        
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
        
        screenSize = [CCDirector sharedDirector].winSize;
        
        playerIsDied = [[GameManager sharedGameManager] hasPlayerDied];
        
        currentLevel = [[GameManager sharedGameManager] currentLevel];
        
        CCSprite* background = [CCSprite spriteWithFile:[[[GameManager sharedGameManager]dao]
                                                         loadBackgroundEnd:@"BackgroundEnd" 
                                                         atLevel:currentLevel 
                                                         andWin:playerIsDied]];
        
        elapsedTime = [[GameManager sharedGameManager] elapsedTime];
        
        currentLevelScore = [[GameManager sharedGameManager] currentScore];
        
        totalGameScore = [[GameManager sharedGameManager] totalScore];
        
        bestScore = [[GameManager sharedGameManager] bestScore];
        
        scoreUp = 0;
        
        scoreUpTotalScore = totalGameScore;
        
        if (playerIsDied) {
            
            scoreUpTimeBonus = 0;
            
            timeBonus = lrint(roundf((GAMETIME - elapsedTime) * 20));
            
            labelTimeBonus = [CCLabelBMFont labelWithString:@"0" fntFile:FONTFEEDBACK];
            
            [labelTimeBonus setAnchorPoint:ccp(0, 0)];
            
            [labelTimeBonus setPosition:ccp(696/2 , screenSize.height - 170)];
            
            [self addChild:labelTimeBonus z:1];
            
        }
        
        labelScore = [CCLabelBMFont labelWithString:@"0" fntFile:FONTFEEDBACK];
        
        [labelScore setAnchorPoint:ccp(0, 0)];
        
        [labelScore setPosition:ccp(696/2, screenSize.height - 153)];
        
        [self addChild:labelScore z:1];
        
        labelTotalScore = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d", totalGameScore] fntFile:FONTFEEDBACK];
        
        [labelTotalScore setAnchorPoint:ccp(0, 0)];
        
        [labelTotalScore setPosition:ccp(696/2,screenSize.height - 203)];
        
        [self addChild:labelTotalScore z:1];
        
        totalGameScore += currentLevelScore + timeBonus;
        
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        
        [background setPosition:ccp(screenSize.width/2, screenSize.height/2)];
        
        [self addChild:background z:0];
        
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        
        [self sendAchievements];
        
    }
    return self;
}

@end
