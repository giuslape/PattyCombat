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
@property (nonatomic, strong)CCLabelBMFont* labelScore;
@property (readwrite) NSTimeInterval firstTouchTimeStamp;
@property (readwrite) CGPoint firstTouchLocInView;
@property (readwrite) BOOL isTouchInTime;
@property (readwrite) int countDown;
@property (nonatomic, strong)NSString * backgroundTrack;
@property int count;
@property (readonly)int bpm;
@property double currentTime;
@property (nonatomic, strong)NSString* namePlayer;

-(void)verifiedTouchFromLocation:(NSValue*)location;
@end

@implementation GamePlayLayer

@synthesize state;
@synthesize firstTouchTimeStamp;
@synthesize firstTouchLocInView;
@synthesize isTouchInTime;
@synthesize countDown;
@synthesize labelScore;
@synthesize count;
@synthesize currentTime;
@synthesize bpm;
@synthesize backgroundTrack;
@synthesize namePlayer;
@synthesize player = _player;
@synthesize hudLayer = _hudLayer;

#pragma mark -
#pragma mark Update Methods

-(void) update:(ccTime)deltaTime
{

    [_player updateStateWithDeltaTime:deltaTime];
    [_hudLayer updateStateWithDelta:deltaTime];
    
}

#pragma mark -

- (void)dealloc {
    
    NSLog(@"%@ , %@",NSStringFromSelector(_cmd), self);
   
    [[[CCDirectorIOS sharedDirector] touchDispatcher] removeDelegate:self];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"Common.png"];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    
}


#pragma mark -
#pragma mark ===  Protocol Methods  ===
#pragma mark -


-(void)didPlayerChangeHands:(BOOL)handIsOpen{
    
    [_hudLayer updateHealthBar:handIsOpen];
    
}

-(void)didPlayerHasTouched:(BOOL)handsIsTouched{
    
    [_hudLayer updateHealthBar:handsIsTouched];
    
}


-(void)gameOverHandler:(CharacterStates)gameOverState withScore:(NSNumber *)score andPlayerIsDead:(BOOL)playerIsDead fromLayer:(id)layer{
    

    NSLog(@"%@", NSStringFromSelector(_cmd));

    CGSize size = [[CCDirectorIOS sharedDirector] winSize];
    
    [self unscheduleAllSelectors];
    
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[GameManager sharedGameManager] setHasPlayerDied:playerIsDead];
    [[GameManager sharedGameManager] setCurrentScore:[score intValue]];

    
    self.isTouchEnabled = FALSE;
    
    CCLabelBMFont* finishLabel = [CCLabelBMFont labelWithString:@"Finish" fntFile:FONTLETTERS];
    
    [self addChild:finishLabel z:100];
    
    finishLabel.position = ccp(size.width/2,size.height/2);
    
    
    self.player = nil;
    self.hudLayer = nil;
    
    [[GameManager sharedGameManager] runSceneWithID:kLevelCompleteScene];
  
}

#pragma mark Init Methods


    
- (id)init {
    
    self = [super init];
    
    if (self) {
                                    
        self.countDown = 15;
        currentTime = 0;
        count = 1;
                
        id dao = [GameManager sharedGameManager].dao;
        
        NSDictionary* sceneObjects = [dao loadScene:[[GameManager sharedGameManager] currentLevel]];
        
        backgroundTrack = [[NSString alloc] initWithString:[sceneObjects objectForKey:@"backgroundTrack"]];
                
        namePlayer = [sceneObjects objectForKey:@"name"];
        
        NSDictionary* playerSettings = [sceneObjects objectForKey:@"player"];
                
        bpm = [[playerSettings objectForKey:@"bpm"] intValue];

        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];

        _player = [Player playerWithDictionary:playerSettings];
        
        [self addChild:_player z:kPlayerZValue tag:kPlayerTagValue];
                
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

        [_player setDelegate:self];
                
        CGSize winSize = [[CCDirectorIOS sharedDirector]winSize];
                                                              
        CCLabelBMFont* label = [CCLabelBMFont labelWithString:@"Ready" fntFile:FONTLETTERS];
        [self addChild:label z:10 tag:300];
        [label setPosition:ccp(winSize.width/2, winSize.height/2)];
        
        
    }
    return self;
}


#pragma mark Touch Delegate

-(void) registerWithTouchDispatcher
{
       
    [[[CCDirectorIOS sharedDirector] touchDispatcher]addStandardDelegate:self priority:-1];
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
        
        isTouchInTime = FALSE;
        
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
        
        isTouchInTime = TRUE;
        
        UITouch *aTouch = (UITouch*)[touches anyObject];
        if((aTouch.timestamp - firstTouchTimeStamp) <= MAX_ELAPSED_TIME){
            
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
            firstTouchTimeStamp = aTouch.timestamp;
            firstTouchLocInView = [aTouch locationInView:[aTouch view]];
            [tempChar handleHit:firstTouchLocInView];
            state = kStateOneTouchWaiting;
        }
    }
    else {
        state = kStateNone;
        [[CCDirectorIOS sharedDirector]convertToGL:firstTouchLocInView];
        [tempChar handleHit:firstTouchLocInView];
        state = kStateOneTouchWaiting;
        
    }
    
    
}

-(void)verifiedTouchFromLocation:(NSValue*)location{
        
    if (!isTouchInTime){
        
        CGPoint loc = [location CGPointValue];
        
        loc= [[CCDirectorIOS sharedDirector] convertToGL:loc];
        
        if (CGRectContainsPoint([_hudLayer.pauseButton boundingBox], loc)) {
            
            [_hudLayer onPause:self];
            
            return;
        }
        
        loc = [[CCDirectorIOS sharedDirector] convertToGL:loc];
        
        GameCharacter* tempChar = (GameCharacter*)[self getChildByTag:kPlayerTagValue];
        
        [tempChar handleHit:loc];
        
        state = kStateOneTouchWaiting;
            
    }
    
}

-(void)onEnterTransitionDidFinish{
    
    
    [[GameManager sharedGameManager] playBackgroundTrack:backgroundTrack];
    [self schedule:@selector(countDown:) interval:0.01];

}

-(void)countDown:(ccTime)delta{
    
    currentTime += delta;
    
    if ((count * (60.0 / bpm)) <= currentTime) {
        
    count++;
        
    self.countDown --;
    
    CCLabelBMFont* label = (CCLabelBMFont*)[self getChildByTag:300];
   
     if(self.countDown <= 3){
         
         NSString *tempString = [NSString stringWithFormat:@"%d", self.countDown];
         [label setString:tempString];
        
    }
    
    if (self.countDown == 0) {
        
        [self removeChild:label cleanup:YES];
        
        PLAYSOUNDEFFECT(BELL);
        [self unschedule:_cmd];
        id delay = [CCDelayTime actionWithDuration:0.2f];
        id func = [CCCallFunc actionWithTarget:self selector:@selector(scheduleUpdate)];
        [self runAction:[CCSequence actionOne:delay two:func]];
        self.isTouchEnabled = TRUE;
        
        }
    }
}



@end
