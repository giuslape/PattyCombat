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
		CGSize size = [[CCDirector sharedDirector] winSize];
		loading.position = CGPointMake(size.width / 2, size.height * 0.6f);
		[self addChild:loading z:1 tag:1];
		
        [self scheduleOnce:@selector(loadScene:) delay:0.1];
	}
	
	return self;
}


-(void)loadScene:(ccTime)delta
{	
    switch (_scene) {
        case kIntroScene:
            break;
        case kGamelevel1:
        {
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"IntroButtAndFeed.plist"];
            
            _spriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"IntroButtAndFeed.png"];
            
            [self addChild:_spriteBatchNode z:kSpriteBatchNodeIntroZValue tag:kSpriteBatchNodeIntroTagValue];
            
            [self feedPattern];
            
            [self scheduleOnce:@selector(changeScene:) delay:4];

        }
            break;
        case kMainMenuScene:{
            
            CGSize size = [[CCDirector sharedDirector] winSize];
            
            CCLabelBMFont* loading = (CCLabelBMFont *)[self getChildByTag:1];
            
            [loading setPosition:ccp(size.width /2, size.height /2)];
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
    
    NSArray* patternArray = [[NSArray alloc] initWithArray:[gameManager patternForLevel]];
    
    // Insert each item of PatternArray in feedHand array with check if is dx, sx or two
    
    for (NSString* hand in patternArray) {
        
        CCSprite* handSprite = nil;
        CCSprite* twoHandSprite = nil;
        CCSprite* arrow = nil;
        
        if ([hand isEqualToString:@"dx"] || [hand isEqualToString:@"dxCross"]) {
            
            handSprite = [CCSprite spriteWithSpriteFrame: 
                          [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"intro_feed_dx_01.png"]];
            
            [handSprite setTag:kHandFeedRightTagValue];
            
        }else if([hand isEqualToString:@"sx"] || [hand isEqualToString:@"sxCross"]){
            
            handSprite = [CCSprite spriteWithSpriteFrame:
                          [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"intro_feed_sx_01.png"]];
            
            
            [handSprite setTag:kHandFeedLeftTagValue];
            
        }else if([hand isEqualToString:@"two"]){
            
            handSprite = [CCSprite spriteWithSpriteFrame: 
                          [[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"intro_feed_dx_01.png"]];
            twoHandSprite = [CCSprite spriteWithSpriteFrame: 
                             [[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"intro_feed_sx_01.png"]];
            
            
            [handSprite setTag:kHandFeedRightTagValue];
            [twoHandSprite setTag:kHandFeedLeftTagValue];
            
        }else CCLOG(@"Pattern non riconosciuto");
        
        
        if (handSprite != nil && twoHandSprite != nil) {
            
            arrow = [CCSprite spriteWithSpriteFrame: 
                     [[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"intro_feed_arrow.png"]];
            
            [arrow setTag:kArrowFeedTagValue];
            
            [feedHand addObject:handSprite];
            [feedHand addObject:twoHandSprite];
            [feedHand addObject:arrow];
            
        }else if (handSprite != nil) {
            
            arrow = [CCSprite spriteWithSpriteFrame: 
                     [[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"intro_feed_arrow.png"]];
            
            [arrow setTag:kArrowFeedTagValue];
            
            [feedHand addObject:handSprite];
            [feedHand addObject:arrow];
        }
        
    } 
    [feedHand removeLastObject];
    
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
}



@end
