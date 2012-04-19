//
//  BonusLevel.m
//  pattycombat
//
//  Created by Vincenzo Lapenta on 18/04/12.
//  Copyright 2012 Fratello. All rights reserved.
//

#import "BonusLevel.h"
#import "GameManager.h"



@implementation BonusLevel

@synthesize touchAnimation;


#pragma mark -
#pragma mark ===  Init Methods  ===
#pragma mark -

- (id)init
{
    self = [super init];
    if (self) {
        
        size = [[CCDirector sharedDirector] winSize];

        [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:[NSString stringWithString:@"Common.plist"]];
        
        spriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"Common.png"];
        
        [self addChild:spriteBatchNode];
        
        [self createObjectOfType:kObjectTypeBell 
                      atLocation:ccp(40, 295) 
                      withZValue:kBellZValue];
        
        [self createObjectOfType:kObjectTypeScoreLabel
                      atLocation:ccp(410, 295)
                      withZValue:kLabelScoreZValue];
        
        CCLabelBMFont* label = [CCLabelBMFont labelWithString:@"Destroy!!!" fntFile:FONTHIGHSCORES];
        [self addChild:label z:2 tag:kLabelCountDown];
        [label setPosition:ccp(size.width/2, size.height/2)];
        
        touchCount = 0;
        
        indexSprite = 1;
        
        scoreDown = 4;
        
        score = 0;
        
        isFinish = FALSE;
        
        totalScore = [[GameManager sharedGameManager] totalScore];
        
        scoreUp = totalScore;
        
        CCSprite* handNext = [CCSprite spriteWithFile:@"next_btn.png"];
        CCMenuItemSprite* itemHand = [CCMenuItemSprite itemWithNormalSprite:handNext selectedSprite:nil target:self selector:@selector(runNewScene)];
        CCMenu* menu = [CCMenu menuWithItems:itemHand, nil];
        [menu setPosition:ccp (size.width - handNext.boundingBox.size.width , handNext.boundingBox.size.height)];
        [menu setAnchorPoint:ccp(0, 1)];
        
        [self addChild:menu z:3 tag:kHandNext];
        
        menu.opacity = 0;
        menu.enabled = FALSE;
        
    }
    return self;
}


-(void)onEnterTransitionDidFinish{
    
    [[GameManager sharedGameManager] playBackgroundTrack:BACKGROUND_TRACK_MAIN_MENU];
    [self schedule:@selector(countDown:) interval:1];
    
}

-(void)countDown:(ccTime)delta{
    
    
    CCLabelBMFont* label = (CCLabelBMFont*)[self getChildByTag:kLabelCountDown];
    
    scoreDown--;
    
    if (scoreDown == 0) {
        
        PLAYSOUNDEFFECT(BELL);
        [label removeFromParentAndCleanup:YES];
        [self unschedule:_cmd];
        [self scheduleUpdate];
        self.isTouchEnabled = TRUE;
        
    } else [label setString:[NSString stringWithFormat:@"%d",scoreDown]];
        
}

-(void)createObjectOfType:(GameObjectType)objectType atLocation:(CGPoint)spawnLocation withZValue:(int)ZValue{
    
    if (objectType == kObjectTypeBell) {
        
        Bell* bell = [Bell spriteWithSpriteFrameName:@"gong_0001.png"];
        
        [spriteBatchNode addChild:bell z:ZValue tag:kBellTagValue];
        
        [bell setPosition:spawnLocation];
        
        [bell setDelegate:self];
    }
    
    if (objectType == kObjectTypeScoreLabel) {
        
        CCLabelBMFont* labelScore = [CCLabelBMFont labelWithString:@"0" fntFile:FONTHIGHSCORES];
        
        [self addChild:labelScore z:ZValue tag:kLabelScoreTagValue];
        
        [labelScore setPosition:spawnLocation];
    }
    
}

#pragma mark -
#pragma mark ===  Update Methods  ===
#pragma mark -


-(void)updateScore:(ccTime)delta{
    
    
    CCLabelBMFont* label = (CCLabelBMFont *)[self getChildByTag:101];
    
    scoreUp++;
    
    if (scoreUp <= (totalScore + score)) {
        
        [label setString:[NSString stringWithFormat:@"%d",scoreUp]];
        
    }else {
        
        [self unschedule:_cmd];
        
        CCMenu* menu = (CCMenu *)[self getChildByTag:kHandNext];
        
        menu.opacity = 255;
        menu.enabled = YES;
                
        [[GameManager sharedGameManager] setTotalScore:scoreUp];
        
    }
    
}

-(void) update:(ccTime)delta
{
    
    GameCharacter* tempChar = (GameCharacter *)[spriteBatchNode getChildByTag:kBellTagValue];
        
    [tempChar updateStateWithDeltaTime:delta];
    
    if (indexSprite >= 6) {
        
        [tempChar changeState:[NSNumber numberWithInt:kStateBellGongFinish]];
        
    }
    
}

#pragma mark -
#pragma mark ===  Start new Game  ===
#pragma mark -

-(void)runNewScene{
    
    self.isTouchEnabled = FALSE;
    [[GameManager sharedGameManager]stopBackgroundMusic];
    [[GameManager sharedGameManager]runSceneWithID:kIntroScene];

}


#pragma mark -
#pragma mark ===  Dealloc  ===
#pragma mark -

- (void)dealloc
{
    spriteBatchNode = nil;
    [[[CCDirector sharedDirector] touchDispatcher]removeDelegate:self];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"Common.plist"];
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), self);

}

#pragma mark -
#pragma mark ===  Bell Delegate  ===
#pragma mark -

-(void)bellDidFinishTime:(Bell *)bell{
    
    [self unscheduleUpdate];
    
    isFinish = TRUE;
    
    CCLabelBMFont* label = [CCLabelBMFont labelWithString:@"Finish" fntFile:FONTHIGHSCORES];
    
    [self addChild:label z:2];
    
    [label setPosition:ccp(240,160)];
    
    [self removeChildByTag:kLabelScoreTagValue cleanup:YES];
    
    CCLabelBMFont* labelFinal = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d",score] fntFile:FONTHIGHSCORES];
    
    [self addChild:labelFinal z:2 tag:102];
    
    [labelFinal setPosition:ccp(240, 220)];
    
    CCLabelBMFont * totalScoreLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d",totalScore] fntFile:FONTHIGHSCORES];
    
    [self addChild:totalScoreLabel z:2 tag:101];
    
    [totalScoreLabel setPosition:ccp(240, 190)];
        
    [self schedule:@selector(updateScore:) interval:0.01f repeat:-1 delay:1];
    
}

@end
