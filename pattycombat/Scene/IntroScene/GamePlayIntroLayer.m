//
//  GamePlayIntroLayer.m
//  PattyCombat
//
//  Created by Giuseppe Lapenta on 10/10/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import "GamePlayIntroLayer.h"

@interface GamePlayIntroLayer()   
    
@property(nonatomic, strong)CCSprite* leftHand;
@property(nonatomic, strong)CCSprite* rightHand;
@property(readwrite)int feedIndex;
@property(readwrite)int patternIndex;
@property(readwrite)BOOL isTouchInTime;
@property (readonly)BOOL isLastLevel;
@property (readwrite)int positionActorX;


-(void)startGamePlay;
-(void)feedPattern;
-(void)loadAnimation;
-(void)alignHandsWithPadding:(float)padding;
-(void)resetPatternWithNodeTouched:(CharacterStates)nodeTouched;
-(CharacterStates)detectNodeFromTouches:(NSArray*)touches;
-(CharacterStates)detectNodeFromTouch:(CGPoint)touch;
-(int)getPositionX;

@end

@implementation GamePlayIntroLayer

@synthesize patternArray;
@synthesize rightHand;
@synthesize leftHand;
@synthesize feedIndex;
@synthesize feedHand;
@synthesize patternIndex;
@synthesize animationHandLeftOk;
@synthesize animationHandRightOk;
@synthesize animationHandLeftErr;
@synthesize animationHandRightErr;
@synthesize isTouchInTime;
@synthesize isLastLevel;
@synthesize animationFeedLeft;
@synthesize animationFeedRight;
@synthesize positionActorX;

- (void)dealloc {
    
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    spriteBatchNode = nil;
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"IntroButtAndFeed.plist"];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), self);

}

#pragma mark -
#pragma mark Init Methods


- (id)init {
    
    self = [super init];
    if (self) {
        
        patternIndex = 0;
        feedIndex = 0;
        state = kStateNone;
        
        isLastLevel = [[GameManager sharedGameManager] isLastLevel];
        
        NSString* playerName = [[GameManager sharedGameManager] namePlayer];

        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];

        CCSprite* player = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@_intro_player.png",playerName]];
        
        [self addChild:player z:2 tag:13];
        
        int xPosition = [self getPositionX];
        
        player.position = ccp(xPosition, player.boundingBox.size.height + 20);
        
        player.anchorPoint = ccp(1, 1);
        
        player.opacity = 0;
        
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        
        NSLog(@"Inizializzazione Intro");
    }
    return self;
}

-(void)onEnterTransitionDidFinish{
    
    CCCallFunc * call = [CCCallFunc actionWithTarget:self selector:@selector(showActorAndName)];
    
    CCDelayTime* delay = [CCDelayTime actionWithDuration:0.5];
    
    [self runAction:[CCSequence actionOne:delay two:call]];
    
    [[GameManager sharedGameManager] playBackgroundTrack:BACKGROUND_TRACK_MAIN_MENU];
    
}


-(void)feedPattern{
    
    id gameManager = [GameManager sharedGameManager];
    
    float padding = 2;
    
    feedHand = [[NSMutableArray alloc] init];       
    
    patternArray = [[NSMutableArray alloc] initWithArray:[gameManager patternForLevel]];
    
    
    for (NSString* hand in patternArray) {
        
        CCSprite* handSprite = nil;
        CCSprite* twoHandSprite = nil;
        CCSprite* arrow = nil;
        
        if ([hand isEqualToString:@"dx"] || [hand isEqualToString:@"dxCross"]) {
            
            handSprite = [CCSprite spriteWithSpriteFrame: 
                          [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"intro_feed_dx_01.png"]];

        [handSprite setTag:kHandFeedRight];
            
        }else if([hand isEqualToString:@"sx"] || [hand isEqualToString:@"sxCross"]){
            
            handSprite = [CCSprite spriteWithSpriteFrame:
                          [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"intro_feed_sx_01.png"]];
            
            handSprite.flipX = YES;
            
            [handSprite setTag:kHandFeedLeft];
            
        }else if([hand isEqualToString:@"two"]){
            
            handSprite = [CCSprite spriteWithSpriteFrame: 
                                [[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"intro_feed_dx_01.png"]];
            twoHandSprite = [CCSprite spriteWithSpriteFrame: 
                             [[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"intro_feed_sx_01.png"]];
            
            twoHandSprite.flipX = YES;
            
            [handSprite setTag:kHandFeedRight];
            [twoHandSprite setTag:kHandFeedLeft];
            
        }else CCLOG(@"Pattern non riconosciuto");
        
        
        if (handSprite != nil && twoHandSprite != nil) {
            
            arrow = [CCSprite spriteWithSpriteFrame: 
                     [[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"intro_feed_arrow.png"]];
            
            [arrow setTag:kArrow];
            
            [feedHand addObject:handSprite];
            [feedHand addObject:twoHandSprite];
            [feedHand addObject:arrow];
            
        }else if (handSprite != nil) {
            arrow = [CCSprite spriteWithSpriteFrame: 
                     [[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"intro_feed_arrow.png"]];
            
            [arrow setTag:kArrow];
            
            [feedHand addObject:handSprite];
            [feedHand addObject:arrow];
        }
        
    } 
    [feedHand removeLastObject];
    [self alignHandsWithPadding:padding];
    
    
}

-(void)alignHandsWithPadding:(float)padding{
    
    CGSize size = [[CCDirector sharedDirector]winSize];
    
    float width = -padding;
    
    for (CCSprite* item in feedHand) {
        
        width += item.textureRect.size.width * item.scaleX +padding; 
        
    }
    
    
    float x = (size.width/2) - (width / 2.0f);
    
    
    for (CCSprite* item in feedHand) {
        
        [spriteBatchNode addChild:item];
        CGSize itemSize = item.textureRect.size;
        [item setPosition:ccp(x + itemSize.width * item.scaleX / 2.0f, size.height - itemSize.height * item.scaleY /2.0f)];
        x += itemSize.width * item.scaleX + padding;
    }
    
    
}

-(void)loadAnimation{
    
    [self setAnimationHandLeftOk:[CCAnimation animationWithSpriteFrames:
                                  [NSArray arrayWithObjects:
                                   [[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"intro_btn_sx_01.png"],
                                    [[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"intro_btn_sx_02.png"], nil]
                                    delay:0.08]];
    
    [self setAnimationHandRightOk:[CCAnimation animationWithSpriteFrames:
                                   [NSArray arrayWithObjects:
                                    [[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"intro_btn_dx_01.png"],
                                    [[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"intro_btn_dx_02.png"], nil]delay:0.08]];
    
    [self setAnimationHandLeftErr:[CCAnimation animationWithSpriteFrames:
                                   [NSArray arrayWithObjects:
                                    [[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"intro_btn_sx_01.png"],
                                    [[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"intro_btn_sx_03.png"], nil]delay:0.08]];
    
    [self setAnimationHandRightErr:[CCAnimation animationWithSpriteFrames:
                                    [NSArray arrayWithObjects:
                                     [[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"intro_btn_dx_01.png"],
                                     [[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"intro_btn_dx_03.png"], nil]delay:0.08]];
    [self setAnimationFeedLeft:[CCAnimation animationWithSpriteFrames:
                                [NSArray arrayWithObjects:
                                 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"intro_feed_sx_01.png"],
                                 [[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"intro_feed_sx_02.png"], nil] delay:0.08]];
    [self setAnimationFeedRight:[CCAnimation animationWithSpriteFrames:
                                [NSArray arrayWithObjects:
                                 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"intro_feed_dx_01.png"],
                                 [[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"intro_feed_dx_02.png"], nil] delay:0.08]];

}
#pragma mark -
#pragma mark Touch Methods

-(void) registerWithTouchDispatcher
{
    
    [[[CCDirector sharedDirector] touchDispatcher] addStandardDelegate:self priority:-1];

}



-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
            
    isTouchInTime = FALSE;
    
    int noTouchesInEvent = ((NSSet*)[event allTouches]).count;
    int noTouchesBegan = touches.count;
    UITouch* oldTouch = nil;
    UITouch* currentTouch = nil;
    
    CCLOG(@"began %i, total %i", noTouchesBegan, noTouchesInEvent);
        
    if((noTouchesBegan== 2) && (noTouchesInEvent==2)){
        
        NSArray *touchArray = [touches allObjects];
        
        NSMutableArray* userTouches = [NSMutableArray array];
        
        oldTouch = [touchArray objectAtIndex:0];
        currentTouch = [touchArray objectAtIndex:1];
        
        CGPoint firstLocation = [oldTouch locationInView:[oldTouch view]];
        CGPoint secondLocation = [currentTouch locationInView:[currentTouch view]];
        [[CCDirector sharedDirector]convertToGL:firstLocation];
        [[CCDirector sharedDirector]convertToGL:secondLocation];
        
        [userTouches addObject:[NSValue valueWithCGPoint:firstLocation]];
        [userTouches addObject:[NSValue valueWithCGPoint:secondLocation]];
        
        [self handleHitsWithTouches:userTouches];

        state = kStateOneTouchWaiting;
        
    }
    
    else if((state!= kStateTwoHandsHit)&&((noTouchesBegan== 1)&&(noTouchesInEvent==1))){
        
        state = kStateTwoHandsHit; // S2 ho ricevuto il primo tocco e aspetto il secondo
        oldTouch = (UITouch*)[touches anyObject];
        firstTouchTimeStamp = oldTouch.timestamp;
        firstTouchLocInView = [oldTouch locationInView:[oldTouch view]];
        [[CCDirector sharedDirector]convertToGL:firstTouchLocInView];
        [self performSelector:@selector(verifiedTouchFromLocation:) withObject:[NSValue valueWithCGPoint:firstTouchLocInView] afterDelay:MAX_ELAPSED_TIME];
        return;
    }                                                                                                                                
    else if((state == kStateTwoHandsHit) && (noTouchesInEvent== 2) ){
                
        isTouchInTime = TRUE;

        UITouch *aTouch = (UITouch*)[touches anyObject];
        if((aTouch.timestamp - firstTouchTimeStamp) <= MAX_ELAPSED_TIME){
                        
            // S1 Ho ricevuto il secondo tocco entro la soglia MAX_ELAPSED_TIME
            
            NSMutableArray* userTouches = [[NSMutableArray alloc] init];
            
            CGPoint secondLocation = [aTouch locationInView:[aTouch view]];
            
            [[CCDirector sharedDirector]convertToGL:secondLocation];
            
            [userTouches addObject:[NSValue valueWithCGPoint:firstTouchLocInView]];
            [userTouches addObject:[NSValue valueWithCGPoint:secondLocation]];
            
            [self handleHitsWithTouches:userTouches];
            
            state = kStateOneTouchWaiting;
            
        }
        else {
            firstTouchTimeStamp = aTouch.timestamp;
            firstTouchLocInView = [aTouch locationInView:[aTouch view]];
        }
    }
    else {
        
        state = kStateOneTouchWaiting;
        oldTouch = (UITouch*)[touches anyObject];
        firstTouchTimeStamp = oldTouch.timestamp;
        firstTouchLocInView = [oldTouch locationInView:[oldTouch view]];
        [[CCDirector sharedDirector]convertToGL:firstTouchLocInView];
        [self handleHitWithTouch:firstTouchLocInView];
    }
        
}

#pragma mark -
#pragma mark Handle Hit

-(void)handleHitWithTouch:(CGPoint)location 
{
    
    NSLog(@"%@", NSStringFromSelector(_cmd));

    NSString * patternDescription = nil;
            
    if(patternIndex < [patternArray count]) patternDescription = [patternArray objectAtIndex:patternIndex];    
        
    CharacterStates nodeHit = [self detectNodeFromTouch:location];
    
    if (nodeHit == kStateLeftHandHit && patternDescription != nil){
        
        if (([patternDescription isEqualToString:@"sx"] || [patternDescription isEqualToString:@"sxCross"]) && [leftHand numberOfRunningActions] == 0)
        {
         
        patternIndex++;
        [leftHand stopAllActions];
        [leftHand runAction:
         [CCAnimate actionWithAnimation:animationHandLeftOk]];
        
            
            [[feedHand objectAtIndex:feedIndex]
             setDisplayFrame:[[animationFeedLeft frames] objectAtIndex:1]];
            
        feedIndex += 2;

                    
        }else [self resetPatternWithNodeTouched:nodeHit];
        
    }else if(nodeHit == kStateRightHandHit && patternDescription != nil){
        
        if(([patternDescription isEqualToString:@"dx"] || [patternDescription isEqualToString:@"dxCross"]) && [rightHand numberOfRunningActions] == 0){
            
        patternIndex++;
        [rightHand stopAllActions];
        [rightHand runAction:
         [CCAnimate actionWithAnimation:animationHandRightOk]];
                 
            [[feedHand objectAtIndex:feedIndex] 
             setDisplayFrame:[[animationFeedRight frames] objectAtIndex:1]];

            feedIndex += 2;

                
        }else [self resetPatternWithNodeTouched:nodeHit];
    
    }
    
    [self performSelector:@selector(startGamePlay) withObject:nil afterDelay:MAX_ELAPSED_TIME];

    
}

-(void)handleHitsWithTouches:(NSArray*)touches
{
    
    NSLog(@"%@", NSStringFromSelector(_cmd));

    NSString* patternDescription = [patternArray objectAtIndex:patternIndex];    

    if ([patternDescription isEqualToString:@"end"]) return;
        
    if ([touches count] == 2) {
        
    CharacterStates nodesTouched = [self detectNodeFromTouches:touches];
    
    CCLOG(@"Nodo toccato:%i", nodesTouched);
        
    if(nodesTouched == kStateTwoHandsHit ){
        
        if([patternDescription isEqualToString:@"two"] && [leftHand numberOfRunningActions] == 0 && [rightHand numberOfRunningActions] == 0){

            [[feedHand objectAtIndex:feedIndex] 
             setDisplayFrame:[[animationFeedLeft frames] objectAtIndex:1]];

            
            feedIndex++;
            
            
            [[feedHand objectAtIndex:feedIndex]        
             setDisplayFrame:[[animationFeedRight frames] objectAtIndex:1]];

            
            feedIndex += 2;
            
            [leftHand stopAllActions];
            [leftHand runAction:
              [CCAnimate actionWithAnimation:animationHandLeftOk]];
            
            [rightHand stopAllActions];
            [rightHand runAction:
             [CCAnimate actionWithAnimation:animationHandRightOk]];
                
            
            patternIndex++;

            [self performSelector:@selector(startGamePlay) withObject:nil afterDelay:MAX_ELAPSED_TIME];
            
        
        
            }else [self resetPatternWithNodeTouched:nodesTouched];
    
        }
    }

}

-(void)resetPatternWithNodeTouched:(CharacterStates)nodeTouched
{
    
    isTouchInTime = FALSE;
            
    CCLOG(@"%@ %@", NSStringFromSelector(_cmd), self);
        
        feedIndex = 0;
        patternIndex = 0;
        
        if (nodeTouched == kStateTwoHandsHit) {
            
            [leftHand runAction:[CCAnimate actionWithAnimation:animationHandLeftErr]];
            
            [rightHand runAction:[CCAnimate actionWithAnimation:animationHandRightErr]];
        }
        
        else if (nodeTouched == kStateLeftHandHit) {
            
            [leftHand runAction:[CCAnimate actionWithAnimation:animationHandLeftErr]];
            
        }else if(nodeTouched == kStateRightHandHit)
        {
            [rightHand runAction:[CCAnimate actionWithAnimation:animationHandRightErr]];
        }

    
    for (CCSprite* pat in feedHand) {
        
        if (pat.tag == kHandFeedLeft) {
            
            [pat setDisplayFrame:[[animationFeedLeft frames] objectAtIndex:0]];
            
        }else if(pat.tag == kHandFeedRight){
            
            [pat setDisplayFrame:[[animationFeedRight frames]objectAtIndex:0]];
            
            }
        
        
        }
    }
    


#pragma mark -
#pragma mark - Start Game Method

-(void)startGamePlay {
    
            
    if (patternIndex == [patternArray count] || isLastLevel) {
        
        CCLOG(@"Intro complete, asking Game Manager to start the Game play");
        
        [[GameManager sharedGameManager] runSceneWithID:kGamelevel1];
        
        self.isTouchEnabled = FALSE;
        
        patternIndex++;
    }
    
}

-(void)verifiedTouchFromLocation:(NSValue*)location{
        
    if (!isTouchInTime && patternIndex <= [patternArray count]) {
                
        [self handleHitWithTouch:firstTouchLocInView];
        
        state = kStateOneTouchWaiting;
    }
    
    if (isLastLevel) {
        
        [self startGamePlay];
    }
}

-(CharacterStates)detectNodeFromTouches:(NSArray*)touches{
    
    CharacterStates nodeHits = kStateNone;

    if ([touches count] == 2) {

    CCLOG(@"%@ %@", NSStringFromSelector(_cmd), self);
        
    CGPoint firstLocation = [[touches objectAtIndex:0] CGPointValue];
    CGPoint secondLocation = [[touches objectAtIndex:1] CGPointValue];
    
    if((CGRectContainsPoint([rightHand boundingBox], firstLocation) && 
        CGRectContainsPoint([leftHand boundingBox], secondLocation)) || 
       ((CGRectContainsPoint([rightHand boundingBox], secondLocation) && 
         CGRectContainsPoint([leftHand boundingBox], firstLocation))))
        
    nodeHits =  kStateTwoHandsHit;
    

    else if (CGRectContainsPoint([rightHand boundingBox], firstLocation) || CGRectContainsPoint([rightHand boundingBox], secondLocation))nodeHits = kStateRightHandHit;
        
    else if (CGRectContainsPoint([leftHand boundingBox], firstLocation)|| CGRectContainsPoint([leftHand boundingBox], secondLocation))nodeHits =  kStateLeftHandHit;
        
    else nodeHits = kStateHitBackground;
    }

    
    return nodeHits;
}

-(CharacterStates)detectNodeFromTouch:(CGPoint)touch{
    
    CCLOG(@"%@ %@", NSStringFromCGPoint(touch), self);

    CharacterStates nodeHit;
    
    if (CGRectContainsPoint([rightHand boundingBox], touch))nodeHit = kStateRightHandHit;
    
    else if (CGRectContainsPoint([leftHand boundingBox], touch))nodeHit =  kStateLeftHandHit;
    
    else nodeHit = kStateHitBackground;
    
    return nodeHit;

}

-(void)showActorAndName{
    
    
    CCSprite* player = (CCSprite *)[self getChildByTag:13];
    
    CCFadeIn* fade = [CCFadeIn actionWithDuration:0.2];
        
    [player runAction:fade];
       
    [self scheduleUpdate];
}

-(void) update:(ccTime)delta
{
    CCSprite* player = (CCSprite *)[self getChildByTag:13];
    
    if ([player numberOfRunningActions] == 0) {
        
        [self unscheduleUpdate];
        [self showButtonAndFeed];
    }
}


-(void)showButtonAndFeed{
    
    CGSize winSize = [[CCDirector sharedDirector]winSize];
    
    if (!isLastLevel) {
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:
         [NSString stringWithString:@"IntroButtAndFeed.plist"]];
        
        spriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:
                           [NSString stringWithFormat:@"IntroButtAndFeed.png"]];
        
        [self addChild:spriteBatchNode z:0 tag:100];

        
        [self feedPattern];
        
        [self loadAnimation];
        
        rightHand = [CCSprite spriteWithSpriteFrameName:
                     [NSString stringWithString:@"intro_btn_dx_01.png"]];
        
        [spriteBatchNode addChild:rightHand z:1000];
        
        [rightHand setPosition:ccp(winSize.width/2 - 150, winSize.height/2)];
        
        leftHand = [CCSprite spriteWithSpriteFrameName:
                    [NSString stringWithString:@"intro_btn_sx_01.png"]];
        
        [spriteBatchNode addChild:leftHand z:1000];
        
        [leftHand setPosition:ccp(winSize.width/2 + 150, winSize.height/2)];
        
    }
    else{
        
        CCLabelTTF* label = [CCLabelTTF labelWithString:@"????" fontName:@"Marker Felt" fontSize:20];
        
        [self addChild:label];
        
        [label setPosition:ccp(winSize.width/2, winSize.height - label.boundingBox.size.height + 10)];
        
    }
    
    self.isTouchEnabled = TRUE;
    
    
}


-(int)getPositionX{
    
    int x = 0;
    
    int currentLevel = [[GameManager sharedGameManager] currentLevel];
    
    switch (currentLevel) {
            
        case 1:
            x = 330;
            break;
        case 2:
            x = 316;
            break;
        case 3:
            x = 328;
            break;
        case 5:
            x= 286;
            break;
        case 6:
            x = 304;
            break;
        case 7:
            x = 302;
            break;
        case 8:
            x = 336;
            break;
        case 10:
            x = 188;
            break;
        case 11:
            x= 238;
            break;
        case 12:
            x= 320;
            break;
        default:
            break;
    }
    
    
    return x;
}



@end
