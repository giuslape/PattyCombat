//
//  CreditsLayer.m
//  pattycombat
//
//  Created by Giuseppe Lapenta on 22/04/12.
//  Copyright 2012. All rights reserved.
//

#import "CreditsLayer.h"


@implementation CreditsLayer

@synthesize delegate = _delegate;


-(id)initWithColor:(ccColor4B)color width:(GLfloat)w height:(GLfloat)h{

        if( (self=[super initWithColor:color width:w height:h]) ) {
            
            CGSize size = [CCDirectorIOS sharedDirector].winSize;
            
            self.isTouchEnabled = YES;
                        
            CCSprite* background = [CCSprite spriteWithFile:@"credits.png"];
            
            background.position = ccp(size.width/2,size.height/2);
            
            [self addChild:background];
            
            CCSprite* closeButton = [CCSprite spriteWithFile:@"FBDialog.bundle/images/close.png"];
            
            [self addChild:closeButton z:3 tag:10];
            
            [closeButton setPosition:ccp(size.width * 0.97f, size.height * 0.95f)];
            
        }
        return self;

}

-(void) registerWithTouchDispatcher
{
    [[CCDirectorIOS sharedDirector].touchDispatcher addTargetedDelegate:self priority:INT_MIN + 1
     
                                              swallowsTouches:YES];
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirectorIOS sharedDirector] convertToGL:location];
    
    CGSize size = [CCDirectorIOS sharedDirector].winSize;
    
    CGRect balzorect = CGRectMake(size.width * 0.90f, 0, 100, 100);
    CGRect patty     = CGRectMake(size.width * 0.20f, 0, 100, 100);
    
    NSLog(@"Rect: %@",NSStringFromCGRect(balzorect));
    NSLog(@"Location: %@", NSStringFromCGPoint(location));
    
    CCSprite* closeButton = (CCSprite *)[self getChildByTag:10];
    
    if (CGRectContainsPoint([closeButton boundingBox], location)) {
        
        [_delegate creditsLayerDidClose:self];
        return  YES;
    }
    
    if (CGRectContainsPoint(balzorect, location)) {
        
        [self showWebSite:@"Balzo"];
        return YES;
    }
    
    if (CGRectContainsPoint(patty, location)) {
        
        [self showWebSite:@"Patty"];
        return YES;
    }
    
    return NO;
}

-(void)showWebSite:(NSString *)sender{
    
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), self);
    
    NSURL *urlToOpen = nil;
    
    if ([sender isEqualToString:@"Balzo"]) urlToOpen = [NSURL URLWithString:@"http://balzo.eu"];
    else if ([sender isEqualToString:@"Patty"]) urlToOpen = [NSURL URLWithString:@"http://www.pattycombat.com"];
    
    if (![[UIApplication sharedApplication] openURL:urlToOpen]) {
        CCLOG(@"%@%@",@"Failed to open url:",[urlToOpen description]);
    }
    
}

- (void)dealloc
{
    _delegate = nil;
}

@end
