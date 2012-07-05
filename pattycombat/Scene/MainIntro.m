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


- (id)init
{
    self = [super init];
    if (self) {
        
        
        CGSize screenSize = [CCDirector sharedDirector].winSize;

        CCSprite* skip = [CCSprite spriteWithFile:@"skip.png"];
        CCSprite* skipSel = [CCSprite spriteWithFile:@"skip_tap.png"];
        
        CCMenuItemSprite* skipBtn = [CCMenuItemSprite itemWithNormalSprite:skip selectedSprite:skipSel block:^(id sender) {
            
            [self removeChildByTag:1 cleanup:YES];
            
            CCScene* scene = [LoadingScene sceneWithTargetScene:kMainMenuScene];
            
            [[GameManager sharedGameManager] stopBackgroundMusic];
            [[CCDirectorIOS sharedDirector]  replaceScene:scene];  
            
        }] ;
        
        [skipBtn setAnchorPoint:ccp(1, 1)];
        
        CCMenu* menu = [CCMenu menuWithItems:skipBtn, nil];
        
        [self addChild:menu z:1 tag:1];
        
        [menu setPosition:ccp(screenSize.width * 0.96f, screenSize.height * .97f)];
        
        [menu setAnchorPoint:ccp(1, 1)];
        
        [[GameManager sharedGameManager] playBackgroundTrack:BACKGROUND_TRACK_MAIN_MENU];
        
        [self updateForScreenReshape];
            
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
    
    CCMoveTo* moveTo = [CCMoveTo actionWithDuration:0.2f position:ccp(screenSize.width/2, screenSize.height * 0.10f)];
    CCMoveTo* move   = [CCMoveTo actionWithDuration:.1f position:arrow.position];
    
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
                   
                    CCScene* scene = [LoadingScene sceneWithTargetScene:kMainMenuScene];
                    
                    [[GameManager sharedGameManager] stopBackgroundMusic];
                    [[CCDirectorIOS sharedDirector]  replaceScene:scene];
                    
                }];
                
                CCMenu* menu = [CCMenu menuWithItems:button, nil];
                
                menu.position = ccp(screenSize.width/2 * 0.975f, screenSize.height/2 * 0.55f);
                [pageFive addChild:menu];
            }
        }
            break;
        case 4:
        default:
            break;
    }
}

- (void)dealloc
{
    
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
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
    
    [[CCDirectorIOS sharedDirector] replaceScene:[MainIntro node]];
    
}

- (void)dealloc
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
}
@end
