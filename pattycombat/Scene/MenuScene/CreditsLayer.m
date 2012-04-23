//
//  CreditsLayer.m
//  pattycombat
//
//  Created by Giuseppe Lapenta on 22/04/12.
//  Copyright 2012. All rights reserved.
//

#import "CreditsLayer.h"


@implementation CreditsLayer


-(id)initWithColor:(ccColor4B)color width:(GLfloat)w height:(GLfloat)h{

        if( (self=[super initWithColor:color width:w height:h]) ) {
            
            self.isTouchEnabled = YES;
        }
        return self;

}

-(void) registerWithTouchDispatcher
{
    [[CCDirectorIOS sharedDirector].touchDispatcher addTargetedDelegate:self priority:-1
     
                                              swallowsTouches:YES];
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    
    NSLog(@"%@ %@", NSStringFromSelector(_cmd),self);
    
    [self removeFromParentAndCleanup:YES];

    return YES;
}

@end
