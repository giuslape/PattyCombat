//
//  GamePlayIntroLayer.m
//  PattyCombat
//
//  Created by Giuseppe Lapenta on 10/10/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import "GamePlayIntroLayer.h"

@interface GamePlayIntroLayer()   

-(void)startGamePlay;
-(void)feedPattern;
-(void)loadAnimation;
-(void)alignHandsWithPadding:(float)padding;
-(void)resetPatternWithNodeTouched:(CharacterStates)nodeTouched;
-(CharacterStates)detectNodeFromTouches:(NSArray*)touches;
-(CharacterStates)detectNodeFromTouch:(CGPoint)touch;

@end

@implementation GamePlayIntroLayer

@synthesize patternArray;
@synthesize feedHand;
@synthesize animationHandLeftOk;
@synthesize animationHandRightOk;
@synthesize animationHandLeftErr;
@synthesize animationHandRightErr;
@synthesize animationFeedLeft;
@synthesize animationFeedRight;
@synthesize animationFeedBoth;



#pragma mark -
#pragma mark ===  Dealloc  ===
#pragma mark -

- (void)dealloc {
    
    _spriteBatchNode = nil;
    [[[CCDirectorIOS sharedDirector] touchDispatcher] removeAllDelegates];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"IntroButtAndFeed.plist"];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];    
        
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), self);

}

#pragma mark -
#pragma mark Init Methods


- (id)init {
    
    self = [super init];
    
    if (self) {
        
        _patternIndex = -1;
        _feedIndex = 0;
        _state = kStateNone;
        _isLastLevel = [[GameManager sharedGameManager] isLastLevel];
        
        [[CCDirectorIOS sharedDirector].view setMultipleTouchEnabled:YES];
                
        CCLayerColor* layer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 0)];
                
        [self addChild:layer z:kDarkValueIntroZValue tag:kDarkLayerIntroTagValue];
                
        NSLog(@"Inizializzazione Intro");
    }
    return self;
}

-(void)onEnterTransitionDidFinish{
        
    [self scheduleOnce:@selector(showButtonAndFeed) delay:0.5f];
    
    [[GameManager sharedGameManager] playBackgroundTrack:WAITINGTHEME];
    
}


-(void)feedPattern{
    
    id gameManager = [GameManager sharedGameManager];
    
    float padding = 4;
    
    feedHand = [[NSMutableArray alloc] init];       
    
    
    //Load Pattern for current Level
    
    patternArray = [[NSMutableArray alloc] initWithArray:[gameManager patternForLevel]];
    
    // Insert each item of PatternArray in feedHand array with check if is dx, sx or two
    
    for (NSString* hand in patternArray) {
        
        CCSprite* handSprite = nil;
        
        //TestFlight
        TFLog(hand);        
        
        if ([hand isEqualToString:@"dx"] || [hand isEqualToString:@"dxCross"]) {
            
            handSprite = [CCSprite spriteWithSpriteFrame: 
                          [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"intro_feed_dx_01.png"]];

        [handSprite setTag:kHandFeedRightTagValue];
            
        }else if([hand isEqualToString:@"sx"] || [hand isEqualToString:@"sxCross"]){
            
            handSprite = [CCSprite spriteWithSpriteFrame:
                          [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"intro_feed_sx_01.png"]];
            
            
            [handSprite setTag:kHandFeedLeftTagValue];
            
        }else if([hand isEqualToString:@"two"]){
            
            handSprite = [CCSprite spriteWithSpriteFrame: 
                                [[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"intro_feed_both_01.png"]];
                        
            
            [handSprite setTag:kHandFeedBothTagValue];
            
        }else CCLOG(@"Pattern non riconosciuto");
        
        
        if (handSprite != nil)[feedHand addObject:handSprite];
    }
            
    // Align elements of array feedhand
    
    [self alignHandsWithPadding:padding];
    
}

-(void)alignHandsWithPadding:(float)padding{
    
    CGSize size = [[CCDirectorIOS sharedDirector] winSize];
    
    float width = -padding;
    
    for (CCSprite* item in feedHand) {
        
        [item setScale:1.2f];

        width += item.textureRect.size.width * item.scaleX +padding; 
        
    }
    
    
    float x = (size.width/2) - (width / 2.0f);
    
    
    for (CCSprite* item in feedHand) {
        
        [_spriteBatchNode addChild:item];
        CGSize itemSize = item.textureRect.size;
        [item setPosition:ccp(x + itemSize.width * item.scaleX / 2.0f, size.height * 0.95f - itemSize.height * item.scaleY /2.0f)];
        x += itemSize.width * item.scaleX + padding;
    }
    
    
}

-(void)loadAnimation{
    
    [self setAnimationHandLeftOk:[CCAnimation animationWithSpriteFrames:
                                  [NSArray arrayWithObjects:
                                    [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"intro_btn_sx_02.png"],
                                    [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"intro_btn_sx_01.png"], nil]delay:0.08]];
    
    [self setAnimationHandRightOk:[CCAnimation animationWithSpriteFrames:
                                   [NSArray arrayWithObjects:
                                    [[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"intro_btn_dx_02.png"],
                                    [[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"intro_btn_dx_01.png"], nil] delay:0.08]];
    
    [self setAnimationHandLeftErr:[CCAnimation animationWithSpriteFrames:
                                   [NSArray arrayWithObjects:
                                    [[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"intro_btn_sx_03.png"],
                                    [[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"intro_btn_sx_01.png"], nil] delay:0.08]];
    
    [self setAnimationHandRightErr:[CCAnimation animationWithSpriteFrames:
                                    [NSArray arrayWithObjects:
                                     [[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"intro_btn_dx_03.png"],
                                     [[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"intro_btn_dx_01.png"], nil] delay:0.08]];
    [self setAnimationFeedLeft:[CCAnimation animationWithSpriteFrames:
                                [NSArray arrayWithObjects:
                                 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"intro_feed_sx_01.png"],
                                 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"intro_feed_sx_02.png"], nil] delay:0.08]];
    [self setAnimationFeedRight:[CCAnimation animationWithSpriteFrames:
                                [NSArray arrayWithObjects:
                                 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"intro_feed_dx_01.png"],
                                 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"intro_feed_dx_02.png"], nil] delay:0.08]];
    [self setAnimationFeedBoth:[CCAnimation animationWithSpriteFrames:
                                [NSArray arrayWithObjects:
                                 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"intro_feed_both_01.png"],
                                 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"intro_feed_both_02.png"],nil]delay:0.08]];

}
#pragma mark -
#pragma mark Touch Methods

-(void) registerWithTouchDispatcher
{
    
    [[[CCDirectorIOS sharedDirector] touchDispatcher] addStandardDelegate:self priority:-1];
    
}


-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
            
    _isTouchInTime = FALSE;
    
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
        [[CCDirectorIOS sharedDirector]convertToGL:firstLocation];
        [[CCDirectorIOS sharedDirector]convertToGL:secondLocation];
        
        [userTouches addObject:[NSValue valueWithCGPoint:firstLocation]];
        [userTouches addObject:[NSValue valueWithCGPoint:secondLocation]];
        
        [self handleHitsWithTouches:userTouches];

        _state = kStateOneTouchWaiting;
        
    }
    
    else if((_state!= kStateTwoHandsHit)&&((noTouchesBegan== 1)&&(noTouchesInEvent==1))){
        
        _state = kStateTwoHandsHit; // S2 ho ricevuto il primo tocco e aspetto il secondo
        oldTouch = (UITouch*)[touches anyObject];
        _firstTouchTimeStamp = oldTouch.timestamp;
        _firstTouchLocInView = [oldTouch locationInView:[oldTouch view]];
        [[CCDirectorIOS sharedDirector]convertToGL:_firstTouchLocInView];
        [self performSelector:@selector(verifiedTouchFromLocation:) withObject:[NSValue valueWithCGPoint:_firstTouchLocInView] afterDelay:MAX_ELAPSED_TIME];
        return;
    }                                                                                                                               
    else if((_state == kStateTwoHandsHit) && (noTouchesInEvent== 2) ){
                
        _isTouchInTime = TRUE;

        UITouch *aTouch = (UITouch*)[touches anyObject];
                        
            // S1 Ho ricevuto il secondo tocco entro la soglia MAX_ELAPSED_TIME
            
            NSMutableArray* userTouches = [[NSMutableArray alloc] init];
            
            CGPoint secondLocation = [aTouch locationInView:[aTouch view]];
            
            [[CCDirectorIOS sharedDirector]convertToGL:secondLocation];
            
            [userTouches addObject:[NSValue valueWithCGPoint:_firstTouchLocInView]];
            [userTouches addObject:[NSValue valueWithCGPoint:secondLocation]];
            
            [self handleHitsWithTouches:userTouches];
            
            _state = kStateOneTouchWaiting;
        
    }
    else {
        
        oldTouch = (UITouch*)[touches anyObject];
        _firstTouchTimeStamp = oldTouch.timestamp;
        _firstTouchLocInView = [oldTouch locationInView:[oldTouch view]];
        [[CCDirectorIOS sharedDirector]convertToGL:_firstTouchLocInView];
        //[self handleHitWithTouch:_firstTouchLocInView];
    }
        
}

#pragma mark -
#pragma mark ===  Handle Hits  ===
#pragma mark -


-(void)handleHitWithTouch:(CGPoint)location 
{
    _patternIndex++;
            
    if(_patternIndex >= [patternArray count]) return;
        
    NSString* patternDescription = [patternArray objectAtIndex:_patternIndex];    
        
    // Return the node hit
    
    CharacterStates nodeHit = [self detectNodeFromTouch:location];
    
        // Compare with current item of pattern
    
        if (nodeHit == kStateLeftHandHit &&
            ([patternDescription isEqualToString:@"sx"] ||
             [patternDescription isEqualToString:@"sxCross"]))
        {
                     
        [_leftHand stopAllActions];
        [_leftHand runAction:[CCAnimate actionWithAnimation:animationHandLeftOk]];
        
            CCSpriteFrame* frame = [[[animationFeedLeft frames] objectAtIndex:1] spriteFrame];

            [[feedHand objectAtIndex:_feedIndex] setDisplayFrame:frame];
            
            _feedIndex++;
            
        }else if(nodeHit == kStateRightHandHit && 
           ([patternDescription isEqualToString:@"dx"] ||
            [patternDescription isEqualToString:@"dxCross"])){
            
                [_rightHand stopAllActions];
                [_rightHand runAction:[CCAnimate actionWithAnimation:animationHandRightOk]];
                 
                CCSpriteFrame* frame = [[[animationFeedRight frames] objectAtIndex:1] spriteFrame];

                [[feedHand objectAtIndex:_feedIndex] setDisplayFrame:frame];

                _feedIndex++;
            
                } else [self resetPatternWithNodeTouched:nodeHit];
    
    if(_patternIndex == [patternArray count] - 1){
        
        CCSprite * fightButton = (CCSprite *)[_spriteBatchNode getChildByTag:kFightButtonTagValue];
        fightButton.opacity = 255;

    }

}


// Handle Touches

-(void)handleHitsWithTouches:(NSArray*)touches
{
    
    _patternIndex++;

    if(_patternIndex >= [patternArray count]) return;
    
    NSString* patternDescription = [patternArray objectAtIndex:_patternIndex];    
        
    if ([touches count] == 2) {
        
    CharacterStates nodesTouched = [self detectNodeFromTouches:touches];
                    
        if(nodesTouched == kStateTwoHandsHit &&
           [patternDescription isEqualToString:@"two"])
        {

            [[feedHand objectAtIndex:_feedIndex] 
             setDisplayFrame:[[[animationFeedBoth frames] objectAtIndex:1]spriteFrame]];
            
            _feedIndex++;

            [_leftHand stopAllActions];
            [_leftHand runAction:
              [CCAnimate actionWithAnimation:animationHandLeftOk]];
            
            [_rightHand stopAllActions];
            [_rightHand runAction:
             [CCAnimate actionWithAnimation:animationHandRightOk]];
                        
        }else [self resetPatternWithNodeTouched:nodesTouched];
        
        if(_patternIndex == [patternArray count] - 1) {
            
            CCSprite * fightButton = (CCSprite *)[_spriteBatchNode getChildByTag:kFightButtonTagValue];
            fightButton.opacity = 255;
        }

    }

}

// Reset feed pattern

-(void)resetPatternWithNodeTouched:(CharacterStates)nodeTouched
{
    
    _isTouchInTime = FALSE;

    _feedIndex = 0;
    _patternIndex = -1;
        
    if (nodeTouched == kStateTwoHandsHit) {
            
            [_leftHand runAction:[CCAnimate actionWithAnimation:animationHandLeftErr]];
            
            [_rightHand runAction:[CCAnimate actionWithAnimation:animationHandRightErr]];
        }
        
        else if (nodeTouched == kStateLeftHandHit) 
            
                [_leftHand runAction:[CCAnimate actionWithAnimation:animationHandLeftErr]];
            
                else if(nodeTouched == kStateRightHandHit)
        
                        [_rightHand runAction:[CCAnimate actionWithAnimation:animationHandRightErr]];
        

    
    for (CCSprite* pat in feedHand) {
        
        if (pat.tag == kHandFeedLeftTagValue) 
            
            [pat setDisplayFrame:[[[animationFeedLeft frames] objectAtIndex:0]spriteFrame]];
            
        else if(pat.tag == kHandFeedRightTagValue)
            
            [pat setDisplayFrame:[[[animationFeedRight frames]objectAtIndex:0]spriteFrame]];
        
        else if(pat.tag == kHandFeedBothTagValue)
        
            [pat setDisplayFrame:[[[animationFeedBoth frames] objectAtIndex:0] spriteFrame]];
        }
    
    //TestFlight
    TFLog(@"Tocco sbagliato Intro");
}
    


#pragma mark -
#pragma mark - Start Game Method

-(void)startGamePlay {
            
        CCLOG(@"Intro complete, asking Game Manager to start the Game play");
        
        [self unschedule:_cmd];
        [[GameManager sharedGameManager] runSceneWithID:kGamelevel1];
        
        self.isTouchEnabled = FALSE;
}

-(void)verifiedTouchFromLocation:(NSValue*)location{
    
    CGPoint pointLocation = [location CGPointValue];
    
    pointLocation = [[CCDirectorIOS sharedDirector] convertToGL:pointLocation];
    pointLocation = [self convertToNodeSpace:pointLocation];
    
    // Check is touch is on fight button
    
    CCSprite* fightButton = (CCSprite *)[_spriteBatchNode getChildByTag:kFightButtonTagValue];
    
    if (CGRectContainsPoint([fightButton boundingBox], pointLocation) && fightButton.opacity == 255) {
        
        self.isTouchEnabled = FALSE;
        
        // Remove Sprite unused
        
        CCSprite* arrowLeft = (CCSprite *)[self getChildByTag:kArrowLeftTutorialTagValue];
        CCSprite* arrowRight = (CCSprite *)[self getChildByTag:kArrowRightTutorialTagValue];
        CCLabelBMFont* labelTutorial = (CCLabelBMFont *)[self getChildByTag:kLabelTutorialTagValue];
        
        [arrowRight removeFromParentAndCleanup:YES];
        [arrowLeft removeFromParentAndCleanup:YES];
        [labelTutorial removeFromParentAndCleanup:YES];
        [fightButton removeFromParentAndCleanup:YES];
        [_leftHand removeFromParentAndCleanup:YES];
        [_rightHand removeFromParentAndCleanup:YES];
        
        // Add animation 
        
        CGSize size = [CCDirectorIOS sharedDirector].winSize;

        CCLabelBMFont* labelEnd = [CCLabelBMFont labelWithString:@"Don't forget the sequence" fntFile:FONTHIGHSCORES];
        
        [self addChild:labelEnd z:4];
        
        [labelEnd setPosition:ccp(size.width/2, size.height * 0.6)];
        
        CCLayerColor* darkLayer = (CCLayerColor *)[self getChildByTag:kDarkLayerIntroTagValue];
        
        [darkLayer runAction:[CCFadeIn actionWithDuration:0.5f]];
        
        for (CCSprite* item in feedHand) {
            
            CCMoveTo* move = [CCMoveTo actionWithDuration:0.5f position:ccp(item.position.x, size.height/2)];
            
            [item runAction:move];
        }
        
        [self scheduleOnce:@selector(startGamePlay) delay:2];
        
        return;
    }
    
    
    
    if (!_isTouchInTime) {
        
        [self handleHitWithTouch:pointLocation];
        
        _state = kStateOneTouchWaiting;
    }
    
    if (_isLastLevel) {
        
        [self startGamePlay];
    }
}


// Detect which hands are touched by 2 tap

-(CharacterStates)detectNodeFromTouches:(NSArray*)touches{
    
    CharacterStates nodeHits = kStateNone;

    if ([touches count] == 2) {

    CCLOG(@"%@ %@", NSStringFromSelector(_cmd), self);
        
    CGPoint firstLocation = [[touches objectAtIndex:0] CGPointValue];
    CGPoint secondLocation = [[touches objectAtIndex:1] CGPointValue];
    
    if((CGRectContainsPoint([_rightHand boundingBox], firstLocation) && 
        CGRectContainsPoint([_leftHand boundingBox], secondLocation)) || 
       ((CGRectContainsPoint([_rightHand boundingBox], secondLocation) && 
         CGRectContainsPoint([_leftHand boundingBox], firstLocation)))){
        
    nodeHits =  kStateTwoHandsHit;
        
        //TestFlight
        TFLog(@"Doppio Tocco Intro");
    
    }
    else if (CGRectContainsPoint([_rightHand boundingBox], firstLocation) ||
             CGRectContainsPoint([_rightHand boundingBox], secondLocation))
    {
                    nodeHits = kStateRightHandHit;
        //TestFlight
        TFLog(@"Tocco mano Destra Intro");
    }   
        else if (CGRectContainsPoint([_leftHand boundingBox], firstLocation)||
                 CGRectContainsPoint([_leftHand boundingBox], secondLocation)){
            nodeHits =  kStateLeftHandHit;
            //TestFlight
            TFLog(@"Tocco Sinistra Intro");
        }
        
        else {
            nodeHits = kStateHitBackground;
            //TestFlight
            TFLog(@"Tocco Background Intro");
        }
            
    }

    
    return nodeHits;
}


// Detect whic hand is touched by 1 tap

-(CharacterStates)detectNodeFromTouch:(CGPoint)touch{
    
    CCLOG(@"%@ %@", NSStringFromCGPoint(touch), self);

    CharacterStates nodeHit;
    
    if (CGRectContainsPoint([_rightHand boundingBox], touch)){
        
        nodeHit = kStateRightHandHit;
        
        //TestFlight
        TFLog(@"Tocco Destra");
    }
    
    else if (CGRectContainsPoint([_leftHand boundingBox], touch)){
        
        //TestFlight
        TFLog(@"Tocco Sinistra");
        
        nodeHit =  kStateLeftHandHit;
    
    }
    
    else {
        
        nodeHit = kStateHitBackground;
        //TestFlight
        TFLog(@"Tocco Background");
    }
    
    return nodeHit;

}

-(void)showButtonAndFeed{
    
    CGSize size = [[CCDirectorIOS sharedDirector] winSize];
    
    // Check if is last level
    
    if (!_isLastLevel) {
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"IntroButtAndFeed.plist" textureFilename:@"IntroButtAndFeed.png"];
        
        _spriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"IntroButtAndFeed.png"];
        
        [self addChild:_spriteBatchNode z:kSpriteBatchNodeIntroZValue tag:kSpriteBatchNodeIntroTagValue];
        
        //Load animation for Hands
        
        [self loadAnimation];
        
        // Set Pattern
        
        [self feedPattern];
        
        // Add Right Hand
        
        _rightHand = [CCSprite spriteWithSpriteFrameName:
                     [NSString stringWithString:@"intro_btn_dx_01.png"]];
        
        [_spriteBatchNode addChild:_rightHand z:kRightHandZValue tag:kRightHandTagValue];
        
        [_rightHand setPosition:ccp(size.width * 0.19f, size.height * 0.45f)];
        
        
        // Add Left Hand
        
        _leftHand = [CCSprite spriteWithSpriteFrameName:
                    [NSString stringWithString:@"intro_btn_sx_01.png"]];
        
        [_spriteBatchNode addChild:_leftHand z:kLeftHandZValue tag:kLeftHandTagValue];
        
        [_leftHand setPosition:ccp(size.width * 0.81f, size.height * 0.45f)];
        
        CCSprite* fightButton = [CCSprite spriteWithSpriteFrameName:@"fight_btn.png"];
        fightButton.opacity = 0;
        
        [_spriteBatchNode addChild:fightButton z:kFightButtonZValue tag:kFightButtonTagValue];
        
        [fightButton setPosition:ccp(size.width - fightButton.contentSize.width * 0.6f, 0)];
        
        [fightButton setAnchorPoint:ccp(0.5f, 0)];
        
        if ([[GameManager sharedGameManager] isTutorial]) {
            
            CCLabelBMFont* labelHelp = [CCLabelBMFont labelWithString:@"Follow the sequence above by tapping on the hands buttons" fntFile:FONTFEEDBACK];
            
            [self addChild:labelHelp z:kLabelTutorialZValue tag:kLabelTutorialTagValue];
            
            [labelHelp setPosition:ccp(size.width/2, size.height * 0.79f)];
            
            CCSprite* arrowLeft = [CCSprite spriteWithSpriteFrameName:@"intro_help1.png"];
            
            [arrowLeft setPosition:ccp(size.width * 0.19f, size.height * 0.70f)];
            
            [self addChild:arrowLeft z:kArrowsTutorialZValue tag:kArrowRightTutorialTagValue];
            
            CCSprite* arrowRight = [CCSprite spriteWithSpriteFrameName:@"intro_help2.png"];
            
            [arrowRight setPosition:ccp(size.width * 0.80f, size.height * 0.70f)];
            
            [self addChild:arrowRight z:kArrowsTutorialZValue tag:kArrowLeftTutorialTagValue];
        }
        
    }
    else{
        
        CCLabelBMFont* label = [CCLabelBMFont labelWithString:@"????" fntFile:FONTHIGHSCORES];
        
        [self addChild:label];
        
        [label setPosition:ccp(size.width * 0.5f, size.height * 0.97f - label.boundingBox.size.height)];
        
    }
    
    self.isTouchEnabled = TRUE;
    
}


@end
