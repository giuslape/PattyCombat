//
//  GameState.h
//  pattycombat
//
//  Created by Giuseppe Lapenta on 26/03/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameState : NSObject <NSCoding> {
    
    BOOL completedLevel1;
    BOOL completedLevel2;
    BOOL completedLevel3;
    BOOL completedLevel4;
    BOOL completedLevel5;
    BOOL completedLevel6;
    BOOL completedLevel7;
    BOOL completedLevel8;
    BOOL completedLevel9;
    BOOL completedLevel10;
    BOOL extreme;
    BOOL perfect;
    BOOL ko;
    int timesFell;
}


+ (GameState *) sharedInstance;
- (void)save;

@property (assign) BOOL completedLevel1;
@property (assign) BOOL completedLevel2;
@property (assign) BOOL completedLevel3;
@property (assign) BOOL completedLevel4;
@property (assign) BOOL completedLevel5;
@property (assign) BOOL completedLevel6;
@property (assign) BOOL completedLevel7;
@property (assign) BOOL completedLevel8;
@property (assign) BOOL completedLevel9;
@property (assign) BOOL completedLevel10;
@property (assign) BOOL perfect;
@property (assign) BOOL ko;
@property (assign) BOOL extreme;


@property (assign) int  timesFell;


-(void)resetAchievements;

@end

