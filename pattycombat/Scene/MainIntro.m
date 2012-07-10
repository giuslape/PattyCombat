//
//  MainIntro.m
//  pattycombat
//
//  Created by Vincenzo Lapenta on 14/06/12.
//  Copyright (c) 2012 Fratello. All rights reserved.
//

#import "MainIntro.h"
#import "Constant.h"
#import "LoadingScene.h"
#import "GameManager.h"

@interface MainIntro(MainIntroCreation)

-(NSArray *)scrollLayerPage;
-(CCScrollLayer *)scrollLayer;
-(void)updateForScreenReshape;

@end

@implementation MainIntro

bool fadingOutLoop1;
bool fadingOutLoop2;

- (id)init
{
    self = [super init];
    
    if (self) {
        
        CGSize screenSize = [CCDirector sharedDirector].winSize;

        CCSprite* skip = [CCSprite spriteWithFile:@"skip.png"];
        CCSprite* skipSel = [CCSprite spriteWithFile:@"skip_tap.png"];
        
        CCMenuItemSprite* skipBtn = [CCMenuItemSprite itemWithNormalSprite:skip selectedSprite:skipSel block:^(id sender) {
            
            [self removeChildByTag:1 cleanup:YES];
            
            [[[CCDirector sharedDirector] actionManager] removeAllActionsFromTarget:sound1];                  
            [[[CCDirector sharedDirector] actionManager] removeAllActionsFromTarget:sound2];
          //  [[SimpleAudioEngine sharedEngine] unloadEffect:@"loop_sinth.mp3"];
          //  [[SimpleAudioEngine sharedEngine] unloadEffect:@"loop_metronomo.mp3"];
            [sound1 stop];
            [sound2 stop];
            
            CCScene* scene = [LoadingScene sceneWithTargetScene:kMainMenuScene];
            
            [[CCDirectorIOS sharedDirector]  replaceScene:scene];  
            
        }] ;
        
        [skipBtn setAnchorPoint:ccp(1, 1)];
        
        CCMenu* menu = [CCMenu menuWithItems:skipBtn, nil];
        
        [self addChild:menu z:1 tag:1];
        
        [menu setPosition:ccp(screenSize.width * 0.96f, screenSize.height * .97f)];
        
        [menu setAnchorPoint:ccp(1, 1)];
                
        [self updateForScreenReshape];
        
        sound1 = [[SimpleAudioEngine sharedEngine] soundSourceForFile:@"loop_sinth.mp3"];
        sound2 = [[SimpleAudioEngine sharedEngine] soundSourceForFile:@"loop_metronomo.mp3"];
        
        fadingOutLoop1 = YES;
        fadingOutLoop2 = YES;
        sound1.gain = 0.0f;
        sound2.gain = 0.0f;
        
        [self fadeSound:sound1];
    }
    return self;
}

- (void) updateForScreenReshape
{
	
	// ReCreate Scroll Layer for each Screen Reshape (slow, but easy).
	CCScrollLayer *scrollLayer = (CCScrollLayer *)[self getChildByTag:kScrollLayer];
	if (scrollLayer)
	{
		[self removeChild:scrollLayer cleanup:YES];
	}
	
	scrollLayer = [self scrollLayer];
	[self addChild: scrollLayer z: 0 tag: kScrollLayer];
	[scrollLayer selectPage: 0];
    
    scrollLayer.delegate = self;
}

#pragma mark ScrollLayer Creation

// Returns array of CCLayers - pages for ScrollLayer.
- (NSArray *) scrollLayerPages
{
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	
	// PAGE 1
	CCLayer *pageOne = [CCLayer node];
	CCSprite *s1 = [CCSprite spriteWithFile:@"001.png"];
	s1.position =  ccp( screenSize.width /2 , screenSize.height/2 );
    [pageOne addChild:s1];

    CCSprite* arrow = [CCSprite spriteWithFile:@"arrow.png"];
    arrow.position = ccp(screenSize.width /2, screenSize.height * 0.05f);
    
    CCMoveTo* moveTo = [CCMoveTo actionWithDuration:.21f position:ccp(screenSize.width/2, screenSize.height * 0.10f)];
    CCMoveTo* move   = [CCMoveTo actionWithDuration:.21f position:arrow.position];
    
    CCDelayTime* delay = [CCDelayTime actionWithDuration:.2f];
    
    CCRepeatForever* repeat = [CCRepeatForever actionWithAction:[CCSequence actions:moveTo,move,delay,nil]];
    
    [pageOne addChild:arrow];
    [arrow runAction:repeat];
	
	// PAGE 2 
	CCLayer *pageTwo = [CCLayer node];
	CCSprite *s2 = [CCSprite spriteWithFile:@"002.png"];
	s2.position =  ccp( screenSize.width /2 , screenSize.height/2 );
	[pageTwo addChild:s2];
    
    
	return [NSArray arrayWithObjects: pageOne,pageTwo,nil];
}

// Creates new Scroll Layer with pages returned from scrollLayerPages.
- (CCScrollLayer *) scrollLayer
{
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	
	// Create the scroller and pass-in the pages (set widthOffset to 0 for fullscreen pages).
	CCScrollLayer *scroller = [CCScrollLayer nodeWithLayers: [self scrollLayerPages] heightOffset: 0 ];
    
    // New feature: margin offset - to slowdown scrollLayer when scrolling out of it contents.
    // Comment this line or change marginOffset to screenSize.height to disable this effect.
    scroller.marginOffset =  screenSize.height;
	
    
    scroller.showPagesIndicator = false;
    
	return scroller;
}


#pragma mark -
#pragma mark ===  Scroll Layer Delegate Methods  ===
#pragma mark -


-(void)scrollLayer:(CCScrollLayer *)sender scrolledToPageNumber:(int)page{
    
    CGSize screenSize = [CCDirectorIOS sharedDirector].winSize;

    switch (page) {
        case 0:
            if (sound2.isPlaying) [self fadeSound:sound2];
            break;
        case 1:
        {
            if ([[sender pages] count] == 2) {

                // PAGE 3
                CCLayer *pageThree = [CCLayer node];
                CCSprite *s3 = [CCSprite spriteWithFile:@"003.png"];
                s3.position =  ccp( screenSize.width /2 , screenSize.height/2 );
                [pageThree addChild:s3];
                [sender addPage:pageThree withNumber:2];
            }
            if (!sound2.isPlaying)[self fadeSound:sound2];
        }
            break;
        case 2:
        {
            if ([[sender pages] count] == 3) {

                // PAGE 4
                CCLayer *pageFour= [CCLayer node];
                CCSprite *s4 = [CCSprite spriteWithFile:@"004.png"];
                s4.position =  ccp( screenSize.width /2 , screenSize.height/2 );
                [pageFour addChild:s4];
            
                [sender addPage:pageFour withNumber:3];
            }
            if (!sound2.isPlaying)[self fadeSound:sound2];
            if (!sound1.isPlaying)[self fadeSound:sound1];
        }
            break;
        case 3:
        {
            if ([[sender pages] count] == 4) {

                // PAGE 5 
                CCLayer *pageFive = [CCLayer node];
                CCSprite *s5 = [CCSprite spriteWithFile:@"005.png"];
                s5.position =  ccp( screenSize.width /2 , screenSize.height/2 );
                [pageFive addChild:s5];
                [sender addPage:pageFive withNumber:4];
                
                CCSprite* start = [CCSprite spriteWithFile:@"start.png"];
                CCSprite* start_over = [CCSprite spriteWithFile:@"start_over.png"];
                
                CCMenuItemSprite* button = [CCMenuItemSprite itemWithNormalSprite:start selectedSprite:start_over block:^(id sender) {
                   
                    [[[CCDirector sharedDirector] actionManager] removeAllActionsFromTarget:sound1];                  
                    [[[CCDirector sharedDirector] actionManager] removeAllActionsFromTarget:sound2];
                    [sound1 stop];
                    [sound2 stop];
                    
                    CCScene* scene = [LoadingScene sceneWithTargetScene:kMainMenuScene];
                    
                    [[CCDirectorIOS sharedDirector]  replaceScene:scene];
                    
                }];
                                
                CCMenu* menu = [CCMenu menuWithItems:button, nil];
                menu.position = ccp(screenSize.width/2 * 0.975f, screenSize.height/2 * 0.55f);
                [pageFive addChild:menu];
            }
            
            if (sound2.isPlaying) [self fadeSound:sound2];
            if (!sound1.isPlaying)[self fadeSound:sound1];
        }
            break;
        case 4:
            if (sound1.isPlaying) [self fadeSound:sound1];
            if (sound2.isPlaying) [self fadeSound:sound2];
            break;
        default:
            break;
    }
}

- (void)dealloc
{
    
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
}


-(void)fadeSound:(CDSoundSource *)sender{
    
    CCDirector* director = [CCDirector sharedDirector];
    
    [[director actionManager] removeAllActionsFromTarget:sender];
    
    if ([sender isEqual:sound1]) {
        
    
        if (!fadingOutLoop1) {
        
            [CDXPropertyModifierAction fadeSoundEffect:1.0f finalVolume:0.0f curveType:kIT_Linear shouldStop:YES effect:sender]; 
            }else {
        
                sender.looping = YES;
                [sender play];
                [CDXPropertyModifierAction fadeSoundEffect:1.0f finalVolume:1.0f curveType:kIT_Linear shouldStop:NO effect:sender];
         }
    
    fadingOutLoop1 = !fadingOutLoop1;
    }
    
    if ([sender isEqual:sound2]) {
        
        
        if (!fadingOutLoop2) {
            
            [CDXPropertyModifierAction fadeSoundEffect:0.5f finalVolume:0.0f curveType:kIT_Linear shouldStop:YES effect:sender]; 
        }else {
            
            sender.looping = YES;
            [sender play];
            [CDXPropertyModifierAction fadeSoundEffect:0.5f finalVolume:1.0f curveType:kIT_Linear shouldStop:NO effect:sender];
        }
        
        fadingOutLoop2 = !fadingOutLoop2;
    }

}


@end


@interface GinoScappelloni ()

-(void)changeScene;

@end


@implementation GinoScappelloni


- (id)init
{
    self = [super init];
    if (self) {
        
        CGSize size = [CCDirectorIOS sharedDirector].winSize;
        
        CCSprite* gino = [CCSprite spriteWithFile:@"gameApproved.png"];
        
        [self addChild:gino];
        
        [gino setOpacity:0.0f];
                
        gino.position = ccp(size.width/2, size.height/2);
        
        [gino runAction:[CCFadeIn actionWithDuration:0.3f]];
        
        [self scheduleOnce:@selector(changeScene) delay:3];
        
    }
    return self;
}

-(void)changeScene{
    
    [[GameManager sharedGameManager] runSceneWithID:kGameMainIntro];    
}

- (void)dealloc
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
}
@end
