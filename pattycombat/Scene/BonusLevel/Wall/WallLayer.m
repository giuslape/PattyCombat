//
//  WallLayer.m
//  PattyCombat
//
//  Created by Giuseppe Lapenta on 23/11/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import "WallLayer.h"
#import "GameManager.h"



@interface WallLayer()

-(void)updateWall:(CGPoint)location;

@end

@implementation WallLayer



-(void)initAnimation{
    
    CCAnimation* tempAnimation = [CCAnimation animation];
    

    for (int i = 0; i<=4; i++) {
        
        [tempAnimation addSpriteFrameWithFilename:[NSString stringWithFormat:@"muretto_touch_000%d.png",i]];
    }
    
    [self setTouchAnimation:tempAnimation];
    [touchAnimation setDelayPerUnit:0.08];
    
    
}

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        size = [[CCDirector sharedDirector] winSize];
        
        CCSprite* wall = [CCSprite spriteWithFile:@"muretto_0001.png"];
        
        [self addChild:wall z:kWallZValue tag:kWallTagValue];
        
        [wall setAnchorPoint:ccp(0, 1)];
        
        [wall setPosition:ccp(78, size.height - 63)];
        
        [self initAnimation];
        
    }
    return self;
}



-(CGRect)adjustBoundingBox{
    
    CCSprite* wall = (CCSprite *)[self getChildByTag:kWallTagValue];
    
    CGRect wallBoundingBox = [wall boundingBox];
    
    float yCropAmount;
    
    switch (indexSprite) {
        case 1:
            yCropAmount = wallBoundingBox.size.height*0;
            break;
        case 2:
            yCropAmount = wallBoundingBox.size.height*0.17;
            break;
        case 3:
            yCropAmount = wallBoundingBox.size.height*0.43;
            break;
        case 4:
            yCropAmount = wallBoundingBox.size.height*0.58;
            break;
        case 5:
            yCropAmount = wallBoundingBox.size.height*0.71;
            break;
        case 6:
            yCropAmount = wallBoundingBox.size.height;
            break;
        default:
            yCropAmount = wallBoundingBox.size.height;
            break;
    }
    
    wallBoundingBox = CGRectMake(wallBoundingBox.origin.x, wallBoundingBox.origin.y, wallBoundingBox.size.width, wallBoundingBox.size.height - yCropAmount);
    
    
    return wallBoundingBox;
    
    
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
        
        [self updateWall:location];
        
        return YES;
        
    } 
        
    return NO;
}


-(void)updateWall:(CGPoint)location{
    
    if (indexSprite >= 6)return;
    
    PLAYSOUNDEFFECT(TouchWall);
    
    score+= 5;
    
    CCSprite* tempSprite = (CCSprite *)[self getChildByTag:kWallTagValue];

    
    CCLabelBMFont* label = (CCLabelBMFont *)[self getChildByTag:kLabelScoreTagValue];
    

    touchCount++;

    if (touchCount % kTapForProgress == 0) {
        
        PLAYSOUNDEFFECT(DestroyWall);
        
        indexSprite++;
        
        score+= 50;
        
        [tempSprite setTexture:[[CCTextureCache sharedTextureCache]addImage:[NSString stringWithFormat:@"muretto_000%d.png",indexSprite]]];
        
        
    }
    
    [label setString:[NSString stringWithFormat:@"%d",score]];
    
    CCSprite * temp = [CCSprite spriteWithFile:@"muretto_touch_0001.png"];

    [self addChild:temp z:2 tag:kAnimationTouch];
        
    [temp setPosition:location];
    
    CCCallBlock * block = [CCCallBlock actionWithBlock:^{
        
        [self removeChild:temp cleanup:YES];
    }];
    
    [temp runAction:[CCSequence actionOne:[CCAnimate actionWithAnimation:touchAnimation] two:block]];    
}


- (void)dealloc {
    
    CCLOG(@"%@, %@",NSStringFromSelector(_cmd), self);
    
    [[[CCDirector sharedDirector] touchDispatcher]removeDelegate:self];
    
    
}

@end
