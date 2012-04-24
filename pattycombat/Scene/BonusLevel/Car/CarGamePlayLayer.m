//
//  CarGamePlayLayer.m
//  PattyCombat
//
//  Created by Giuseppe Lapenta on 04/12/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import "CarGamePlayLayer.h"
#import "GameManager.h"


@implementation CarGamePlayLayer

@synthesize fireAnimation;

- (void)dealloc {
    
    CCLOG(@"%@, %@",NSStringFromSelector(_cmd), self);
    [[[CCDirector sharedDirector] touchDispatcher]removeDelegate:self];
    
}

-(void)initAnimation{
    
    CCAnimation* tempAnimation = [CCAnimation animation];
    
    for (int i = 1; i <= 4; i++) {
        
        [tempAnimation addSpriteFrameWithFilename:[NSString stringWithFormat:@"pickup_touch_000%d.png",i]];
    }
    
    [self setTouchAnimation:tempAnimation];
    [touchAnimation setDelayPerUnit:0.08];
    
    CCAnimation* fireAnimationLoc = [CCAnimation animation];
    
    for (int i = 1; i <= 4; i++) {
        
        [fireAnimationLoc addSpriteFrameWithFilename:[NSString stringWithFormat:@"pickup_fuoco_000%d.png",i]];
    }
    
    [self setFireAnimation:fireAnimationLoc];
    [fireAnimation setDelayPerUnit:0.08];
}

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
        
        size = [[CCDirector sharedDirector] winSize];
        
        CCSprite* pickup = [CCSprite spriteWithFile:@"pickup_0001.png"];
        
        [self addChild:pickup z:kWallZValue tag:kWallTagValue];
                
        [pickup setPosition:ccp(size.width/2, size.height/2)];
        
        [self initAnimation];
        
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        
    }
    return self;
}

-(CGRect)adjustBoundingBox{
    
    CCSprite* pickup = (CCSprite *)[self getChildByTag:kWallTagValue];
    
    CGRect wallBoundingBox = [pickup boundingBox];
    
    float yCropAmount;
    
    int index = indexSprite;
    
    switch (++index) {
        case 1:
            yCropAmount = wallBoundingBox.size.height*0;
            break;
        case 2:
            yCropAmount = wallBoundingBox.size.height*0.17;
            break;
        case 3:
            yCropAmount = wallBoundingBox.size.height*0.30;
            break;
        case 4:
            yCropAmount = wallBoundingBox.size.height*0.40;
            break;
        case 5:
            yCropAmount = wallBoundingBox.size.height*0.60;
            break;
        case 6:
            yCropAmount = wallBoundingBox.size.height*0.71;
            break;
        case 7:
            yCropAmount = wallBoundingBox.size.height*0.71;
            break;
        default:
            yCropAmount = wallBoundingBox.size.height;
            break;
    }
    
    wallBoundingBox = CGRectMake(wallBoundingBox.origin.x, wallBoundingBox.origin.y, wallBoundingBox.size.width, wallBoundingBox.size.height - yCropAmount);
    
    return wallBoundingBox;
    
}

-(void)updateCar:(CGPoint)location{
    
    int index = indexSprite;
        
    if (indexSprite == 7) {
        
        CCSprite* sprite = (CCSprite *)[self getChildByTag:kWallTagValue];
        
         [sprite runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:fireAnimation]]];
    }
    
    PLAYSOUNDEFFECT(TouchCar);
    
    score+= 5;
    
    CCSprite* tempSprite = (CCSprite *)[self getChildByTag:kWallTagValue];
    
    CCLabelBMFont* label = (CCLabelBMFont *)[self getChildByTag:kLabelScoreTagValue];
    
    touchCount++;
    
    if (touchCount % kTapForProgress == 0) {
        
        PLAYSOUNDEFFECT(DestroyCar);
        
        indexSprite++;
        
        score+= 50;
        
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
        
        [tempSprite setTexture:[[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"pickup_000%d.png",index]]];
                
    }
    
    [label setString:[NSString stringWithFormat:@"%d",score]];
    
    CCSprite * temp = [CCSprite spriteWithFile:@"pickup_touch_0001.png"];
    
    [self addChild:temp z:2 tag:kAnimationTouch];
    
    [temp setPosition:location];
    
    CCCallBlock * block = [CCCallBlock actionWithBlock:^{
        
        [self removeChild:temp cleanup:YES];
    }];
    
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    
    [temp runAction:[CCSequence actionOne:[CCAnimate actionWithAnimation:touchAnimation] two:block]];    
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
    
    if (isFinish){
        
        scoreUp = totalScore + score - 1;
        return YES;
    }

    CGRect myBoundingBox = [self adjustBoundingBox];
    
    if (CGRectContainsPoint(myBoundingBox, location) && !isFinish) {
        
        [self updateCar:location];
        
        return YES;
        
    } 

    return NO;
	
}



@end
