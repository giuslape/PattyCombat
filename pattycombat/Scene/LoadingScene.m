//
//  LoadingScene.m
//  pattycombat
//
//  Created by Giuseppe Lapenta on 10/04/12.
//  Copyright (c) 2012 Fratello. All rights reserved.
//

#import "LoadingScene.h"
#import "GameManager.h"

@interface LoadingScene ()

@property (nonatomic, strong)NSMutableArray* feedHand;

-(void) loadScene:(ccTime)delta;
-(void) feedPattern;
-(void)alignHandsWithPadding:(float)padding;

@end

@implementation LoadingScene

@synthesize feedHand;


+(id)sceneWithTargetScene:(SceneTypes)targetScene;
{
	CCLOG(@"===========================================");
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    return [[self alloc] initWithTargetScene:targetScene];
	
}

-(id)initWithTargetScene:(SceneTypes)targetScene
{
	if ((self = [super init]))
	{
		_scene = targetScene;
        
		CCLabelBMFont* loading = [CCLabelBMFont labelWithString:@"Loading..." fntFile:FONTHIGHSCORES];
		
		[self addChild:loading z:1 tag:1];
		
        [self scheduleOnce:@selector(loadScene:) delay:0.1];
        
        [loading setPosition:ccp(-loading.contentSize.width, -loading.contentSize.height)];
        
	}
	
	return self;
}


-(void)loadScene:(ccTime)delta
{	
    CCLabelBMFont* loading = (CCLabelBMFont *)[self getChildByTag:1];

    CGSize size = [[CCDirector sharedDirector] winSize];
    
    switch (_scene) {
        case kIntroScene:
            break;
        case kGamelevel1:
        {
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"IntroButtAndFeed.plist"];
            
            _spriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"IntroButtAndFeed.png"];
            
            [self addChild:_spriteBatchNode z:kSpriteBatchNodeIntroZValue tag:kSpriteBatchNodeIntroTagValue];
            
            [self feedPattern];
            
            [self scheduleOnce:@selector(changeScene:) delay:2];
            
            loading.position = CGPointMake(size.width / 2, size.height * 0.6f);

        }
            break;
            
        case kMainMenuScene:{
            
            CGSize size = [[CCDirector sharedDirector] winSize];
                        
            [loading setPosition:ccp(size.width /2, size.height /2)];
            
            [self scheduleOnce:@selector(changeScene:) delay:0.4f];
            
        }
        
        break;
        default:
            NSAssert2(nil, @"%@: unsupported TargetScene %i",
                      NSStringFromSelector(_cmd), _scene);
            break;
    }
}

-(void)changeScene:(ccTime)delta{
    
    [[GameManager sharedGameManager] runSceneWithID:_scene];
    
}

-(void)feedPattern{
    
    id gameManager = [GameManager sharedGameManager];
    
    float padding = 2;
    
    feedHand = [[NSMutableArray alloc] init];       
    
    
    //Load Pattern for current Level
    
    NSMutableArray* patternArray = [[NSMutableArray alloc] initWithArray:[gameManager patternForLevel]];
    
    // Insert each item of PatternArray in feedHand array with check if is dx, sx or two
    
    for (NSString* hand in patternArray) {
        
        CCSprite* handSprite = nil;
        
        if ([hand isEqualToString:@"dx"] || [hand isEqualToString:@"dxCross"]) {
            
            handSprite = [CCSprite spriteWithSpriteFrame: 
                          [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"intro_feed_dx_02.png"]];
            
            [handSprite setTag:kHandFeedRightTagValue];
            
        }else if([hand isEqualToString:@"sx"] || [hand isEqualToString:@"sxCross"]){
            
            handSprite = [CCSprite spriteWithSpriteFrame:
                          [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"intro_feed_sx_02.png"]];
            
            
            [handSprite setTag:kHandFeedLeftTagValue];
            
        }else if([hand isEqualToString:@"two"]){
            
            handSprite = [CCSprite spriteWithSpriteFrame: 
                          [[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"intro_feed_both_02.png"]];
            
            
            [handSprite setTag:kHandFeedBothTagValue];
            
        }else CCLOG(@"Pattern non riconosciuto");
        
        
        if (handSprite != nil)[feedHand addObject:handSprite];
    }
    
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
        [item setPosition:ccp(x + itemSize.width * item.scaleX / 2.0f, size.height * 0.5f - itemSize.height * item.scaleY /2.0f)];
        x += itemSize.width * item.scaleX + padding;
    }
    
    
}



#pragma mark -
#pragma mark ===  Dealloc  ===
#pragma mark -

- (void)dealloc
{
    _spriteBatchNode = nil;
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"IntroButtAndFeed.plist"];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
}



@end
