//
//  GameState.m
//  pattycombat
//
//  Created by Vincenzo Lapenta on 26/03/12.
//  Copyright (c) 2012 Fratello. All rights reserved.
//

#import "GameState.h"
#import "GCDatabase.h"


@implementation GameState

@synthesize completedLevel1;
@synthesize completedLevel2;
@synthesize completedLevel3;
@synthesize completedLevel4;
@synthesize completedLevel5;
@synthesize completedLevel6;
@synthesize completedLevel7;
@synthesize completedLevel8;
@synthesize completedLevel9;
@synthesize completedLevel10;
@synthesize perfect;
@synthesize ko;
@synthesize timesFell;
@synthesize extreme;



static GameState * sharedInstance = nil;


+(GameState*)sharedInstance {
    
    @synchronized([GameState class])
    {
        if(!sharedInstance) {
            
            sharedInstance = loadData(@"GameStates");
            if (!sharedInstance) {
                sharedInstance = [[self alloc] init];
            }
        }
        return sharedInstance;
    }
    return nil;
}

+(id)alloc
{
    @synchronized ([GameState class])
    {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a \
                 second instance of the GameState singleton");
        sharedInstance = [super alloc];
        return sharedInstance;
    }
    return nil;
}
- (void)save {
    saveData(self, @"GameStates");
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeBool:completedLevel1 forKey:@"CompletedLevel1"];
    [encoder encodeBool:completedLevel2 forKey:@"CompletedLevel2"];
    [encoder encodeBool:completedLevel3 forKey:@"CompletedLevel3"];
    [encoder encodeBool:completedLevel4 forKey:@"CompletedLevel4"];
    [encoder encodeBool:completedLevel5 forKey:@"CompletedLevel5"];
    [encoder encodeBool:completedLevel6 forKey:@"CompletedLevel6"];
    [encoder encodeBool:completedLevel7 forKey:@"CompletedLevel7"];
    [encoder encodeBool:completedLevel8 forKey:@"CompletedLevel8"];
    [encoder encodeBool:completedLevel9 forKey:@"CompletedLevel9"];
    [encoder encodeBool:completedLevel10 forKey:@"CompletedLevel10"];
    [encoder encodeBool:extreme forKey:@"Extreme"];
    [encoder encodeBool:perfect forKey:@"Perfect"];
    [encoder encodeBool:ko forKey:@"KO"];
    
    [encoder encodeInt:timesFell forKey:@"TimesFell"];
}
- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [super init])) {
        
        completedLevel1  = [decoder
                           decodeBoolForKey:@"CompletedLevel1"];
        completedLevel2  = [decoder
                           decodeBoolForKey:@"CompletedLevel2"];
        completedLevel3  = [decoder
                           decodeBoolForKey:@"CompletedLevel3"];
        completedLevel4  = [decoder
                           decodeBoolForKey:@"CompletedLevel4"];
        completedLevel5  = [decoder
                           decodeBoolForKey:@"CompletedLevel5"];
        completedLevel6  = [decoder
                           decodeBoolForKey:@"CompletedLevel6"];
        completedLevel7  = [decoder
                           decodeBoolForKey:@"CompletedLevel7"];
        completedLevel8  = [decoder
                           decodeBoolForKey:@"CompletedLevel8"];
        completedLevel9  = [decoder
                           decodeBoolForKey:@"CompletedLevel9"];
        completedLevel10 = [decoder
                            decodeBoolForKey:@"CompletedLevel10"];
        extreme          = [decoder
                           decodeBoolForKey:@"Extreme"];
        perfect          = [decoder
                            decodeBoolForKey:@"Perfect"];
        ko               = [decoder
                            decodeBoolForKey:@"KO"];
        timesFell        = [decoder
                            decodeIntForKey:@"TimesFell"];
    }
    return self;
}


-(void) resetAchievements{
    
    completedLevel1 = FALSE;
    completedLevel2 = FALSE;
    completedLevel3 = FALSE;
    completedLevel4 = FALSE;
    completedLevel5 = FALSE;
    completedLevel6 = FALSE;
    completedLevel7 = FALSE;
    completedLevel8 = FALSE;
    completedLevel9 = FALSE;
    completedLevel10 = FALSE;
    perfect = FALSE;
    ko = FALSE;
    extreme = FALSE;
    
    [self save];
}
@end