//
//  FinalSceneLayer.m
//  pattycombat
//
//  Created by Vincenzo Lapenta on 12/04/12.
//  Copyright (c) 2012 Fratello. All rights reserved.
//

#import "FinalSceneLayer.h"
#import "GameManager.h"
#import "LoadingScene.h"


static int labelIdx=-1;
static int touchCount=-1;
static NSString *transitions[] = {
    @"Finally you won",
    @"At the award ceremony,\n the crowd can be heard whispering",
    @"Already seeking the next challenge",
    @"Ceremony means nothing to you",
    @"The Fight is everything",
    @"Game Over"
};

NSString* nextLabel(void);

NSString *nextLabel()
{
    labelIdx++;
    int total = ( sizeof(transitions) / sizeof(transitions[0]) );
    
    if (labelIdx == total) {
        labelIdx = 0;
    }
    NSString* r= transitions[labelIdx];
	    return r;
}

@implementation FinalSceneLayer

#define ComicInterval 2

#pragma mark -
#pragma mark ===  Init Methods  ===
#pragma mark -


- (id)init
{
    self = [super init];
    
    if (self) {
                
        size = [[CCDirectorIOS sharedDirector] winSize];
        
        CCSprite* background = [CCSprite spriteWithFile:@"finale_bg.png"];
                
        [self addChild:background];
        
        [background setPosition:ccp(size.width/2, size.height/2)];
                        
      //  [self scheduleOnce:@selector(showDarkLayer:) delay:2];
        
        if(![[GameManager sharedGameManager] isExtreme])
            [[GameManager sharedGameManager] setIsExtreme:YES];
                
        _text = [CCLabelBMFont labelWithString:nil fntFile:FONTFEEDBACK];
        
        [self addChild:_text];
        
        _text.position = ccp(size.width/2, size.height * 0.9f);
        _text.opacity = 0;
        
      //  [self scheduleOnce:@selector(fadeLabel) delay:1.0f];
        
        self.isTouchEnabled = YES;
        
        cloud1 = [CCSprite new];
        cloud2 = [CCSprite new];
        
        [self scheduleOnce:@selector(handleComics) delay:1.0f]; 

    }
    return self;
}


-(void)onEnterTransitionDidFinish{
    
    
    [[GameManager sharedGameManager] playBackgroundTrack:FINAL_THEME];
    
}

#pragma mark -
#pragma mark ===  Show Dark Layer  ===
#pragma mark -

-(void)showDarkLayer:(ccTime)delta{
    
    CreditsLayer* layerColor = [CreditsLayer layerWithColor:ccc4(0, 0, 0, 0)];
    
    [self addChild:layerColor];
    
    [layerColor setDelegate:self];
    
    CCFadeTo* fade = [CCFadeTo actionWithDuration:0.5f opacity:180];
    
    [layerColor runAction:fade];
    
}


#pragma mark -
#pragma mark ===  Credits Layer Protocol  ===
#pragma mark -

-(void)creditsLayerDidClose:(CreditsLayer *)layer{
    
    [self removeChild:layer cleanup:YES];
    
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    
    CCScene* scene = [LoadingScene sceneWithTargetScene:kMainMenuScene];
    
    [[CCDirectorIOS sharedDirector] replaceScene:scene];
    
}


#pragma mark -
#pragma mark ===  Fade Label  ===
#pragma mark -



-(void)fadeLabel{
    
    CCCallBlock* block = [CCCallBlock actionWithBlock:^{
        
        [_text setString:nextLabel()];

    }];
    CCActionInterval* fadeIn = [CCFadeIn actionWithDuration:0.3f];
    CCDelayTime* d1 = [CCDelayTime actionWithDuration:1];
    CCActionInterval* fadeOut = [fadeIn reverse];
    
    [_text runAction:[CCSequence actions:fadeOut,d1,block,fadeIn, nil]];
}

#pragma mark -
#pragma mark ===  Touch Handler  ===
#pragma mark -

-(void) registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector]touchDispatcher] addTargetedDelegate:self priority:-1 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch*)touch withEvent:(UIEvent *)event
{
   
    if ([_text numberOfRunningActions] == 0) {
        
        [self handleComics];
        return YES;
    }    
    return YES;
}

-(void)handleComics{
    
    touchCount++;
	touchCount = touchCount%(11);
    switch (touchCount) {
        case 0:
            [self fadeLabel];
            break;
        case 1:
            [self fadeLabel];
            break;
        case 2:
            cloud1 = [CCSprite spriteWithFile:@"finale_malinconico_01.png"];
            [self addChild:cloud1];
            [cloud1 setPosition:ccp(size.width * 0.23f, size.height* 0.68f)];
            break;
        case 3:
            cloud2 = [CCSprite spriteWithFile:@"finale_malinconico_02.png"];
            [self addChild:cloud2];
            [cloud2 setPosition:ccp(size.width * 0.2f, size.height * 0.38f)];
            break;
        case 4:
            [self fadeLabel];
            [self removeChild:cloud1 cleanup:YES];
            [self removeChild:cloud2 cleanup:YES];
            break;
        case 5:
            [self fadeLabel];
            break;
        case 6:
            [self fadeLabel];
            break;
        case 7:
            [_text setString:@""];
            break;
        case 8:
            cloud1 = [CCSprite spriteWithFile:@"finale_malinconico_03.png"];
            [self addChild:cloud1];
            [cloud1 setPosition:ccp(size.width * 0.70f, size.height * 0.85f)];
            break;
        case 9:
            [self fadeLabel];
            [self removeChild:cloud1 cleanup:YES];
            cloud1 = [CCSprite spriteWithFile:@"finale_malinconico_04.png"];
            [self addChild:cloud1];
            [cloud1 setPosition:ccp(size.width * 0.51f, size.height * 0.02f)];
            break;
        case 10:
            self.isTouchEnabled = NO;
            [self showDarkLayer:0];
            break;
        default:
            break;
    }
    
}


@end
