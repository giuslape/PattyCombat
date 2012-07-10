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

@implementation FinalSceneLayer


#pragma mark -
#pragma mark ===  Init Methods  ===
#pragma mark -


- (id)init
{
    self = [super init];
    
    if (self) {
        
        CGSize size = [[CCDirectorIOS sharedDirector] winSize];
        
        CCSprite* background = [CCSprite spriteWithFile:@"end.png"];
                
        [self addChild:background];
        
        [background setPosition:ccp(size.width/2, size.height/2)];
                        
        [self scheduleOnce:@selector(showDarkLayer:) delay:2];
        
        if(![[GameManager sharedGameManager] isExtreme]){
            
            [[GameManager sharedGameManager] setIsExtreme:YES];
        }
                
    }
    return self;
}


-(void)onEnterTransitionDidFinish{
    
    
    [[GameManager sharedGameManager] playBackgroundTrack:BACKGROUND_TRACK_MAIN_MENU];
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
    
    CCScene* scene = [LoadingScene sceneWithTargetScene:kMainMenuScene];
    
    [[CCDirectorIOS sharedDirector] replaceScene:scene];
}


@end
