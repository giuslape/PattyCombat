//
//  WallLayer.m
//  PattyCombat
//
//  Created by Giuseppe Lapenta on 23/11/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import "WallLayer.h"
#import "Constant.h"
#import "GameManager.h"
#import "Bell.h"
#import "GameCharacter.h"


#define kAnimationTouch 100
#define kHandNext 103
#define kLabelCountDown 300


@interface WallLayer()

@property (readwrite)int touchCount;
@property (readwrite)int indexSprite;
@property (readwrite)int scoreDown;
@property (readwrite)int score;
@property (readwrite)int scoreUp;
@property (readwrite)int totalScore;
@property (readwrite)BOOL isFinish;

-(void)updateWall:(CGPoint)location;

@end

@implementation WallLayer

@synthesize  touchCount;
@synthesize  indexSprite;
@synthesize  scoreDown;
@synthesize  score;
@synthesize totalScore;
@synthesize touchAnimation;
@synthesize scoreUp;
@synthesize isFinish;


-(void)initAnimation{
    
    CCAnimation* tempAnimation = [CCAnimation animation];
    

    for (int i = 0; i<=4; i++) {
        
        [tempAnimation addSpriteFrameWithFilename:[NSString stringWithFormat:@"muretto_touch_000%d.png",i]];
    }
    
    [self setTouchAnimation:tempAnimation];
    [touchAnimation setDelayPerUnit:0.08];
    
    
}

-(void)onEnterTransitionDidFinish{
    
    [[GameManager sharedGameManager] playBackgroundTrack:BACKGROUND_TRACK_MAIN_MENU];
    [self schedule:@selector(countDown:) interval:1];
    
}

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        size = [[CCDirector sharedDirector] winSize];
        
        CCSprite* wall = [CCSprite spriteWithFile:@"muretto_0001.png"];
        
        [self addChild:wall z:kWallZValue tag:kWallTagValue];
        
        [wall setAnchorPoint:ccp(0, 1)];
        
        [wall setPosition:ccp(78, size.height - 63)];
        
        touchCount = 0;
        
        indexSprite = 1;
        
        scoreDown = 4;
        
        score = 0;
                
        isFinish = FALSE;
                        
        [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:[NSString stringWithString:@"Common.plist"]];
        
        spriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"Common.png"];
        
        [self addChild:spriteBatchNode];
        
        [self createObjectOfType:kObjectTypeBell 
                      atLocation:ccp(40, 295) 
                      withZValue:kBellZValue];
        
        [self createObjectOfType:kObjectTypeScoreLabel
                      atLocation:ccp(410, 295)
                      withZValue:kLabelScoreZValue];
        
        CCLabelBMFont* label = [CCLabelBMFont labelWithString:@"Ready" fntFile:FONTLETTERS];
        [self addChild:label z:2 tag:kLabelCountDown];
        [label setPosition:ccp(size.width/2, size.height/2)];
        
        [self initAnimation];

        totalScore = [[GameManager sharedGameManager] totalScore];
        
        scoreUp = totalScore;

        
        
    }
    return self;
}



-(CGRect)adjustBoundingBox{
    
    CCSprite* wall = (CCSprite *)[self getChildByTag:kWallTagValue];
    
    CGRect wallBoundingBox = [wall boundingBox];
    
    float yCropAmount;
    
    switch (indexSprite) {
        case 1:
            yCropAmount = wallBoundingBox.size.height*0;
            break;
        case 2:
            yCropAmount = wallBoundingBox.size.height*0.17;
            break;
        case 3:
            yCropAmount = wallBoundingBox.size.height*0.43;
            break;
        case 4:
            yCropAmount = wallBoundingBox.size.height*0.58;
            break;
        case 5:
            yCropAmount = wallBoundingBox.size.height*0.71;
            break;
        case 6:
            yCropAmount = wallBoundingBox.size.height;
            break;
        default:
            yCropAmount = wallBoundingBox.size.height;
            break;
    }
    
    wallBoundingBox = CGRectMake(wallBoundingBox.origin.x, wallBoundingBox.origin.y, wallBoundingBox.size.width, wallBoundingBox.size.height - yCropAmount);
    
    
    return wallBoundingBox;
    
    
}


-(void) registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:-1
     
                                              swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch*)touch withEvent:(UIEvent *)event
{
    
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector]convertToGL:location];
    
    CGRect myBoundingBox = [self adjustBoundingBox];
    
    CCSprite* hand = (CCSprite *)[self getChildByTag:kHandNext];
    
    if(CGRectContainsPoint([hand boundingBox], location)){ 
        
        self.isTouchEnabled = FALSE;
        [[GameManager sharedGameManager]stopBackgroundMusic];
        [[GameManager sharedGameManager]runSceneWithID:kIntroScene];
        return YES;
    }
        
    if (CGRectContainsPoint(myBoundingBox, location) && !isFinish) {
        
        [self updateWall:location];
        
        return YES;
        
    } 
    
    if (isFinish)scoreUp = totalScore + score - 1;
    
    return NO;
}


-(void)updateWall:(CGPoint)location{
    
    if (indexSprite >= 6)return;
    
    PLAYSOUNDEFFECT(PERFECT_TAP);
    
    score+= 5;
    
    CCSprite* tempSprite = (CCSprite *)[self getChildByTag:kWallTagValue];

    
    CCLabelBMFont* label = (CCLabelBMFont *)[self getChildByTag:kLabelScoreTagValue];
    

    touchCount++;

    if (touchCount % kTapForProgress == 0) {
        
        
        indexSprite++;
        
        score+= 50;
                                
        [tempSprite setTexture:[[CCTextureCache sharedTextureCache]addImage:[NSString stringWithFormat:@"muretto_000%d.png",indexSprite]]];
        
        
    }
    
    [label setString:[NSString stringWithFormat:@"%d",score]];
    
    CCSprite * temp = [CCSprite spriteWithFile:@"muretto_touch_0001.png"];

    [temp runAction:[CCAnimate actionWithAnimation:touchAnimation]];
    
    [temp setPosition:location];
    
    [self addChild:temp z:2 tag:kAnimationTouch];
    
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

- (void)dealloc {
    
    CCLOG(@"%@, %@",NSStringFromSelector(_cmd), self);
    
    [[[CCDirector sharedDirector] touchDispatcher]removeDelegate:self];
    
    
}

-(void)updateScore:(ccTime)delta{
    
    
    CCLabelBMFont* label = (CCLabelBMFont *)[self getChildByTag:101];
    
    scoreUp++;
    
    if (scoreUp <= (totalScore + score)) {
        
        [label setString:[NSString stringWithFormat:@"%d",scoreUp]];
        
    }else {
        
        [self unschedule:_cmd];
        
        CCSprite* handNext = [CCSprite spriteWithFile:@"next_btn.png"];
        [handNext setPosition:ccp (size.width - handNext.boundingBox.size.width , handNext.boundingBox.size.height)];
        [handNext setAnchorPoint:ccp(0, 1)];
        
        [self addChild:handNext z:3 tag:kHandNext];
        
        
        [[GameManager sharedGameManager] setTotalScore:scoreUp];
        
    }
    
    
    
}


-(void) update:(ccTime)delta
{
    
    GameCharacter* tempChar = (GameCharacter *)[spriteBatchNode getChildByTag:kBellTagValue];
    
    CCSprite* sprite = (CCSprite *)[self getChildByTag:kAnimationTouch];
    
    [tempChar updateStateWithDeltaTime:delta];
    
    if ([sprite numberOfRunningActions] == 0) {
        
        [sprite stopAllActions];
        [sprite removeFromParentAndCleanup:YES];
    }
    
    
    if (tempChar.characterState == kStateBellFinish)
    {
        
        [self unscheduleUpdate];
                
        CCLabelBMFont* label = [CCLabelBMFont labelWithString:@"Finish" fntFile:FONTLETTERS];
        
        [self addChild:label z:2];
        
        [label setPosition:ccp(240,160)];
        
        CCArray* arraytemp = [self children];
        
        for (CCSprite* temp in arraytemp) {
            
            if ([temp tag] == kAnimationTouch ) {
                
                [temp stopAllActions];
                [temp removeFromParentAndCleanup:YES];
            }
        }
                
        [self removeChildByTag:kLabelScoreTagValue cleanup:YES];
        
        CCLabelBMFont* labelFinal = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d",score] fntFile:FONTNUMBERS];
        
        [self addChild:labelFinal z:2 tag:102];
        
        [labelFinal setPosition:ccp(240, 220)];
        
        CCLabelBMFont * totalScoreLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d",totalScore] fntFile:FONTNUMBERS];
        
        [self addChild:totalScoreLabel z:2 tag:101];
        
        [totalScoreLabel setPosition:ccp(240, 190)];
        
        id delay = [CCDelayTime actionWithDuration:1];
        
        id callFunc = [CCCallBlock actionWithBlock:(^{[self schedule:@selector(updateScore:)];})];
        
        id block = [CCCallBlock actionWithBlock:(^{ self.isFinish = TRUE;})];
        
        [self runAction:[CCSequence actions:delay,callFunc,block, nil]];

    }
    
    if (indexSprite >= 6) {
        
        [tempChar changeState:[NSNumber numberWithInt:kStateBellGong]];

    }
    
}

-(void)createObjectOfType:(GameObjectType)objectType atLocation:(CGPoint)spawnLocation withZValue:(int)ZValue{
    
    if (objectType == kObjectTypeBell) {
        
        Bell* bell = [Bell spriteWithSpriteFrameName:@"gong0001.png"];
        
        [spriteBatchNode addChild:bell z:ZValue tag:kBellTagValue];
        
        [bell setPosition:spawnLocation];
    }
    
    if (objectType == kObjectTypeScoreLabel) {
        
        CCLabelBMFont* labelScore = [CCLabelBMFont labelWithString:@"0" fntFile:FONTNUMBERS];
        
        [self addChild:labelScore z:ZValue tag:kLabelScoreTagValue];
        
        [labelScore setPosition:spawnLocation];
    }
    
}




@end
