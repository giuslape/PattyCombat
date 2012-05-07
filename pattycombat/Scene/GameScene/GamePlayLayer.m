//
//  GamePlayLayer.m
//  PattyCakeFighter
//
//  Created by Giuseppe Lapenta on 08/09/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import "GamePlayLayer.h"
#import "SceneDaoPlist.h"
#import "Bell.h"
#import "GPBar.h"
#import "GameManager.h"

@interface GamePlayLayer ()

@property (assign)CharacterStates state;
@property (readwrite) NSTimeInterval firstTouchTimeStamp;
@property (readwrite) CGPoint firstTouchLocInView;
@property (nonatomic, strong)CCLabelBMFont* labelScore;
@property (nonatomic, strong)NSString * backgroundTrack;
@property (nonatomic, strong)NSString* namePlayer;

-(void)verifiedTouchFromLocation:(NSValue*)location;
@end

@implementation GamePlayLayer

@synthesize state;
@synthesize firstTouchTimeStamp;
@synthesize firstTouchLocInView;
@synthesize labelScore;
@synthesize backgroundTrack;
@synthesize namePlayer;
@synthesize player = _player;
@synthesize hudLayer = _hudLayer;



#pragma mark -
#pragma mark ===  Dealloc  ===
#pragma mark -

- (void)dealloc {
    
    NSLog(@"%@ , %@",NSStringFromSelector(_cmd), self);
    
    self.player = nil;
    self.hudLayer = nil;
    
    [self unscheduleAllSelectors];
    [[[CCDirectorIOS sharedDirector] touchDispatcher] removeDelegate:self];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];

}


#pragma mark -
#pragma mark ===  Protocol Methods  ===
#pragma mark -


-(void)didPlayerChangeHands:(BOOL)touchOk{
    
    CCSprite* leftHand = (CCSprite *)[self getChildByTag:kLeftHandHelpTagValue];
    CCSprite* rightHand = (CCSprite *)[self getChildByTag:kRightHandHelpTagValue];

    if (leftHand.opacity == 100)leftHand.opacity = 0;
    if (rightHand.opacity == 100)rightHand.opacity = 0;
        
    [_hudLayer updateHealthBar:touchOk];
    
    if (!touchOk && [[GameManager sharedGameManager] isPerfectForLevel]) {
        
        [[GameManager sharedGameManager] setIsPerfectForLevel:NO];
    }
    
}

-(void)didPlayerHasTouched:(BOOL)handsIsTouched{
    
    [_hudLayer updateHealthBar:handsIsTouched];
    
}

-(void)didPlayerOpenHand:(CharacterStates)states{
    
    CCSprite* leftHand = (CCSprite *)[self getChildByTag:kLeftHandHelpTagValue];
    CCSprite* rightHand = (CCSprite *)[self getChildByTag:kRightHandHelpTagValue];
    
    switch (states) {
        case kStateLeftHandOpen:
            
            leftHand.opacity = 100;
            
            break;
        case kStateRightHandOpen:
            rightHand.opacity = 100;
            
        default:
            break;
    }
    
}

// Handle Game Over 

-(void)gameOverHandler:(CharacterStates)gameOverState withScore:(NSNumber *)score{
    
    self.isTouchEnabled = FALSE;

    CGSize size = [[CCDirectorIOS sharedDirector] winSize];
    
    [self unscheduleAllSelectors];
    
    [[GameManager sharedGameManager]  stopBackgroundMusic];
    [[GameManager sharedGameManager]  setCurrentScore:[score intValue]];
    [[GameManager sharedGameManager]  setElapsedTime:_elapsedTime];
    
    // Add Finish Label
    
    CCLabelBMFont* finishLabel = [CCLabelBMFont labelWithString:@"Finish" fntFile:FONTHIGHSCORES];
    
    [self addChild:finishLabel z:3];
    
    finishLabel.position = ccp(size.width/2,size.height/2);
    
    // Run Complete Scene
    [[GameManager sharedGameManager] runSceneWithID:kLevelCompleteScene];
  
}

-(void)pauseDidEnter:(HUDLayer *)layer{
    
    [self pauseSchedulerAndActions];
    
}

-(void)pauseDidExit:(HUDLayer *)layer{
    
    [self resumeSchedulerAndActions];
}



#pragma mark -
#pragma mark ===  Touch Handler  ===
#pragma mark -

-(void) registerWithTouchDispatcher
{
       
    [[[CCDirectorIOS sharedDirector] touchDispatcher] addStandardDelegate:self priority:0];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
         
    PLAYSOUNDEFFECT(PERFECT_TAP);
    GameCharacter* tempChar = (GameCharacter*)[self getChildByTag:kPlayerTagValue];
    int noTouchesInEvent = ((NSSet*)[event allTouches]).count;
    int noTouchesBegan = touches.count;
    UITouch* oldTouch = nil;
    UITouch* currentTouch = nil;
    
    CCLOG(@" TouchBegan: %d, TouchEvent: %d",noTouchesBegan,noTouchesInEvent);
    
    if((noTouchesBegan== 2) && (noTouchesInEvent==2)){
        
        NSArray *touchArray = [touches allObjects];
        
        NSMutableArray* userTouches = [NSMutableArray array];
        
        oldTouch = [touchArray objectAtIndex:0];
        currentTouch = [touchArray objectAtIndex:1];
        
        CGPoint firstLocation = [oldTouch locationInView:[oldTouch view]];
        CGPoint secondLocation = [currentTouch locationInView:[currentTouch view]];
        
        [[CCDirectorIOS sharedDirector]convertToGL:firstLocation];
        [[CCDirectorIOS sharedDirector]convertToGL:secondLocation];
        
        [userTouches addObject:[NSValue valueWithCGPoint:firstLocation]];
        [userTouches addObject:[NSValue valueWithCGPoint:secondLocation]];
        
        [tempChar handleHitsWithTouches:userTouches];
        
        state = kStateOneTouchWaiting;
                
    }
    
    else if((state!= kStateTwoHandsHit)&&((noTouchesBegan == 1)&&(noTouchesInEvent == 1))){
        
        _isTouchInTime = FALSE;
        
        state = kStateTwoHandsHit; // S2 ho ricevuto il primo tocco e aspetto il secondo
        oldTouch = (UITouch *)[touches anyObject];
        firstTouchTimeStamp = oldTouch.timestamp;
        firstTouchLocInView = [oldTouch locationInView:[oldTouch view]];
        
        [[CCDirectorIOS sharedDirector]convertToGL:firstTouchLocInView];

        NSLog(@"Touch in: %@", NSStringFromCGPoint(firstTouchLocInView));
        
        [self performSelector:@selector(verifiedTouchFromLocation:) withObject:[NSValue valueWithCGPoint:firstTouchLocInView] afterDelay:MAX_ELAPSED_TIME];
        return;
        
    }                                                                                                                                
    else if((state == kStateTwoHandsHit) && (noTouchesInEvent== 2) ){
        
        _isTouchInTime = TRUE;
        
        UITouch *aTouch = (UITouch*)[touches anyObject];
            
            // S1 Ho ricevuto il secondo tocco entro la soglia MAX_ELAPSED_TIME
            
            NSMutableArray* userTouches = [NSMutableArray array];
            
            CGPoint secondLocation = [aTouch locationInView:[aTouch view]];
            
            [[CCDirectorIOS sharedDirector]convertToGL:secondLocation];
            
            [userTouches addObject:[NSValue valueWithCGPoint:firstTouchLocInView]];
            [userTouches addObject:[NSValue valueWithCGPoint:secondLocation]];
            
            [tempChar handleHitsWithTouches:userTouches];
            
            state = kStateOneTouchWaiting;
                                   
    }
    else {
        state = kStateNone;
        [[CCDirectorIOS sharedDirector]convertToGL:firstTouchLocInView];
        state = kStateOneTouchWaiting;
        
    }
    
    
}

-(void)verifiedTouchFromLocation:(NSValue*)location{
        
    if (!_isTouchInTime){
        
        CGPoint loc = [location CGPointValue];
        
        GameCharacter* player = (GameCharacter*)[self getChildByTag:kPlayerTagValue];
        
        [player handleHit:loc];
        
        state = kStateOneTouchWaiting;
            
    }
    
}


#pragma mark -
#pragma mark ===  Init Methods  ===
#pragma mark -


- (id)init {
    
    self = [super init];
    
    if (self) {
        
        _currentTime = 0;
        _count = 1;
        _elapsedTime = 0;
        
        _gameTimeInit = [[GameManager sharedGameManager] gameTimeInit];
        
        id dao = [GameManager sharedGameManager].dao;
        
        CGSize size = [[CCDirectorIOS sharedDirector] winSize];

        // Load Scene
        
        NSDictionary* sceneObjects = [dao loadScene:[[GameManager sharedGameManager] currentLevel]];
        
        // Set Background Track
        
        backgroundTrack = [[NSString alloc] initWithString:[sceneObjects objectForKey:@"backgroundTrack"]];
        
        namePlayer = [[GameManager sharedGameManager] formatPlayerNameTypeToString];
        
        // Add Player
        
        NSDictionary* playerSettings = [sceneObjects objectForKey:@"player"];
        
        _bpm = [[playerSettings objectForKey:@"bpm"] intValue];
                
        _player = [Player playerWithDictionary:playerSettings];
        
        [self addChild:_player z:kPlayerZValue tag:kPlayerTagValue];
        
        [_player setDelegate:self];

        CCLabelBMFont* label = [CCLabelBMFont labelWithString:@"Get the Rhythm" fntFile:FONTHIGHSCORES];
        [self addChild:label z:kLabelReadyZValue tag:kLabelReadyTagValue];
        [label setPosition:ccp(size.width/2, size.height/2)];
        
        // Check if Tutorial is active
        
        BOOL isTutorial = [[GameManager sharedGameManager] isTutorial];
        
        if(isTutorial){
            
            CCSprite* leftHand = [CCSprite spriteWithFile:@"intro_btn_sx_02.png"];
            
            [self addChild:leftHand z:kLeftHandHelpZValue tag:kLeftHandHelpTagValue];
            
            [leftHand setPosition:ccp(size.width * 0.76f, size.height * 0.40f)];
            
            leftHand.opacity = 0;
            
            CCSprite* rightHand = [CCSprite spriteWithFile:@"intro_btn_dx_02.png"];
            
            [self addChild:rightHand z:kRightHandHelpZValue tag:kRightHandHelpTagValue];
            
            [rightHand setPosition:ccp(size.width * 0.24f, size.height * 0.40f)];
            
            rightHand.opacity = 0;
            
        }
           
        [self scheduleOnce:@selector(playSound) delay:1.0f];

    }
    return self;
}


    

-(void)playSound{
    
    [[GameManager sharedGameManager] playBackgroundTrack:backgroundTrack];
    [self schedule:@selector(countDown:) interval:0.01];
}
    


// Count Down

-(void)countDown:(ccTime)delta{
    
    _currentTime += delta;
        
    if ((_count * (60.0 / _bpm)) <= _currentTime) {
        
    int count = _count;
    _count++;

    CCLabelBMFont* label = (CCLabelBMFont*)[self getChildByTag:kLabelReadyTagValue];
   
    if (count == _gameTimeInit + 3) {
            
            //  id delay  = [CCDelayTime actionWithDuration:0.5f];
            [self unschedule:_cmd];
        
           // id func   = [CCCallFunc actionWithTarget:self selector:@selector(scheduleUpdate)];
        
            id change = [CCCallBlock actionWithBlock:^{
                 [label setString:@"4"];
             }];
            
            id d2 = [CCDelayTime actionWithDuration:(60.0f/ _bpm)];
            id delete = [CCCallBlock actionWithBlock:^{
                
                [self removeChild:label cleanup:YES];
                
            }];
            
            [self runAction:[CCSequence actions:change,d2,delete, nil]];
            [self schedule:@selector(update:) interval:0 repeat:kCCRepeatForever delay:0.00001f];
            self.isTouchEnabled = TRUE;
            return;
            
        }

     if(count >= _gameTimeInit){
         
         int tempCount = _gameTimeInit - 1;
         NSString *tempString = [NSString stringWithFormat:@"%d", count - tempCount];
         [label setString:tempString];
        
        }
    
    }
}

#pragma mark -
#pragma mark ===  Update Methods  ===
#pragma mark -


-(void) update:(ccTime)deltaTime
{
    _elapsedTime += deltaTime;
    
    [_player updateStateWithDeltaTime:deltaTime];
    [_hudLayer updateStateWithDelta:deltaTime];
    
}


@end
