//
//  Bell.m
//  PattyCombat
//
//  Created by Giuseppe Lapenta on 08/10/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import "Bell.h"
#import "GameManager.h"

@interface Bell ()

    @property (readwrite)float elapsedTime;
    @property (readwrite)float currentFrame;
    @property (readwrite)float delayBetweenFrames;
    @property (readwrite)float oldElapsedTime;
    @property (readwrite)float gameTime;
    @property (readwrite)BOOL  isBonusLevel;

@end

@implementation Bell

@synthesize bellAnimation = _bellAnimation;
@synthesize gongAnimation = _gongAnimation;
@synthesize elapsedTime, currentFrame, delayBetweenFrames,oldElapsedTime;
@synthesize isBonusLevel;
@synthesize gameTime;
@synthesize delegate = _delegate;

- (void)dealloc 
{
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    [[CCTextureCache sharedTextureCache]         removeUnusedTextures];
}


-(void)changeState:(NSNumber *)newState
{
    
    CharacterStates state = (CharacterStates)[newState intValue];
    id action = nil;
    id changeCharacter = nil;
    id sequence = nil;
    [self setCharacterState:state];
    
    switch (state) {
            
        case kStateBellUpdate:
        {
            [self setDisplayFrame:[[[_bellAnimation frames]objectAtIndex:currentFrame]spriteFrame]];
            currentFrame = currentFrame+1 % [[_bellAnimation frames] count];
            
            break;
        }
        case kStateBellGong:
        {
            PLAYSOUNDEFFECT(BELL);
            changeCharacter = [CCCallBlock actionWithBlock:
                            (^{
                
                            [self setCharacterState:kStateBellFinish]; 
                            [_delegate bellDidFinish:self];
                
            })];
            action = [CCAnimate actionWithAnimation:_gongAnimation];
            sequence =[CCSequence actionOne:changeCharacter two:action];

            break;
        }
        case kStateBellStart:
            
            [self setDisplayFrame:[[[_bellAnimation frames]lastObject] spriteFrame]];
            [self changeState:[NSNumber numberWithInt:kStateBellGong]];
            break;
            
        default:{
            CCLOG(@"Unhandled state %d in Bell", state);
            break;}
    }
    if (action != nil) {
        
        [self runAction:sequence];

    }
}

-(void)updateStateWithDeltaTime:(ccTime)deltaTime
{
    
    if ([self characterState] == kStateBellFinish) return;
    
    
    elapsedTime += deltaTime;
    
    float diff = elapsedTime - oldElapsedTime;
    
    if (diff >= delayBetweenFrames) {
        
        [self changeState:[NSNumber numberWithInt:kStateBellUpdate]];
        oldElapsedTime = elapsedTime;

    }
    else if (elapsedTime >= gameTime &&
             [self isFrameDisplayed:[[_bellAnimation frames] lastObject]]) 
    {
        
        [self changeState:[NSNumber numberWithInt:kStateBellGong]];
        
    }
        
            
}


-(void)initAnimations
{
    
    [self setBellAnimation:
        [[[GameManager sharedGameManager]dao] loadPlistForAnimationWithName:@"bellAnimation" andClassName:NSStringFromClass([self class])]];
    
    [self setGongAnimation:
        [[[GameManager sharedGameManager]dao] loadPlistForAnimationWithName:@"gongAnimation" andClassName:NSStringFromClass([self class])]];
}

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
    
    if( (self=[super initWithTexture:texture rect:rect]))
        
    {
        
        self.gameObjectType = kObjectTypeBell;
        [self initAnimations];
        elapsedTime = 0;
        currentFrame = 0;
        oldElapsedTime = 0;
        isBonusLevel = [[GameManager sharedGameManager] isBonusLevel];
        gameTime = (isBonusLevel) ? GAMETIMEBONUSLEVEL : GAMETIME;
        delayBetweenFrames = (float)gameTime /[[_bellAnimation frames] count];

        
    }
    return self;
}




@end
