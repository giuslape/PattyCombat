//
//  GCHelper.m
//  PattyCombat
//
//  Created by Giuseppe Lapenta on 04/03/12.
//  Copyright (c) 2012 Fratello. All rights reserved.
//

#import "GCHelper.h"
#import "GCDatabase.h"
#import "GameState.h"

@implementation GCHelper

@synthesize scoresToReport;
@synthesize achievementsToReport;



#pragma mark -
#pragma mark ===  Loading/Saving  ===
#pragma mark -

static GCHelper *sharedHelper = nil;

+ (GCHelper *) sharedInstance {
    
    @synchronized([GCHelper class])
    {
        if (!sharedHelper) {
            
            sharedHelper = loadData(@"GameCenterData");
            
            if (!sharedHelper) {
                sharedHelper =  [[self alloc]
                                 initWithScoresToReport:[NSMutableArray array]
                 achievementsToReport:[NSMutableArray array]];
            }
        }
        return sharedHelper;
    }
    return nil;
}


+(id)alloc
{
    @synchronized ([GCHelper class])
    {
        NSAssert(sharedHelper == nil, @"Attempted to allocated a \
                 second instance of the GCHelper singleton");
        sharedHelper = [super alloc];
        
        return sharedHelper;
    }
    return nil;
}

- (void)save {
    saveData(self, @"GameCenterData");
}


- (BOOL)isGameCenterAvailable {
    
    // check for presence of GKLocalPlayer API
    BOOL localPlayerClassAvailable = (NSClassFromString(@"GKLocalPlayer")) != nil;
    
    // check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer
                                           options:NSNumericSearch] != NSOrderedAscending);
    return (localPlayerClassAvailable && osVersionSupported);
}

- (id)initWithScoresToReport:(NSMutableArray *)theScoresToReport
        achievementsToReport:(NSMutableArray *)theAchievementsToReport {
    
    if ((self = [super init])) {
        
        self.scoresToReport = theScoresToReport;
        self.achievementsToReport = theAchievementsToReport;
        gameCenterAvailable = [self isGameCenterAvailable];
        if (gameCenterAvailable) {
            NSNotificationCenter *nc =
            [NSNotificationCenter defaultCenter];
            [nc addObserver:self
                   selector:@selector(authenticationChanged)
                       name:GKPlayerAuthenticationDidChangeNotificationName
                     object:nil];
        }
    }
    return self;
}

#pragma mark -
#pragma mark ===  Internal Function  ===
#pragma mark -

- (void)authenticationChanged {
    
    dispatch_async(dispatch_get_main_queue(), ^(void)
    {
        if ([GKLocalPlayer localPlayer].isAuthenticated &&
            !userAuthenticated) {
            NSLog(@"Authentication changed: player authenticated.");
            [self resendData];
            userAuthenticated = TRUE;
        } else if (![GKLocalPlayer localPlayer].isAuthenticated &&
                   userAuthenticated) {
            NSLog(@"Authentication changed: player not authenticated");
            userAuthenticated = FALSE;
        }
    });
}

- (void)sendAchievement:(GKAchievement *)achievement {
    [achievement reportAchievementWithCompletionHandler:
     ^(NSError *error) {
         dispatch_async(dispatch_get_main_queue(), ^(void)
         {
             if (error == NULL) {
                 NSLog(@"Successfully sent achievement!");
                 [achievementsToReport removeObject:achievement];
             } else {
                 NSLog(@"Achievement failed to send... will try again \
                       later. Reason: %@", error.localizedDescription);
             }
         });
     }];
}

- (void)sendScore:(GKScore *)score {
    [score reportScoreWithCompletionHandler:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            if (error == NULL) {
                NSLog(@"Successfully sent score!");
                [scoresToReport removeObject:score];
                NSLog(@"****************\n Categoria: %lld", score.value);
            } else {
                NSLog(@"Score failed to send... will try again later. \
                      Reason: %@", error.localizedDescription);
                      }
                      });
            }];
        }

- (void) resetAchievements
{
    [GKAchievement resetAchievementsWithCompletionHandler: ^(NSError *error) 
     {
         dispatch_async(dispatch_get_main_queue(), ^(void)
                        {
                            if (error == NULL) {
                                NSLog(@"Successfully reset achievement!");
                                [[GameState sharedInstance] resetAchievements];
                                
                            } else {
                                NSLog(@"Achievement failed to send... will try again \
                                      later. Reason: %@", error.localizedDescription);
                            }
                        });
     }];
}




- (void)resendData {
    for (GKAchievement *achievement in achievementsToReport) {
        [self sendAchievement:achievement];
    }
    
    for (GKScore *score in scoresToReport) {
        [self sendScore:score];
    }
}

#pragma mark -
#pragma mark ===  User Functions  ===
#pragma mark -


- (void)authenticateLocalUser {
    
    if (!gameCenterAvailable) return;
    
    NSLog(@"Authenticating local user...");
    
    if ([GKLocalPlayer localPlayer].authenticated == NO) {
        [[GKLocalPlayer localPlayer]
         authenticateWithCompletionHandler:^(NSError *error) 
         {
             if (error == NULL) {
                 NSLog(@"Successfully autentication user!");
             } else {
                 NSLog(@"Autentication failed... will try again \
                       later. Reason: %@", error.localizedDescription);
             }
         }];
    } else {
        NSLog(@"Already authenticated!");
    }
}


- (void)reportAchievement:(NSString *)identifier
          percentComplete:(double)percentComplete {
    GKAchievement* achievement = [[GKAchievement alloc]
                                   initWithIdentifier:identifier];
    achievement.percentComplete = percentComplete;
    [achievementsToReport addObject:achievement];
    [self save];
    achievement.showsCompletionBanner = YES;
    if (!gameCenterAvailable || !userAuthenticated) return;
    [self sendAchievement:achievement];
}
 
- (void)reportScore:(NSString *)identifier score:(int64_t)rawScore {
    GKScore *score = [[GKScore alloc]
                       initWithCategory:identifier];
    score.value = rawScore;
    [scoresToReport addObject:score];
    [self save];
    if (!gameCenterAvailable || !userAuthenticated) return;
    [self sendScore:score];
}

#pragma mark -
#pragma mark ===  NSCoding  ===
#pragma mark -

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:scoresToReport forKey:@"ScoresToReport"];
    [encoder encodeObject:achievementsToReport
                   forKey:@"AchievementsToReport"];
}
- (id)initWithCoder:(NSCoder *)decoder {
    NSMutableArray * theScoresToReport =
    [decoder decodeObjectForKey:@"ScoresToReport"];
    NSMutableArray * theAchievementsToReport =
    [decoder decodeObjectForKey:@"AchievementsToReport"];
    return [self initWithScoresToReport:theScoresToReport
                   achievementsToReport:theAchievementsToReport];
}
@end
