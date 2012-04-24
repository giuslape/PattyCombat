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
    BOOL isMusicON;
    BOOL isSoundEffectsON;
    BOOL _isTutorial;
    BOOL _isPerfectForLevel;
    BOOL _isKoForLevel;
    BOOL _isExtreme;
    int  _totalScore;
    int  _currentScore;
    int  _currentLevel;
    int  _levelReached;
    int  _gameTime;

    
    // Added for audio
    BOOL hasAudioBeenInitialized;
    GameManagerSoundState managerSoundState;
    SimpleAudioEngine *soundEngine;
    GameStates _gameState;
    NSMutableDictionary *listOfSoundEffectFiles;
    NSMutableDictionary *soundEffectsState;  
    
    NSString* _namePlayer;

}

@property (readwrite) int currentLevel;
@property (readwrite) int currentScore;
@property (readwrite) int totalScore;
@property (readwrite, nonatomic) int bestScore;
@property (readonly , nonatomic) BOOL isTutorial;
@property (readwrite, nonatomic) BOOL isPerfect;
@property (readwrite, nonatomic) BOOL isKo;
@property (readwrite, nonatomic) BOOL isPerfectForLevel;
@property (readwrite, nonatomic) BOOL isKoForLevel;
@property (readwrite) int gameTime;
@property (readwrite) BOOL isMusicON;
@property (readwrite) BOOL isSoundEffectsON;
@property (readwrite) BOOL isBonusLevel;
@property (nonatomic,readwrite) BOOL isExtreme;
@property (readwrite, nonatomic) int levelReached;
@property (nonatomic, strong) NSString* namePlayer;
@property (strong, readonly) id<SceneDao> dao;
@property (readwrite) GameManagerSoundState managerSoundState;
@property (readwrite) GameStates gameState;
@property (nonatomic, strong) NSMutableDictionary *listOfSoundEffectFiles;
@property (nonatomic, strong) NSMutableDictionary *soundEffectsState;
@property (nonatomic, strong, readwrite) NSMutableArray* patternForLevel;
@property (readwrite) double elapsedTime;
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
-(void)updateGameState:(GameStates)newGameState;

@end
