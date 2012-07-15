//
//  Bell.m
//  PattyCombat
//
//  Created by Giuseppe Lapenta on 08/10/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import "Bell.h"
#import "GameManager.h"

@implementation Bell

@synthesize bellAnimation = _bellAnimation;
@synthesize gongAnimation = _gongAnimation;
@synthesize delegate = _delegate;

- (void)dealloc 
{
    _delegate = nil;
    NSLog(@"%@", NSStringFromSelector(_cmd)); 
}


-(void)changeState:(NSNumber *)newState
{
    
    BellStates state = (BellStates)[newState intValue];
    id action = nil;
    id changeCharacter = nil;
    id sequence = nil;
    [self setCharacterState:state];
    
    switch (state) {
          
        case kStateBellStart: 
            PLAYSOUNDEFFECT(BELL);
            action = [CCAnimate actionWithAnimation:_gongAnimation];
            break;
      
        case kStateBellUpdate:
        
            [self setDisplayFrame:[[[_bellAnimation frames]objectAtIndex:_currentFrame]spriteFrame]];
            _currentFrame = _currentFrame+1 % [[_bellAnimation frames] count];
            
            break;
        
        case kStateBellGongFinish:{
            PLAYSOUNDEFFECT(BELL);
            changeCharacter = [CCCallBlock actionWithBlock:
                            (^{
                
                            [self setCharacterState:kStateBellFinish]; 
                            [_delegate bellDidFinishTime:self];
        
            })];
            action = [CCAnimate actionWithAnimation:_gongAnimation];
            sequence =[CCSequence actionOne:changeCharacter two:action];
            break;
        }
        default:
            CCLOG(@"Unhandled state %d in Bell", state);
            break;
    }
    
    if (sequence != nil) [self runAction:sequence];
    else if (action != nil) [self runAction:action];

    
}

-(void)updateStateWithDeltaTime:(ccTime)deltaTime
{
    
    if ([self characterState] == kStateBellFinish) return;
    
    // init scheduler
    
    if (_elapsedTime == 0) {
        
        //[self changeState:[NSNumber numberWithInt:kStateBellStart]];
    }
    
    // Check how time is elapsed
    
    _elapsedTime += deltaTime;
    
    float diff = deltaTime - _oldElapsedTime;
    
    if (diff >= _delayBetweenFrames) {
        
        [self changeState:[NSNumber numberWithInt:kStateBellUpdate]];
        _oldElapsedTime = deltaTime;

    }
    else if (deltaTime >= _gameTime &&
             [self isFrameDisplayed:[[[_bellAnimation frames] lastObject]spriteFrame]]) 
    {
        
        [self changeState:[NSNumber numberWithInt:kStateBellGongFinish]];
        
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
        _elapsedTime = 0;
        _currentFrame = 0;
        _oldElapsedTime = 0;
        int gameTimeForLevel = [[GameManager sharedGameManager] gameTime];
        _isBonusLevel = [[GameManager sharedGameManager] isBonusLevel];
        _gameTime = (_isBonusLevel) ? GAMETIMEBONUSLEVEL : gameTimeForLevel;
        _delayBetweenFrames = (float)_gameTime /[[_bellAnimation frames] count];
    }
    return self;
}




@end
