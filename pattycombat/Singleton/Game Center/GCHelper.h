//
//  GCHelper.h
//  PattyCombat
//
//  Created by Giuseppe Lapenta on 04/03/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

#define kAchievementLevel1  @"com.tadaa.pattycombat.achievement.level1"
#define kAchievementLevel2  @"com.tadaa.pattycombat.achievement.level2"
#define kAchievementLevel3  @"com.tadaa.pattycombat.achievement.level3"
#define kAchievementLevel4  @"com.tadaa.pattycombat.achievement.level4"
#define kAchievementLevel5  @"com.tadaa.pattycombat.achievement.level5"
#define kAchievementLevel6  @"com.tadaa.pattycombat.achievement.level6"
#define kAchievementLevel7  @"com.tadaa.pattycombat.achievement.level7"
#define kAchievementLevel8  @"com.tadaa.pattycombat.achievement.level8"
#define kAchievementLevel9  @"com.tadaa.pattycombat.achievement.level9"
#define kAchievementLevel10 @"com.tadaa.pattycombat.achievement.level10"
#define kAchievementPerfect @"com.tadaa.pattycombat.achievement.perfect"
#define kAchievementKO      @"com.tadaa.pattycombat.achievement.ko"
#define kPattyLeaderboard   @"com.tadaa.pattycombat.leaderboard.score"
#define kAchievementExtreme @"com.tadaa.pattycombat.achievement.extreme"

@interface GCHelper : NSObject <NSCoding>
{
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
    NSMutableArray *scoresToReport;
    NSMutableArray *achievementsToReport;
}

@property (strong) NSMutableArray *scoresToReport;
@property  (strong)NSMutableArray *achievementsToReport;

+ (GCHelper *) sharedInstance;
- (void)authenticationChanged;
- (void)authenticateLocalUser;
- (void)save;
- (id)initWithScoresToReport:(NSMutableArray *)scoresToReport achievementsToReport:(NSMutableArray *)achievementsToReport;
- (void)reportAchievement:(NSString *)identifier percentComplete:(double)percentComplete;
- (void)reportScore:(NSString *)identifier score:(int64_t)score;
- (void) resetAchievements;

@end
