//
//  TvGamePlayLayer.m
//  pattycombat
//
//  Created by Giuseppe Lapenta on 18/04/12.
//  Copyright 2012. All rights reserved.
//

#import "TvGamePlayLayer.h"
#import "GameManager.h"
#import "GameCharacter.h"

@implementation TvGamePlayLayer

#pragma mark -
#pragma mark ===  Init Methods  ===
#pragma mark -


-(void)initAnimation{
    
    CCAnimation* tempAnimation = [CCAnimation animation];
    
    
    for (int i = 1; i<=4; i++) {
        
        [tempAnimation addSpriteFrameWithFilename:[NSString stringWithFormat:@"tv_touch_000%d.png",i]];
    }
    
    [self setTouchAnimation:tempAnimation];
    [touchAnimation setDelayPerUnit:0.08];
    
    
}

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        size = [[CCDirector sharedDirector] winSize];
        
      //  [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
        CCSprite* tv = [CCSprite spriteWithFile:@"tv_0001.png"];
        
        [self addChild:tv z:kTvZValue tag:kTvTagValue];
        
        [tv setPosition:ccp(473/2, size.height - 322/2)];
        
        [self initAnimation];
        
       // [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        
    }
    return self;
}

-(CGRect)adjustBoundingBox{
    
    CCSprite* tv = (CCSprite *)[self getChildByTag:kTvTagValue];
    
    CGRect tvBoundingBox = [tv boundingBox];
    
    NSLog(@"===============================");
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), NSStringFromCGRect(tvBoundingBox));

    float yCropAmount;
    
    switch (indexSprite) {
        case 1:
            yCropAmount = tvBoundingBox.size.height*0.17f;
            break;
        case 2:
            yCropAmount = tvBoundingBox.size.height*0.17f;
            break;
        case 3:
            yCropAmount = tvBoundingBox.size.height*0.17;
            break;
        case 4:
            yCropAmount = tvBoundingBox.size.height*0.43;
            break;
        case 5:
            yCropAmount = tvBoundingBox.size.height*0.71;
            break;
        case 6:
            yCropAmount = tvBoundingBox.size.height;
            break;
        default:
            yCropAmount = tvBoundingBox.size.height;
            break;
    }
    
    tvBoundingBox = CGRectMake(tvBoundingBox.origin.x, tvBoundingBox.origin.y, tvBoundingBox.size.width - 40, tvBoundingBox.size.height - yCropAmount);
    
    
    return tvBoundingBox;
    
    
}


-(void) registerWithTouchDispatcher
{
    [[[CCDirectorIOS sharedDirector] touchDispatcher] addTargetedDelegate:self priority:-1
     
                                                          swallowsTouches:YES];
}


-(BOOL) ccTouchBegan:(UITouch*)touch withEvent:(UIEvent *)event
{
    
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector]convertToGL:location];
    
    CGRect myBoundingBox = [self adjustBoundingBox];
    
    if (isFinish){
        
        scoreUp = totalScore + score - 1;
        return YES;
    }

    if (CGRectContainsPoint(myBoundingBox, location) && !isFinish) {
        
        [self updateTv:location];
        
        return YES;
        
    } 
    return NO;
}


-(void)updateTv:(CGPoint)location{
    
    if (indexSprite >= 6)return;
    
    PLAYSOUNDEFFECT(TouchTv);
    
    score+= 5;
    
    CCSprite* tempSprite = (CCSprite *)[self getChildByTag:kTvTagValue];
    
    CCLabelBMFont* label = (CCLabelBMFont *)[self getChildByTag:kLabelScoreTagValue];
    
    touchCount++;
    
    if (touchCount % kTapForProgress == 0) {
        
        PLAYSOUNDEFFECT(DestroyTv);
        
        indexSprite++;
        
        score+= 50;
        
       // [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
        [tempSprite setTexture:[[CCTextureCache sharedTextureCache]addImage:[NSString stringWithFormat:@"tv_000%d.png",indexSprite]]];
        
    }
    
    [label setString:[NSString stringWithFormat:@"%d",score]];
    
    CCSprite * temp = [CCSprite spriteWithFile:@"tv_touch_0001.png"];
    
    [self addChild:temp z:2 tag:kAnimationTouch];

    [temp setPosition:location];
    
    CCCallBlock * block = [CCCallBlock actionWithBlock:^{
       
        [self removeChild:temp cleanup:YES];
    }];
    
   // [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    
    [temp runAction:[CCSequence actionOne:[CCAnimate actionWithAnimation:touchAnimation] two:block]];
            
}


- (void)dealloc {
    
    CCLOG(@"%@, %@",NSStringFromSelector(_cmd), self);
    
    [[[CCDirector sharedDirector] touchDispatcher]removeDelegate:self];
    
    
}

@end
