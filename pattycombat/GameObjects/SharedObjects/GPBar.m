/*
 * Wrensation: http://www.wrensation.com/
 * Web-Geeks: http://www.web-geeks.com/
 *
 * Copyright (c) 2011 Wrensation + Web-Geeks
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "GPBar.h"


@implementation GPBar
@synthesize bar, inset, type, active, progress, mask;

@synthesize delegate = _delegate;

+(id) barWithBar:(NSString *)b inset:(NSString *)i mask:(NSString *)m {
    return [[self alloc] initBarWithBar:b inset:i mask:m];
}
-(id) initBarWithBar:(NSString *)b inset:(NSString *)i mask:(NSString *)m {
    if ((self = [super init])) {
        
        bar = [[NSString alloc] initWithString:b];
        inset = [[NSString alloc] initWithString:i];
        mask = [[NSString alloc] initWithString:m];
        spritesheet = NO;
		
        screenSize = [[CCDirector sharedDirector] winSize];
        
        screenMid = ccp(screenSize.width * 0.5f, screenSize.height * 0.5f);
        
        barSprite = [[CCSprite alloc] initWithFile:bar];
        barSprite.anchorPoint = ccp(0,0.5);
        barSprite.position = ccp(((screenSize.width - barSprite.boundingBox.size.width)/2),screenMid.y);
		
        insetSprite = [[CCSprite alloc] initWithFile:inset];
        insetSprite.anchorPoint = ccp(0.5,0.5);
        insetSprite.position = screenMid;
        [self addChild:insetSprite z:1];
		
        maskSprite = [[CCSprite alloc] initWithFile:mask];
        maskSprite.anchorPoint = ccp(0.5,0.5);
        maskSprite.position = screenMid;
        
        renderMasked = [[CCRenderTexture alloc] initWithWidth:screenSize.width 
                                                       height:screenSize.height 
                                                       pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        
        
        [[renderMasked sprite] setBlendFunc: (ccBlendFunc) {GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA}];
        renderMasked.position = screenMid;
        
        renderMaskNegative = [[CCRenderTexture alloc] initWithWidth:screenSize.width 
                                                             height:screenSize.height 
                                                             pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        
        [[renderMaskNegative sprite] setBlendFunc: (ccBlendFunc) {GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA}];
        renderMaskNegative.position = screenMid;
        
        [maskSprite setBlendFunc: (ccBlendFunc) {GL_ZERO, GL_ONE_MINUS_SRC_ALPHA}];
        
        [self clearRender];
        
        [self maskBar];
        
        [self addChild:renderMasked z:2];
    }
    return self;
}

+(id) barWithBarFrameName:(NSString *)b insetFrameName:(NSString *)i maskFrameName:(NSString *)m {
    
    return [[self alloc] initBarWithBarFrame:b insetFrame:i maskFrame:m];
}
-(id) initBarWithBarFrame:(NSString *)b insetFrame:(NSString *)i maskFrame:(NSString *)m {
    
    if ((self = [super init])) {
        
        spritesheet = YES;
        
        [self setCharacterState:kStateNone];
		
		screenSize = [[CCDirector sharedDirector] winSize];
        
        screenMid = ccp(screenSize.width * 0.5f, screenSize.height * 0.5f);
        
        insetSprite = [[CCSprite alloc] initWithSpriteFrameName:i];
        insetSprite.anchorPoint = ccp(0.5,0.5);
        insetSprite.position = screenMid;
        [self addChild:insetSprite z:1];

        barSprite = [[CCSprite alloc] initWithSpriteFrameName:b];
        barSprite.anchorPoint = ccp(0,0.5);
        barSprite.position = ccp(((screenSize.width - barSprite.boundingBox.size.width)/2),screenMid.y);
        
        greenBar = [[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"bar_green.png"];
        redBar   = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:b];
        		
        maskSprite = [[CCSprite alloc] initWithSpriteFrameName:m];
        maskSprite.anchorPoint = ccp(0.5,0.5);
        maskSprite.position = screenMid;
        
        
        renderMasked = [[CCRenderTexture alloc] initWithWidth:screenSize.width height:screenSize.height pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        [[renderMasked sprite] setBlendFunc: (ccBlendFunc) {GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA}];
        renderMasked.position = screenMid;
        renderMaskNegative = [[CCRenderTexture alloc] initWithWidth:screenSize.width height:screenSize.height pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        [[renderMaskNegative sprite] setBlendFunc: (ccBlendFunc) {GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA}];
        renderMaskNegative.position = screenMid;
        
        [maskSprite setBlendFunc: (ccBlendFunc) {GL_ZERO, GL_ONE_MINUS_SRC_ALPHA}];
        
        [self clearRender];
        
        [self maskBar];
        
        [self addChild:renderMasked z:2]; 
    }
    return self;
}
-(void) clearRender {
    
    [renderMasked beginWithClear:0.0f g:0.0f b:0.0f a:0.0f];
    
    [barSprite visit];
    
    [renderMasked end];
    
    [renderMaskNegative beginWithClear:0.0f g:0.0f b:0.0f a:0.0f];
    
    [barSprite visit];
    
    [renderMaskNegative end];
}
-(void) maskBar {
    
    [renderMaskNegative begin];
    
    glColorMask(0.0f, 0.0f, 0.0f, 1.0f);
    
    [maskSprite visit];
    
    glColorMask(1.0f, 1.0f, 1.0f, 1.0f);
    
    [renderMaskNegative end];
       
    masked = renderMaskNegative.sprite;
    masked.position = screenMid;
    
    [masked setBlendFunc: (ccBlendFunc) { GL_ZERO, GL_ONE_MINUS_SRC_ALPHA }];
    
    [renderMasked begin];
    
    glColorMask(0.0f, 0.0f, 0.0f, 1.0f);
    
    [masked visit];
    
    glColorMask(1.0f, 1.0f, 1.0f, 1.0f);
    
    [renderMasked end];
}

-(void) setProgress:(float)lp {
    
    if (self.characterState == kStateHealthIsEmpty) return;
    
    [self setCharacterState:kStateNone];
    
    oldProgress = progress;
    progress = lp;
    
    if (progress > 60) [barSprite setDisplayFrame:greenBar];
    else [barSprite setDisplayFrame:redBar];
    
    if(progress > 100){
        
        progress = 100;
    }
    
    barLR = (oldProgress < progress) ? YES : NO;
    
    [self unscheduleUpdate];
    [self scheduleUpdate];
}

-(void) show {
	active = YES;
}
-(void) hide {
	active = NO;
}
-(void) setTransparency:(float)trans {
	if (trans > 0 && trans <= 255) {
		active = YES;
	}
	else if (trans < 0) {
		NSLog(@"Transparency must be greater than or equal 0.");
	}
	else if (trans == 0) {
		
	}
	else if (trans > 255) {
		NSLog(@"Transparency must be less than or equal to 255.");
	}
	barSprite.opacity = trans;
	insetSprite.opacity = trans;
	maskSprite.opacity = trans;
}
-(void)dealloc{
    
    
    [self unscheduleUpdate];

}

-(void) update:(ccTime)delta
{
    int signValue = (barLR) ? 1 : -1;
    
    oldProgress +=   1 * signValue; 
        
    barSprite.position =ccp(((screenSize.width - barSprite.boundingBox.size.width) / 2) - (oldProgress / 100 * barSprite.boundingBox.size.width), screenMid.y);
    [self clearRender];
    [self maskBar];
    
    if ((barLR && oldProgress >= progress) || (!barLR && oldProgress <= progress)){

        [self unscheduleUpdate];
        [self setCharacterState:kStateHealthIdle];
    }
    
    if (progress == 100 && self.characterState == kStateHealthIdle) {
        
        [self setCharacterState:kStateHealthIsEmpty];
        [_delegate barDidEmpty:self];
    }
    
    
}


@end
