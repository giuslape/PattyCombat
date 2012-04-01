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



#pragma mark -
#pragma mark ===  Dealloc  ===
#pragma mark -

- (void)dealloc {
    
    [[[CCDirectorIOS sharedDirector] touchDispatcher] removeDelegate:self];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"IntroButtAndFeed.plist"];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];    
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    
    _spriteBatchNode = nil;
    
        
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
        
      //  CGSize size = [CCDirectorIOS sharedDirector].winSize;
        
        CCLayerColor* layer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 0)];
                
        [self addChild:layer z:kDarkValueIntroZValue tag:kDarkLayerIntroTagValue];
                
        NSLog(@"Inizializzazione Intro");
    }
    return self;
}

-(void)onEnterTransitionDidFinish{
        
    [self scheduleOnce:@selector(showButtonAndFeed) delay:0.5f];
    
    [[GameManager sharedGameManager] playBackgroundTrack:BACKGROUND_TRACK_MAIN_MENU];
    
}


-(void)feedPattern{
    
    id gameManager = [GameManager sharedGameManager];
    
    float padding = 2;
    
    feedHand = [[NSMutableArray alloc] init];       
    
    
    //Load Pattern for current Level
    
    patternArray = [[NSMutableArray alloc] initWithArray:[gameManager patternForLevel]];
    
    // Insert each item of PatternArray in feedHand array with check if is dx, sx or two
    
    for (NSString* hand in patternArray) {
        
        CCSprite* handSprite = nil;
        CCSprite* twoHandSprite = nil;
        CCSprite* arrow = nil;
        
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
                                [[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"intro_feed_dx_01.png"]];
            twoHandSprite = [CCSprite spriteWithSpriteFrame: 
                                [[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"intro_feed_sx_01.png"]];
            
            
            [handSprite setTag:kHandFeedRightTagValue];
            [twoHandSprite setTag:kHandFeedLeftTagValue];
            
        }else CCLOG(@"Pattern non riconosciuto");
        
        
        if (handSprite != nil && twoHandSprite != nil) {
            
            arrow = [CCSprite spriteWithSpriteFrame: 
                     [[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"intro_feed_arrow.png"]];
            
            [arrow setTag:kArrowFeedTagValue];
            
            [feedHand addObject:handSprite];
            [feedHand addObject:twoHandSprite];
            [feedHand addObject:arrow];
            
        }else if (handSprite != nil) {
            
            arrow = [CCSprite spriteWithSpriteFrame: 
                     [[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"intro_feed_arrow.png"]];
            
            [arrow setTag:kArrowFeedTagValue];
            
            [feedHand addObject:handSprite];
            [feedHand addObject:arrow];
        }
        
    } 
    [feedHand removeLastObject];
    
    // Align elements of array feedhand
    
    [self alignHandsWithPadding:padding];
    
    
}

-(void)alignHandsWithPadding:(float)padding{
    
    CGSize size = [[CCDirectorIOS sharedDirector] winSize];
    
    float width = -padding;
    
    for (CCSprite* item in feedHand) {
        
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
            
            _feedIndex += 2;
            
        }else if(nodeHit == kStateRightHandHit && 
           ([patternDescription isEqualToString:@"dx"] ||
            [patternDescription isEqualToString:@"dxCross"])){
            
                [_rightHand stopAllActions];
                [_rightHand runAction:[CCAnimate actionWithAnimation:animationHandRightOk]];
                 
                CCSpriteFrame* frame = [[[animationFeedRight frames] objectAtIndex:1] spriteFrame];

                [[feedHand objectAtIndex:_feedIndex] setDisplayFrame:frame];

                _feedIndex += 2;
            
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
             setDisplayFrame:[[[animationFeedRight frames] objectAtIndex:1]spriteFrame]];

            
            _feedIndex++;
            
            CCSpriteFrame* frame = [[[animationFeedLeft frames] objectAtIndex:1] spriteFrame];
            
            [[feedHand objectAtIndex:_feedIndex]        
             setDisplayFrame:frame];

            
            _feedIndex += 2;
            
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
        
        }
}
    


#pragma mark -
#pragma mark - Start Game Method

-(void)startGamePlay {
            
        CCLOG(@"Intro complete, asking Game Manager to start the Game play");
        
        [[GameManager sharedGameManager] runSceneWithID:kGamelevel1];
        
        self.isTouchEnabled = FALSE;
}

-(void)verifiedTouchFromLocation:(NSValue*)location{
    
    CGPoint pointLocation = [location CGPointValue];
    
    pointLocation = [[CCDirectorIOS sharedDirector] convertToGL:pointLocation];
    pointLocation = [self convertToNodeSpace:pointLocation];
    
    CCSprite* fightButton = (CCSprite *)[_spriteBatchNode getChildByTag:kFightButtonTagValue];
    
    if (CGRectContainsPoint([fightButton boundingBox], pointLocation) && fightButton.opacity == 255) {
        
        self.isTouchEnabled = FALSE;
        
        [fightButton removeFromParentAndCleanup:YES];
        [_leftHand removeFromParentAndCleanup:YES];
        [_rightHand removeFromParentAndCleanup:YES];
        
        CGSize size = [CCDirectorIOS sharedDirector].winSize;

        CCLabelBMFont* labelEnd = [CCLabelBMFont labelWithString:@"Don't forget the pattern" fntFile:FONTHIGHSCORES];
        
        [self addChild:labelEnd z:4];
        
        [labelEnd setPosition:ccp(size.width/2, size.height * 0.6)];
        
        CCLayerColor* darkLayer = (CCLayerColor *)[self getChildByTag:kDarkLayerIntroTagValue];
        
        [darkLayer runAction:[CCFadeIn actionWithDuration:1]];
        
        for (CCSprite* item in feedHand) {
            
            CCMoveTo* move = [CCMoveTo actionWithDuration:1 position:ccp(item.position.x, size.height/2)];
            
            [item runAction:move];
        }
        
        [self scheduleOnce:@selector(startGamePlay) delay:2];
    }
    
    if (!_isTouchInTime) {
        
        
        [self handleHitWithTouch:pointLocation];
        
        _state = kStateOneTouchWaiting;
    }
    
    if (_isLastLevel) {
        
        [self startGamePlay];
    }
}

-(CharacterStates)detectNodeFromTouches:(NSArray*)touches{
    
    CharacterStates nodeHits = kStateNone;

    if ([touches count] == 2) {

    CCLOG(@"%@ %@", NSStringFromSelector(_cmd), self);
        
    CGPoint firstLocation = [[touches objectAtIndex:0] CGPointValue];
    CGPoint secondLocation = [[touches objectAtIndex:1] CGPointValue];
    
    if((CGRectContainsPoint([_rightHand boundingBox], firstLocation) && 
        CGRectContainsPoint([_leftHand boundingBox], secondLocation)) || 
       ((CGRectContainsPoint([_rightHand boundingBox], secondLocation) && 
         CGRectContainsPoint([_leftHand boundingBox], firstLocation))))
        
    nodeHits =  kStateTwoHandsHit;
    

    else if (CGRectContainsPoint([_rightHand boundingBox], firstLocation) ||
             CGRectContainsPoint([_rightHand boundingBox], secondLocation))
                    nodeHits = kStateRightHandHit;
        
        else if (CGRectContainsPoint([_leftHand boundingBox], firstLocation)||
                 CGRectContainsPoint([_leftHand boundingBox], secondLocation))
                    nodeHits =  kStateLeftHandHit;
        
                else nodeHits = kStateHitBackground;
    }

    
    return nodeHits;
}

-(CharacterStates)detectNodeFromTouch:(CGPoint)touch{
    
    CCLOG(@"%@ %@", NSStringFromCGPoint(touch), self);

    CharacterStates nodeHit;
    
    if (CGRectContainsPoint([_rightHand boundingBox], touch))nodeHit = kStateRightHandHit;
    
    else if (CGRectContainsPoint([_leftHand boundingBox], touch))nodeHit =  kStateLeftHandHit;
    
    else nodeHit = kStateHitBackground;
    
    return nodeHit;

}

-(void)showButtonAndFeed{
    
    CGSize size = [[CCDirectorIOS sharedDirector] winSize];
    
    // Check if is last level
    
    if (!_isLastLevel) {
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"IntroButtAndFeed.plist"];
        
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
        
        [_rightHand setPosition:ccp(size.width * 0.19f, size.height * 0.5f)];
        
        
        // Add Left Hand
        
        _leftHand = [CCSprite spriteWithSpriteFrameName:
                    [NSString stringWithString:@"intro_btn_sx_01.png"]];
        
        [_spriteBatchNode addChild:_leftHand z:kLeftHandZvalue tag:kLeftHandTagValue];
        
        [_leftHand setPosition:ccp(size.width * 0.81f, size.height * 0.5f)];
        
        CCSprite* fightButton = [CCSprite spriteWithSpriteFrameName:@"fight_btn.png"];
        fightButton.opacity = 0;
        
        [_spriteBatchNode addChild:fightButton z:kFightButtonZValue tag:kFightButtonTagValue];
        
        [fightButton setPosition:ccp(size.width - fightButton.contentSize.width * 0.6f, 0)];
        
        [fightButton setAnchorPoint:ccp(0.5f, 0)];
        
    }
    else{
        
        CCLabelBMFont* label = [CCLabelBMFont labelWithString:@"????" fntFile:@"Marker Felt"];
        
        [self addChild:label];
        
        [label setPosition:ccp(size.width * 0.5f, size.height * 0.97f - label.boundingBox.size.height)];
        
    }
    
    self.isTouchEnabled = TRUE;
    
    
}


@end
