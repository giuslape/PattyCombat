//
//  FinalSceneLayer.m
//  pattycombat
//
//  Created by Vincenzo Lapenta on 12/04/12.
//  Copyright (c) 2012 Fratello. All rights reserved.
//

#import "FinalSceneLayer.h"

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
        
    }
    return self;
}


#pragma mark -
#pragma mark ===  Show Dark Layer  ===
#pragma mark -

-(void)showDarkLayer:(ccTime)delta{
    
    CCLayerColor* layerColor = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 0)];
    
    [self addChild:layerColor];
    
    CCFadeTo* fade = [CCFadeTo actionWithDuration:0.5f opacity:180];
    
    [layerColor runAction:fade];
    
}

#pragma mark -
#pragma mark ===  Touch Handler  ===
#pragma mark -


-(void) registerWithTouchDispatcher
{
    [[[CCDirectorIOS sharedDirector] touchDispatcher] addTargetedDelegate:self priority:-1 swallowsTouches:YES];
    
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    return YES;
}


@end
