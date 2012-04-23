//
//  Player.m
//  PattyCakeFighter
//
//  Created by Giuseppe Lapenta on 08/09/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import "Player.h"
#import "TargetedAction.h"

@interface Player ()
    
@property (readonly) int bpm;
@property (readonly) BOOL isLastPlayer;
@property (readonly) int frameForDoubleTouch;
-(void)handleHands;

@end
@implementation Player

@synthesize pattern;
@synthesize manoDestraApre;
@synthesize manoDestraChiude;
@synthesize manoSinistraApre;
@synthesize manoSinistraChiude;
@synthesize currentItem;
@synthesize handIsOpen;
@synthesize handsAreOpen;
@synthesize manoDestraColpita;
@synthesize manoSinistraColpita;
@synthesize manoDestraHitUnder;
@synthesize manoDestraHitOver;
@synthesize manoSinistraHitUnder;
@synthesize manoSinistraHitOver;
@synthesize manoDestraCrossHitUnder;
@synthesize manoDestraCrossHitOver;
@synthesize manoSinistraCrossHitUnder;
@synthesize manoSinistraCrossHitOver;
@synthesize feedBody;
@synthesize name;
@synthesize touchOk;
@synthesize bpm;
@synthesize isLastPlayer;
@synthesize delegate = _delegate;
@synthesize frameForDoubleTouch;
@synthesize manoDestraCrossApre;
@synthesize manoDestraCrossChiude;
@synthesize manoSinistraCrossApre;
@synthesize manoDestraCrossColpita;
@synthesize manoSinistraCrossChiude;
@synthesize manoSinistraCrossColpita;
@synthesize feedBodyErr;
@synthesize spriteBatchNode = _spriteBatchNode;
@synthesize spriteHitUnderBatchNode = _spriteHitUnderBatchNode;
@synthesize spriteHitOverBatchNode  = _spriteHitOverBatchNode;



#pragma mark -
#pragma mark - Update Method

-(void)updateStateWithDeltaTime:(ccTime)deltaTime {
    
    if (self.characterState == kStateDead){
        
        for (CCSprite* hand in [_spriteBatchNode children]) {
            
            [hand stopAllActions];
        }
        return;

    }
    

    currentTime += deltaTime;
        
    if ((cnt * (60.0 / bpm)) <= currentTime) {
        
        if (handIsOpen || handsAreOpen) {
            
        [_delegate didPlayerChangeHands:touchOk];
            
            if (!touchOk && feedBodyErr != nil) {
                
                id action = [CCAnimate actionWithAnimation:feedBodyErr];
                [self runAction:action];
            }
            else if(feedBody != nil){
                
                id action = [CCAnimate actionWithAnimation:feedBody];
                [self runAction:action];
            }

        }
        else currentItem = (currentItem +1)%([pattern count]);

        cnt++;
        [self handleHands];
    }

    
}

-(void)handleHands
{
    
    NSLog(@"%@", NSStringFromSelector(_cmd));

    touchOk = NO;
        
    if ([self characterState] == kStateDead) return;
    
    NSString* indexPattern = (NSString*)[pattern objectAtIndex:currentItem];
    
    if([indexPattern isEqualToString:@"two"]){
                
        if (handsAreOpen) {
            [self changeState:[NSNumber numberWithInt:kStateTwoHandsAreClosed]];
            handsAreOpen = FALSE;
        }else{
            
            [self changeState:[NSNumber numberWithInt:kStateTwoHandsAreOpen]];
            handsAreOpen = TRUE;
        }
        
    } else if ([indexPattern isEqualToString:@"dx"]) {
        
        if (handIsOpen) {
            [self changeState:[NSNumber numberWithInt:kStateRightHandClose]];
            handIsOpen = FALSE;
        }else{
            [self changeState:[NSNumber numberWithInt:kStateRightHandOpen]];
            [_delegate didPlayerOpenHand:kStateRightHandOpen];
            handIsOpen = TRUE;
        }
    }else if([indexPattern isEqualToString:@"sx"]){
        
        if (handIsOpen) {
            [self changeState:[NSNumber numberWithInt:kStateLeftHandClose]];
            handIsOpen = FALSE;
        }
        else{
            [self changeState:[NSNumber numberWithInt:kStateLeftHandOpen]];
            [_delegate didPlayerOpenHand:kStateLeftHandOpen];
            handIsOpen = TRUE;
        }
    }else if([indexPattern isEqualToString:@"sxCross"]){
        
        if (handIsOpen) {
            [self changeState:[NSNumber numberWithInt:kStateLeftCrossHandClose]];
            handIsOpen = FALSE;
        }else{
            [self changeState:[NSNumber numberWithInt:kStateLeftCrossHandOpen]];
            handIsOpen = TRUE;
        }
    }else if([indexPattern isEqualToString:@"dxCross"]){
        
        if (handIsOpen) {
            [self changeState:[NSNumber numberWithInt:kStateRightCrossHandClose]];
            handIsOpen = FALSE;
        }else{
            [self changeState:[NSNumber numberWithInt:kStateRightCrossHandOpen]];
            handIsOpen = TRUE;
        }

    }
}

-(void)handleHit:(CGPoint)location {
    
    CCSprite* rightHand = (CCSprite *)[_spriteBatchNode getChildByTag:kRightHandTagValue];
    
    CCSprite* leftHand = (CCSprite *)[_spriteBatchNode getChildByTag:kLeftHandTagValue];
    
    if (handIsOpen) {
        
        if ([leftHand isFrameDisplayed:[[[manoSinistraApre frames]objectAtIndex:2]spriteFrame]]
            && CGRectContainsPoint(rectLeft, location)) {
            
            [self changeState:[NSNumber numberWithInt:kStateLeftHandHit]];
            touchOk = YES;
            
        }else if(([rightHand isFrameDisplayed:[[[manoDestraApre frames]objectAtIndex:2]spriteFrame]])
            && CGRectContainsPoint(rectRight, location)){
            
            [self changeState:[NSNumber numberWithInt:kStateRightHandHit]];
            touchOk = YES;
            
        }else if ([leftHand isFrameDisplayed:[[[manoSinistraCrossApre frames]objectAtIndex:2]spriteFrame]]
                   && CGRectContainsPoint(rectLeftCross, location)) {
            
            [self changeState:[NSNumber numberWithInt:kStateLeftCrossHandHit]];
            touchOk = YES;
            
        }else if([rightHand isFrameDisplayed:[[[manoDestraCrossApre frames]objectAtIndex:2]spriteFrame]] 
                 && CGRectContainsPoint(rectRightCross, location)){
            
            [self changeState:[NSNumber numberWithInt:kStateRightCrossHandHit]];
            touchOk = YES;
            
        }else{
            
            PLAYSOUNDEFFECT(WRONGTAP);
            touchOk = NO;
            [_delegate didPlayerHasTouched:touchOk];
            
        }
        
    }else {
        
        PLAYSOUNDEFFECT(WRONGTAP);
        touchOk = NO;
        [_delegate didPlayerHasTouched:touchOk];
        
    }
    
}

-(void)handleHitsWithTouches:(NSArray*)touches{
    
    
    CGPoint firstLocation = [[touches objectAtIndex:0] CGPointValue];
    CGPoint secondLocation = [[touches objectAtIndex:1] CGPointValue];
    CCSprite* leftHand = (CCSprite *)[_spriteBatchNode getChildByTag:kLeftHandTagValue];
    CCSprite* rightHand = (CCSprite *)[_spriteBatchNode getChildByTag:kRightHandTagValue];
    
    if (handsAreOpen) {
        
        if (([leftHand isFrameDisplayed:[[[manoSinistraApre frames]objectAtIndex:frameForDoubleTouch]spriteFrame]]
            && (CGRectContainsPoint(rectLeft, firstLocation) 
            || CGRectContainsPoint(rectLeft, secondLocation)))
            && ([rightHand isFrameDisplayed:[[[manoDestraApre frames]objectAtIndex:frameForDoubleTouch]spriteFrame]]
            && (CGRectContainsPoint(rectRight, secondLocation)
            || CGRectContainsPoint(rectRight, firstLocation))))
        {
            [self changeState:[NSNumber numberWithInt:kStateTwoHandsHit]];
            touchOk = YES;
        }else{
            
            PLAYSOUNDEFFECT(WRONGTAP);
            touchOk = NO;
            [_delegate didPlayerHasTouched:touchOk];
            
        }
    }else{
        
        PLAYSOUNDEFFECT(WRONGTAP);
        touchOk = NO;
        [_delegate didPlayerHasTouched:touchOk];
    }
    

}

#pragma mark -

-(void)changeState:(NSNumber *)newState {
    
    CharacterStates state = (CharacterStates)[newState intValue];
    
    CCSprite* leftHand     = (CCSprite *)[_spriteBatchNode getChildByTag:kLeftHandTagValue];
    CCSprite* rightHand    = (CCSprite *)[_spriteBatchNode getChildByTag:kRightHandTagValue];
    CCSprite* leftHitUnder = (CCSprite *)[_spriteHitUnderBatchNode getChildByTag:kHitLeftUnderTagValue];
    CCSprite* leftHitOver  = (CCSprite *)[_spriteHitOverBatchNode getChildByTag:kHitLeftOverTagValue];
    CCSprite* rightHitUnder= (CCSprite *)[_spriteHitUnderBatchNode getChildByTag:kHitRightUnderTagValue];
    CCSprite* rightHitOver = (CCSprite *)[_spriteHitOverBatchNode getChildByTag:kHitRightOverTagValue];

    [leftHand stopAllActions];
    [rightHand stopAllActions];
    [leftHitUnder stopAllActions];
    [leftHitOver stopAllActions];
    [rightHitUnder stopAllActions];
    [rightHitOver stopAllActions];
    leftHitOver.opacity   = 0;
    leftHitUnder.opacity  = 0;
    rightHitOver.opacity  = 0;
    rightHitUnder.opacity = 0;

    NSLog(@"%@", NSStringFromSelector(_cmd));

    id action                  = nil;
    id doubleAction            = nil;
    
    id actionHitUnder          = nil;
    id actionHitUnderDouble    = nil;
    id actionHitOver           = nil;
    id actionHitOverDouble     = nil;
    id handAnimation           = nil;
    id handAnimationDouble     = nil;
    id hitAnimationUnder       = nil;
    id hitAnimationOver        = nil;
    id hitAnimationUnderDouble = nil;
    id hitAnimationOverDouble  = nil;
    
    [self setCharacterState:state];
    
    switch (state) {
            
        case kStateNone:
            break;
        case kStateLeftHandClose:
            action = [CCAnimate actionWithAnimation:manoSinistraChiude];
            handAnimation = leftHand;
            break;
        case kStateLeftHandOpen:
            action = [CCAnimate actionWithAnimation:manoSinistraApre];
            handAnimation = leftHand;
            break;
        case kStateRightHandClose:
            action = [CCAnimate actionWithAnimation:manoDestraChiude];
            handAnimation = rightHand;
            break;
        case kStateRightHandOpen:
            action = [CCAnimate actionWithAnimation:manoDestraApre];
            handAnimation = rightHand;
            break;
        case kStateLeftHandHit:
            
             action             = [CCAnimate actionWithAnimation:manoSinistraColpita];
             actionHitUnder     = [CCSequence actions:
                                  [CCFadeIn actionWithDuration:0.01f],
                                  [CCAnimate actionWithAnimation:manoSinistraHitUnder],
                                  [CCFadeOut actionWithDuration:0.01f], nil ];

             actionHitOver      = [CCSequence actions:
                                  [CCFadeIn actionWithDuration:0.01f],
                                  [CCAnimate actionWithAnimation:manoSinistraHitOver],
                                  [CCFadeOut actionWithDuration:0.01f], nil ];

             hitAnimationUnder  = leftHitUnder;
             hitAnimationOver   = leftHitOver;
             handAnimation      = leftHand;
             break;
        case kStateRightHandHit:
            
             action             = [CCAnimate actionWithAnimation:manoDestraColpita];
             actionHitUnder     = [CCSequence actions:
                                  [CCFadeIn actionWithDuration:0.001f],
                                  [CCAnimate actionWithAnimation:manoDestraHitUnder],
                                  [CCFadeOut actionWithDuration:0.001f], nil ];
            
             actionHitOver      = [CCSequence actions:
                                  [CCFadeIn actionWithDuration:0.001f],
                                  [CCAnimate actionWithAnimation:manoDestraHitOver],
                                  [CCFadeOut actionWithDuration:0.001f], nil ];
            
             hitAnimationUnder  = rightHitUnder;
             hitAnimationOver   = rightHitOver;
             handAnimation      = rightHand;
             break;
        case kStateTwoHandsHit:
            action              = [CCAnimate actionWithAnimation:manoDestraColpita];
            doubleAction        = [CCAnimate actionWithAnimation:manoSinistraColpita];
            
             actionHitUnder     = [CCSequence actions:
                                  [CCFadeIn actionWithDuration:0.001f],
                                  [CCAnimate actionWithAnimation:manoDestraHitUnder],
                                  [CCFadeOut actionWithDuration:0.001f], nil ];
            
             actionHitOver      = [CCSequence actions:
                                  [CCFadeIn actionWithDuration:0.001f],
                                  [CCAnimate actionWithAnimation:manoDestraHitOver],
                                  [CCFadeOut actionWithDuration:0.001f], nil ];
            
       actionHitUnderDouble     = [CCSequence actions:
                                  [CCFadeIn actionWithDuration:0.001f],
                                  [CCAnimate actionWithAnimation:manoSinistraHitUnder],
                                  [CCFadeOut actionWithDuration:0.001f], nil ];
            
       actionHitOverDouble      = [CCSequence actions:
                                  [CCFadeIn actionWithDuration:0.001f],
                                  [CCAnimate actionWithAnimation:manoSinistraHitOver],
                                  [CCFadeOut actionWithDuration:0.001f], nil ];
            
       hitAnimationUnderDouble  = leftHitUnder;
       hitAnimationOverDouble   = leftHitOver;

            hitAnimationUnder   = rightHitUnder;
            hitAnimationOver    = rightHitOver;            
            handAnimation       = rightHand;
            handAnimationDouble = leftHand;
            break;
        case kStateTwoHandsAreOpen:
            action = [CCAnimate actionWithAnimation:manoDestraApre];
            doubleAction = [CCAnimate actionWithAnimation:manoSinistraApre];
            handAnimation = rightHand;
            handAnimationDouble = leftHand;
            break;   
        case kStateTwoHandsAreClosed:
            action = [CCAnimate actionWithAnimation:manoDestraChiude];
            doubleAction = [CCAnimate actionWithAnimation:manoSinistraChiude];
            handAnimation = rightHand;
            handAnimationDouble = leftHand;
            break;
        case kStateRightCrossHandClose:
            action = [CCAnimate actionWithAnimation:manoDestraCrossChiude];
            [_spriteBatchNode reorderChild:rightHand z:MinZOrder];
            handAnimation = rightHand;
            break;
        case kStateRightCrossHandOpen:
            action = [CCAnimate actionWithAnimation:manoDestraCrossApre];
            [_spriteBatchNode reorderChild:rightHand z:MaxZOrder];
            handAnimation = rightHand;
            break;
        case kStateLeftCrossHandClose:
            action = [CCAnimate actionWithAnimation:manoSinistraCrossChiude];
            [_spriteBatchNode reorderChild:leftHand z:MinZOrder];
            handAnimation = leftHand;
            break;
        case kStateLeftCrossHandOpen:
            action = [CCAnimate actionWithAnimation:manoSinistraCrossApre];
            [_spriteBatchNode reorderChild:leftHand z:MaxZOrder];
            handAnimation = leftHand;
            break;
        case kStateRightCrossHandHit:
            action = [CCAnimate actionWithAnimation:manoDestraCrossColpita];
            
            actionHitUnder     = [CCSequence actions:
                                  [CCFadeIn actionWithDuration:0.01f],
                                  [CCAnimate actionWithAnimation:manoDestraCrossHitUnder],
                                  [CCFadeOut actionWithDuration:0.01f], nil ];
            
            actionHitOver      = [CCSequence actions:
                                  [CCFadeIn actionWithDuration:0.01f],
                                  [CCAnimate actionWithAnimation:manoDestraCrossHitOver],
                                  [CCFadeOut actionWithDuration:0.01f], nil ];
            
            hitAnimationUnder  = rightHitUnder;
            hitAnimationOver   = rightHitOver;
            handAnimation = rightHand;
            break;
        case kStateLeftCrossHandHit:
            
            action = [CCAnimate actionWithAnimation:manoSinistraCrossColpita];
            actionHitUnder     = [CCSequence actions:
                                  [CCFadeIn actionWithDuration:0.01f],
                                  [CCAnimate actionWithAnimation:manoSinistraCrossHitUnder],
                                  [CCFadeOut actionWithDuration:0.01f], nil ];
            
            actionHitOver      = [CCSequence actions:
                                  [CCFadeIn actionWithDuration:0.01f],
                                  [CCAnimate actionWithAnimation:manoSinistraCrossHitOver],
                                  [CCFadeOut actionWithDuration:0.01f], nil ];
            
            hitAnimationUnder  = leftHitUnder;
            hitAnimationOver   = leftHitOver;

            handAnimation = leftHand;
            break;
        case kStateDead:
            [self stopAllActions];
            [leftHand stopAllActions];
            [rightHand stopAllActions];
        
        default:
            break;
            
    }
    
    if (action != nil && handAnimationDouble != nil) {
                
        [handAnimation              runAction:action],
        [handAnimationDouble        runAction:doubleAction];
                       
    }else [handAnimation            runAction:action];
    
    if (hitAnimationUnder != nil && hitAnimationUnderDouble != nil) {
        
        [hitAnimationUnder          runAction:actionHitUnder];
        [hitAnimationUnderDouble    runAction:actionHitUnderDouble];
        [hitAnimationOver           runAction:actionHitOver];
        [hitAnimationOverDouble     runAction:actionHitOverDouble];
        
    }else {
        
        [hitAnimationUnder          runAction:actionHitUnder];
        [hitAnimationOver           runAction:actionHitOver];
    }
    
}

#pragma mark -
#pragma mark ===  Init Methods  ===
#pragma mark -


+(id)playerWithDictionary:(NSDictionary *)playerSettings{
        
     return [[self alloc] initWithDictionary:playerSettings];    
}


#pragma mark -

-(void)loadHitSpriteWithDictionary:(NSDictionary *)playerSettings{
    
    CCSprite* rightHand = (CCSprite *)[_spriteBatchNode getChildByTag:kRightHandTagValue];
    CCSprite* leftHand  = (CCSprite *)[_spriteBatchNode getChildByTag:kLeftHandTagValue];
    
    // Get name of sprite from dictionary
    
    NSString* hitNameDxUnder = [playerSettings objectForKey:@"hitNameDxUnder"];
    NSString* hitNameDxOver  = [playerSettings objectForKey:@"hitNameDxOver"];
    NSString* hitNameSxUnder = [playerSettings objectForKey:@"hitNameSxUnder"];
    NSString* hitNameSxOver  = [playerSettings objectForKey:@"hitNameSxOver"];
    
    // Creation of Sprite
    
    CCSprite* leftHitUnder   = [CCSprite spriteWithSpriteFrameName:hitNameSxUnder];
    CCSprite* leftHitOver    = [CCSprite spriteWithSpriteFrameName:hitNameSxOver];
    CCSprite* rightHitUnder  = [CCSprite spriteWithSpriteFrameName:hitNameDxUnder];
    CCSprite* rightHitOver   = [CCSprite spriteWithSpriteFrameName:hitNameDxOver];
    
    leftHitUnder.flipX = YES;
    leftHitOver.flipX = YES;
    leftHitUnder.opacity  = 0;
    leftHitOver.opacity   = 0;
    rightHitUnder.opacity = 0;
    rightHitOver.opacity  = 0;
        
    // Set Position
    
    [rightHitUnder setPosition:rightHand.position];
    [rightHitOver  setPosition:rightHand.position];
    [leftHitUnder  setPosition:leftHand.position];
    [leftHitOver   setPosition:leftHand.position];
    
    // Set anchor point
    
    [rightHitUnder setAnchorPoint:ccp(0 , 0)];
    [rightHitOver  setAnchorPoint:ccp(0 , 0)];
    [leftHitUnder  setAnchorPoint:ccp(0,  0)];
    [leftHitOver   setAnchorPoint:ccp(0,  0)];
    
    // Add to batchnode
    
    [_spriteHitUnderBatchNode addChild:leftHitUnder z:kHitLeftUnderZValue tag:kHitLeftUnderTagValue];
    [_spriteHitOverBatchNode  addChild:leftHitOver  z:kHitLeftOverZValue tag:kHitLeftOverTagValue];
    [_spriteHitUnderBatchNode addChild:rightHitUnder z:kHitRightUnderZValue tag:kHitRightUnderTagValue];
    [_spriteHitOverBatchNode  addChild:rightHitOver z:kHitRightOverZValue tag:kHitRightOverTagValue];
    
    // Add Cross sprite if available
    
    if (manoDestraCrossApre != nil) {
        
        NSString* hitNameDxCrossUnder = [playerSettings objectForKey:@"hitNameDxCrossUnder"];
        NSString* hitNameDxCrossOver  = [playerSettings objectForKey:@"hitNameDxCrossOver"];
        
        CCSprite* rightCrossHitUnder  = [CCSprite spriteWithSpriteFrameName:hitNameDxCrossUnder];
        CCSprite* rightCrossHitOver   = [CCSprite spriteWithSpriteFrameName:hitNameDxCrossOver];
        
        rightCrossHitUnder.opacity = 0;
        rightCrossHitOver.opacity  = 0;
        
        rightCrossHitUnder.flipX = YES;
        rightCrossHitOver.flipX  = YES;
        
        [_spriteHitUnderBatchNode addChild:rightCrossHitUnder z:kHitRightCrossUnderZValue tag:kHitRightCrossUnderTagValue];
        [_spriteHitOverBatchNode addChild:rightCrossHitOver z:kHitRightCrossOverZValue tag:kHitRightCrossOverTagValue];
        
        [rightCrossHitUnder setPosition:rightHand.position];
        [rightCrossHitOver  setPosition:rightHand.position];
    }
    
    if (manoSinistraCrossApre != nil) {
        
        NSString* hitNameSxCrossUnder = [playerSettings objectForKey:@"hitNameSxCrossUnder"];
        NSString* hitNameSxCrossOver  = [playerSettings objectForKey:@"hitNameSxCrossOver"];
        
        CCSprite* leftCrossHitUnder  = [CCSprite spriteWithSpriteFrameName:hitNameSxCrossUnder];
        CCSprite* leftCrossHitOver   = [CCSprite spriteWithSpriteFrameName:hitNameSxCrossOver];
        
        leftCrossHitUnder.opacity = 0;
        leftCrossHitOver.opacity  = 0;
        
        leftCrossHitUnder.flipX = YES;
        leftCrossHitOver.flipX  = YES;
        
        [_spriteHitUnderBatchNode addChild:leftCrossHitUnder z:kHitLeftCrossUnderZValue tag:kHitLeftCrossUnderTagValue];
        [_spriteHitOverBatchNode addChild:leftCrossHitOver z:kHitLeftCrossOverZValue tag:kHitLeftCrossOverTagValue];
        
        [leftCrossHitUnder setPosition:leftHand.position];
        [leftCrossHitOver  setPosition:leftHand.position];
        
    }
    
    
}
#pragma mark -

-(void)initAnimations {
    
    id dao = [[GameManager sharedGameManager] dao];
    
    [self setManoDestraApre:[dao loadPlistForAnimationWithName:@"manoApre" 
                                                   andClassName:name]];
    [self setManoDestraChiude:[dao loadPlistForAnimationWithName:@"manoChiude" 
                                                     andClassName:name]];
    [self setManoSinistraApre:[dao loadPlistForAnimationWithName:@"manoApre" 
                                                     andClassName:name]];
    [self setManoSinistraChiude:[dao loadPlistForAnimationWithName:@"manoChiude"
                                                       andClassName:name]];
    [self setManoSinistraColpita:[dao loadPlistForAnimationWithName:@"manoColpita"
                                                        andClassName:name]];
    [self setManoDestraColpita:[dao loadPlistForAnimationWithName:@"manoColpita"
                                                      andClassName:name]];
    [self setFeedBody:[dao loadPlistForAnimationWithName:@"bodyFeed"
                                             andClassName:name]];
    [self setManoDestraCrossApre:[dao loadPlistForAnimationWithName:@"manoCrossApre"
                                                       andClassName:name]];
    [self setManoDestraCrossChiude:[dao loadPlistForAnimationWithName:@"manoCrossChiude"
                                                         andClassName:name]];
    [self setManoSinistraCrossApre:[dao loadPlistForAnimationWithName:@"manoCrossApre" 
                                                         andClassName:name]];
    [self setManoSinistraCrossChiude:[dao loadPlistForAnimationWithName:@"manoCrossChiude"
                                                           andClassName:name]];
    [self setManoDestraCrossColpita:[dao loadPlistForAnimationWithName:@"manoCrossColpita" 
                                                          andClassName:name]];
    [self setManoSinistraCrossColpita:[dao loadPlistForAnimationWithName:@"manoCrossColpita" 
                                                            andClassName:name]];
    [self setFeedBodyErr:[dao loadPlistForAnimationWithName:@"bodyFeedErr" 
                                               andClassName:name]];
    [self setManoDestraHitUnder:[dao loadPlistForAnimationWithName:@"manoDestraHitUnder" 
                                                 andClassName:name]];
    [self setManoDestraHitOver:[dao loadPlistForAnimationWithName:@"manoDestraHitOver" 
                                                 andClassName:name]];
    [self setManoSinistraHitUnder:[dao loadPlistForAnimationWithName:@"manoSinistraHitUnder" 
                                                   andClassName:name]];
    [self setManoSinistraHitOver:[dao loadPlistForAnimationWithName:@"manoSinistraHitOver" 
                                                   andClassName:name]];
    [self setManoDestraCrossHitUnder:[dao loadPlistForAnimationWithName:@"manoDestraCrossHitUnder"
                                                      andClassName:name]];
    [self setManoDestraCrossHitOver:[dao loadPlistForAnimationWithName:@"manoDestraCrossHitOver"
                                                      andClassName:name]];
    [self setManoSinistraCrossHitUnder:[dao loadPlistForAnimationWithName:@"manoSinistraCrossHitUnder" 
                                                        andClassName:name]];
    [self setManoSinistraCrossHitOver:[dao loadPlistForAnimationWithName:@"manoSinistraCrossHitOver" 
                                                        andClassName:name]];

}

#pragma mark -


-(id) initWithDictionary:(NSMutableDictionary*)playerSettings
{    
    [self setName:[playerSettings objectForKey:@"name"]];

    [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:[NSString stringWithFormat:@"%@Player.plist",name] textureFilename:[NSString stringWithFormat:@"%@Player.png",name]];
    
    CCTexture2D* texture = [[CCTextureCache sharedTextureCache] addImage:[playerSettings objectForKey:@"headName"]];
    
    if( (self=[super initWithTexture:texture]))
        
    {
        CCLOG(@"Inizializzazione Player");
        
        currentTime = 0;
        
        cnt = 1;
        
        self.gameObjectType = kObjectTypePlayer;
        
        isLastPlayer = [[GameManager sharedGameManager] isLastLevel];
        
        CGSize size = [[CCDirector sharedDirector] winSize];
                
        bpm = [[playerSettings objectForKey:@"bpm"] intValue];
        
        frameForDoubleTouch = (bpm == 180) ? 1 : 2;
        
        CGPoint positionLeft = 
        CGPointFromString([playerSettings objectForKey:@"leftPosition"]);
        
        CGPoint positionRight = 
        CGPointFromString([playerSettings objectForKey:@"rightPosition"]);
        
        CGPoint rectLeftPosition = 
        CGPointFromString([playerSettings objectForKey:@"leftRectPosition"]);
        
        CGPoint rectRightPosition =
        CGPointFromString([playerSettings objectForKey:@"rightRectPosition"]);
        
        CGPoint rectRightCrossPosition = 
        CGPointFromString([playerSettings objectForKey:@"rightRectCrossPosition"]);
        
        CGPoint leftRectCrossPosition = 
        CGPointFromString([playerSettings objectForKey:@"leftRectCrossPosition"]);
        
        rectLeft = CGRectMake(rectLeftPosition.x/2, rectLeftPosition.y/2, 80, 80);
        
        rectRight = CGRectMake(rectRightPosition.x/2, rectRightPosition.y/2, 80, 80); 
                
        rectLeftCross = CGRectMake(leftRectCrossPosition.x/2, leftRectCrossPosition.y/2, 80, 80);
        
        rectRightCross = CGRectMake(rectRightCrossPosition.x/2, rectRightCrossPosition.y/2, 80, 80);
        
        NSLog(@"Rect Cross Right: %@ \n Rect Cross Left: %@", NSStringFromCGRect(rectRightCross), NSStringFromCGRect(rectLeftCross));
        
        // I use CCSpriteBatchNode as a layer: Under ---> Hand ----> Over (ZOrder)
        
        [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:[NSString stringWithFormat:@"%@Hit.plist", name] textureFilename:[NSString stringWithFormat:@"%@Hit.png", name]];
        
        _spriteHitUnderBatchNode = [CCSpriteBatchNode batchNodeWithFile:[NSString stringWithFormat:@"%@Hit.png", name]];
        
        [self addChild:_spriteHitUnderBatchNode];
                    
        // Add Batch Node Hand
        
        _spriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:[NSString stringWithFormat:@"%@Player.png",name]];
    
        [self addChild:_spriteBatchNode]; 
        
        // Add Batch Node Over
        
        _spriteHitOverBatchNode  = [CCSpriteBatchNode batchNodeWithTexture:_spriteHitUnderBatchNode.texture];
        
        [self addChild:_spriteHitOverBatchNode];
        
        // Set position of head
        
        CGPoint position = 
        CGPointFromString([playerSettings objectForKey:@"position"]);
        
        self.position    = ccp(size.width * (position.x/2 / size.width), size.height - size.height * (position.y/2 / size.height));
        
        // Add Right Hand
                
        NSString* nameHand = [playerSettings objectForKey:@"handName"];
    
        CCSprite* rightHand =  [CCSprite spriteWithSpriteFrame:
                                [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:nameHand]];
        
        rightHand.anchorPoint = ccp(0, 0);
                            
        [rightHand setPosition:ccp(- self.position.x + (self.contentSize.width * self.anchorPoint.x) + size.width * (positionRight.x/2 / size.width), size.height - self.position.y + (self.contentSize.height * self.anchorPoint.y) - positionRight.y/2)];
    
        [_spriteBatchNode addChild:rightHand z:kRightHandZValue tag:kRightHandTagValue];
        
        [rightHand setVertexZ:40];

        
        // Add Left hand
        
        CCSprite* leftHand =  [CCSprite spriteWithSpriteFrame:
                               [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:nameHand]];
    
        leftHand.flipX = YES;
            
        leftHand.anchorPoint = ccp(0, 0);
                
        leftHand.position = ccp(- self.position.x + (self.contentSize.width * self.anchorPoint.x) + positionLeft.x/2, size.height - self.position.y + (self.contentSize.height * self.anchorPoint.y) - positionLeft.y/2);
        
        [_spriteBatchNode addChild:leftHand z:kLeftHandZValue tag:kLeftHandTagValue];
        
        [leftHand setVertexZ:1];
        
        // get pattern from Game Manager
        
        pattern = [[GameManager sharedGameManager] patternForLevel];
        
        // Load animation
            
        [self initAnimations];
        
        // Add sprite for Hit Animation
        
        [self loadHitSpriteWithDictionary:playerSettings];
                
        [self setCharacterState:kStateNone];
        
        currentItem = -1;
            
        handIsOpen = FALSE;
        
        handsAreOpen = FALSE;
        
    }
    return self;
}

#pragma mark -
#pragma mark ===  Dealloc  ===
#pragma mark -


- (void)dealloc {
    
    _spriteBatchNode = nil;
    _spriteHitOverBatchNode = nil;
    _spriteHitUnderBatchNode= nil;
    _delegate = nil;
    
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), self);
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:[NSString stringWithFormat:@"%@Player.plist",name]];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:[NSString stringWithFormat:@"%@Hit.plist", name]];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
}

@end

