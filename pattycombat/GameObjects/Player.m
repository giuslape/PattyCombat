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
@synthesize rightHandBatchNode = _rightHandBatchNode;
@synthesize leftHandBatchNode = _leftHandBatchNode;
@synthesize bodyBatchNode = _bodyBatchNode;


#pragma mark -
#pragma mark - Update Method

-(void)updateStateWithDeltaTime:(ccTime)deltaTime {
    
    if (self.characterState == kStateDead){
        
        [self stopAllActions];
        
        for (CCSprite* hand in [_leftHandBatchNode children]) {
            
            [hand stopAllActions];
        }   
        
        for (CCSprite* hand in [_rightHandBatchNode children]) {
            
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
    
    CCSprite* rightHand = (CCSprite *)[_rightHandBatchNode getChildByTag:kRightHandTagValue];
    
    CCSprite* leftHand = (CCSprite *)[_leftHandBatchNode getChildByTag:kLeftHandTagValue];
    
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
    CCSprite* leftHand = (CCSprite *)[_leftHandBatchNode getChildByTag:kLeftHandTagValue];
    CCSprite* rightHand = (CCSprite *)[_rightHandBatchNode getChildByTag:kRightHandTagValue];
    
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
    CCSprite* leftHand = (CCSprite *)[_leftHandBatchNode getChildByTag:kLeftHandTagValue];
    CCSprite* rightHand = (CCSprite *)[_rightHandBatchNode getChildByTag:kRightHandTagValue];
    
    [leftHand stopAllActions];
    [rightHand stopAllActions];

    NSLog(@"%@", NSStringFromSelector(_cmd));

    id action = nil;
    id doubleAction = nil;
    id handAnimation = nil;
    id handAnimationDouble = nil;
    
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
            action = [CCAnimate actionWithAnimation:manoSinistraColpita];
            handAnimation = leftHand;
            break;
        case kStateRightHandHit:
            action = [CCAnimate actionWithAnimation:manoDestraColpita];
            handAnimation = rightHand;
            break;
        case kStateTwoHandsHit:
            action = [CCAnimate actionWithAnimation:manoDestraColpita];
            doubleAction = [CCAnimate actionWithAnimation:manoSinistraColpita];
            handAnimation = rightHand;
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
            [self reorderChild:_rightHandBatchNode z:MinZOrder];
            handAnimation = rightHand;
            break;
        case kStateRightCrossHandOpen:
            action = [CCAnimate actionWithAnimation:manoDestraCrossApre];
            [self reorderChild:_rightHandBatchNode z:MaxZOrder];
            handAnimation = rightHand;
            break;
        case kStateLeftCrossHandClose:
            action = [CCAnimate actionWithAnimation:manoSinistraCrossChiude];
            [self reorderChild:_leftHandBatchNode z:MinZOrder];
            handAnimation = leftHand;
            break;
        case kStateLeftCrossHandOpen:
            action = [CCAnimate actionWithAnimation:manoSinistraCrossApre];
            [self reorderChild:_leftHandBatchNode z:MaxZOrder];
            handAnimation = leftHand;
            break;
        case kStateRightCrossHandHit:
            action = [CCAnimate actionWithAnimation:manoDestraCrossColpita];
            handAnimation = rightHand;
            break;
        case kStateLeftCrossHandHit:
            action = [CCAnimate actionWithAnimation:manoSinistraCrossColpita];
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
                
        [handAnimation runAction:action],
        [handAnimationDouble runAction:doubleAction];
                       
    }else [handAnimation runAction:action];
    
    
}

#pragma mark -


#pragma mark Init Methods
#pragma mark -

+(id)playerWithDictionary:(NSDictionary *)playerSettings{
        
     return [[self alloc] initWithDictionary:playerSettings];    
}


#pragma mark -

-(void)initAnimations {
    
    id dao = [[GameManager sharedGameManager] dao];
    
    [self setManoDestraApre:[dao loadPlistForAnimationWithName:@"manoDestraApre" 
                                                   andClassName:name]];
    [self setManoDestraChiude:[dao loadPlistForAnimationWithName:@"manoDestraChiude" 
                                                     andClassName:name]];
    [self setManoSinistraApre:[dao loadPlistForAnimationWithName:@"manoSinistraApre" 
                                                     andClassName:name]];
    [self setManoSinistraChiude:[dao loadPlistForAnimationWithName:@"manoSinistraChiude"
                                                       andClassName:name]];
    [self setManoSinistraColpita:[dao loadPlistForAnimationWithName:@"manoSinistraColpita"
                                                        andClassName:name]];
    [self setManoDestraColpita:[dao loadPlistForAnimationWithName:@"manoDestraColpita"
                                                      andClassName:name]];
    [self setFeedBody:[dao loadPlistForAnimationWithName:@"bodyFeed"
                                             andClassName:name]];
    [self setManoDestraCrossApre:[dao loadPlistForAnimationWithName:@"manoDestraCrossApre"
                                                       andClassName:name]];
    [self setManoDestraCrossChiude:[dao loadPlistForAnimationWithName:@"manoDestraCrossChiude"
                                                         andClassName:name]];
    [self setManoSinistraCrossApre:[dao loadPlistForAnimationWithName:@"manoSinistraCrossApre" 
                                                         andClassName:name]];
    [self setManoSinistraCrossChiude:[dao loadPlistForAnimationWithName:@"manoSinistraCrossChiude"
                                                           andClassName:name]];
    [self setManoDestraCrossColpita:[dao loadPlistForAnimationWithName:@"manoDestraCrossColpita" 
                                                          andClassName:name]];
    [self setManoSinistraCrossColpita:[dao loadPlistForAnimationWithName:@"manoSinistraCrossColpita" 
                                                            andClassName:name]];
    [self setFeedBodyErr:[dao loadPlistForAnimationWithName:@"bodyFeedErr" 
                                               andClassName:name]];

}

#pragma mark -
-(id) initWithDictionary:(NSMutableDictionary*)playerSettings
{
    CCTexture2D* texture = [[CCTextureCache sharedTextureCache] addImage:[playerSettings objectForKey:@"texture"]];
        
    if( (self=[super initWithTexture:texture]))
{
        CCLOG(@"Inizializzazione Player");
        
        currentTime = 0;
        
        cnt = 1;
        
        self.gameObjectType = kObjectTypePlayer;
        
        isLastPlayer = [[GameManager sharedGameManager] isLastLevel];
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        [self setName:[playerSettings objectForKey:@"name"]];
        
        bpm = [[playerSettings objectForKey:@"bpm"] intValue];
        
        frameForDoubleTouch = (bpm == 180) ? 1 : 2;

        float positionX = 
        [[playerSettings objectForKey:@"positionX"] floatValue];
        
        float positionY =
        [[playerSettings objectForKey:@"positionY"]floatValue];
        
        float positionLeftX = 
        [[playerSettings objectForKey:@"leftPositionX"] floatValue];
        
        float positionLeftY = 
        [[playerSettings objectForKey:@"leftPositionY"] floatValue];
        
        float positionRightX = 
        [[playerSettings objectForKey:@"rightPositionX"] floatValue];
        
        float positionRightY = 
        [[playerSettings objectForKey:@"rightPositionY"] floatValue];
        
        float rectLeftPositionX = 
        [[playerSettings objectForKey:@"leftRectPositionX"]floatValue];
        
        float rectLeftPositionY = 
        [[playerSettings objectForKey:@"leftRectPositionY"]floatValue];
        
        float rectRightPositionX =
        [[playerSettings objectForKey:@"rightRectPositionX"]floatValue];
        
        float rectRightPositionY =
        [[playerSettings objectForKey:@"rightRectPositionY"]floatValue];
        
        float rectRightCrossPositionX = 
        [[playerSettings objectForKey:@"rightRectCrossPositionX"]floatValue];
        
        float rectRightCrossPositionY = 
        [[playerSettings objectForKey:@"rightRectCrossPositionY"]floatValue];
        
        float leftRectCrossPositionX = 
        [[playerSettings objectForKey:@"leftRectCrossPositionX"]floatValue];
        
        float leftRectCrossPositionY = 
        [[playerSettings objectForKey:@"leftRectCrossPositionY"]floatValue];
        
        rectLeft = CGRectMake(rectLeftPositionX/2, rectLeftPositionY/2, 80, 80);
        
        rectRight = CGRectMake(rectRightPositionX/2, rectRightPositionY/2, 80, 80); 
                
        rectLeftCross = CGRectMake(leftRectCrossPositionX/2, leftRectCrossPositionY/2, 80, 80);
        
        rectRightCross = CGRectMake(rectRightCrossPositionX/2, rectRightCrossPositionY/2, 80, 80);
        
        NSLog(@"Rect Cross Right: %@ \n Rect Cross Left: %@", NSStringFromCGRect(rectRightCross), NSStringFromCGRect(rectLeftCross));
                
        self.anchorPoint = CGPointMake(0.5, 0);
                
        self.position = CGPointMake(positionX/2, size.height - positionY/2);
                
        NSString* leftName = [playerSettings objectForKey:@"leftHand"];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:[NSString stringWithFormat:@"%@Left.plist",name]];
        
        _leftHandBatchNode = [CCSpriteBatchNode batchNodeWithFile:[NSString stringWithFormat:@"%@Left.png",name]];
        
        [self addChild:_leftHandBatchNode];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:[NSString stringWithFormat:@"%@Right.plist",name]];
        
        _rightHandBatchNode = [CCSpriteBatchNode batchNodeWithFile:[NSString stringWithFormat:@"%@Right.png",name]];
        
        [self addChild:_rightHandBatchNode];
        
        CCSprite* leftHand = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] 
                                                          spriteFrameByName:leftName]];
        
        leftHand.anchorPoint = CGPointMake(0, 0);

        leftHand.position = CGPointMake(positionLeftX/2 - self.position.x + (self.textureRect.size.width * self.anchorPoint.x), 
                                        size.height - positionLeftY/2);
        
        
        [_leftHandBatchNode addChild:leftHand z:kLeftHandZValue tag:kLeftHandTagValue];
                
        NSString* rightName = [playerSettings objectForKey:@"rightHand"];
        
        CCSprite* rightHand = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]
                                                     spriteFrameByName:rightName]];
        
        rightHand.anchorPoint = CGPointMake(0, 0);

        
        [rightHand setPosition:CGPointMake(positionRightX/2 - self.position.x + (self.textureRect.size.width * self.anchorPoint.x),
                                           size.height - positionRightY/2)];
        
        [_rightHandBatchNode addChild:rightHand z:kRightHandZValue tag:kRightHandTagValue];
    
        if (!isLastPlayer) {    
        
        [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:[NSString stringWithFormat:@"%@Player.plist",name]];
        
        _bodyBatchNode = [CCSpriteBatchNode batchNodeWithFile:[NSString stringWithFormat:@"%@Player.png",name]];
        
        [self addChild:_bodyBatchNode];
        
        }
    
        pattern = [[GameManager sharedGameManager] patternForLevel];
        
        [self initAnimations];
        
        [self setCharacterState:kStateNone];
        
        currentItem = -1;
                
        handIsOpen = FALSE;
        
        handsAreOpen = FALSE;
                        
        
    }
    return self;
}

- (void)dealloc {
    
    
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), self);

    
    [[CCSpriteFrameCache sharedSpriteFrameCache]removeSpriteFramesFromFile:[NSString stringWithFormat:@"%@Player.plist",name]];
    [[CCSpriteFrameCache sharedSpriteFrameCache]removeSpriteFramesFromFile:[NSString stringWithFormat:@"%@Left.plist",name]];
    [[CCSpriteFrameCache sharedSpriteFrameCache]removeSpriteFramesFromFile:[NSString stringWithFormat:@"%@Right.plist",name]];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
}

@end

