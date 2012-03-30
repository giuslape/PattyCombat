//
//  GameManager.h
//  PattyCakeFighter
//
//  Created by Giuseppe Lapenta on 10/08/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constant.h"
#import "SceneDaoPlist.h"
#import "SimpleAudioEngine.h"


@interface GameManager : NSObject {
    
    SceneTypes currentScene;
    BOOL hasPlayerDied;
    int currentLevel;
    NSString* namePlayer;
    BOOL isMusicON;
    BOOL isSoundEffectsON;
    int totalScore;
    int currentScore;
    
    int _levelReached;
    
    // Added for audio
    BOOL hasAudioBeenInitialized;
    GameManagerSoundState managerSoundState;
    SimpleAudioEngine *soundEngine;
    NSMutableDictionary *listOfSoundEffectFiles;
    NSMutableDictionary *soundEffectsState;  
}

@property (readwrite) int currentLevel;
@property (readwrite, nonatomic) int currentScore;
@property (readwrite) int totalScore;
@property (readwrite, nonatomic) int bestScore;
@property (readwrite) BOOL isMusicON;
@property (readwrite) BOOL isSoundEffectsON;
@property (readwrite) BOOL hasPlayerDied;
@property (readwrite) BOOL isBonusLevel;
@property (readwrite, nonatomic) int levelReached;
@property (nonatomic, strong) NSString* namePlayer;
@property (strong, readonly) id<SceneDao> dao;
@property (readwrite) GameManagerSoundState managerSoundState;
@property (nonatomic, strong) NSMutableDictionary *listOfSoundEffectFiles;
@property (nonatomic, strong) NSMutableDictionary *soundEffectsState;
@property (nonatomic, strong, readwrite) NSMutableArray* patternForLevel;
@property (readwrite) int elapsedTime;
@property (readwrite) BOOL isLastLevel;



+(GameManager*)sharedGameManager;                                
-(void)runSceneWithID:(SceneTypes)sceneID; 
-(void)setupAudioEngine;
-(ALuint)playSoundEffect:(NSString*)soundEffectKey;
-(void)stopSoundEffect:(ALuint)soundEffectID;
-(void)playBackgroundTrack:(NSString*)trackFileName;
-(void) stopBackgroundMusic;
-(void) resetBestScore;
-(void)pauseGame;
-(NSString*)formatPlayerNameTypeToString;
-(NSString *)formatAchievementTypeToString;

@end
