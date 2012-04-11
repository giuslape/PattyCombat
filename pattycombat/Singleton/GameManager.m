//
//  GameManager.m
//  PattyCakeFighter
//
//  Created by Giuseppe Lapenta on 10/08/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import "GameManager.h"
#import "MenuScene.h"
#import "IntroScene.h"
#import "GameScene.h"
#import "EndScene.h"
#import "WallScene.h"
#import "CarScene.h"



@implementation GameManager

static GameManager* _sharedGameManager = nil;         

@synthesize currentLevel = _currentLevel;
@synthesize currentScore = _currentScore;
@synthesize totalScore   = _totalScore;
@synthesize namePlayer   = _namePlayer;
@synthesize gameState    = _gameState;
@synthesize gameTime     = _gameTime;
@synthesize isPerfect;
@synthesize isPerfectForLevel = _isPerfectForLevel;
@synthesize isKoForLevel = _isKoForLevel;
@synthesize isKo;
@synthesize hasPlayerDied;
@synthesize bestScore;
@synthesize dao;
@synthesize managerSoundState;
@synthesize listOfSoundEffectFiles;
@synthesize patternForLevel;
@synthesize soundEffectsState;
@synthesize isMusicON;
@synthesize isSoundEffectsON;
@synthesize elapsedTime;
@synthesize isLastLevel;
@synthesize isBonusLevel;
@synthesize levelReached = _levelReached;

+(GameManager*)sharedGameManager {
    
    @synchronized([GameManager class])                            
    {
        if(!_sharedGameManager)                                    
            _sharedGameManager = [[self alloc] init]; 
        return _sharedGameManager;                                 
    }
    return nil; 
 }


+(id)alloc 
{
    @synchronized ([GameManager class])                            
    {
        NSAssert(_sharedGameManager == nil,
                 @"Attempted to allocated a second instance of the Game Manager singleton"); 
        _sharedGameManager = [super alloc];
    
        return _sharedGameManager;                                 
    }
    return nil;  
}


-(id<SceneDao>)dao{
    
    if (!dao) {
        
        dao = [[SceneDaoPlist alloc] init];
    }
    
    return dao;
}



-(id)init {  
    
    self = [super init];
    
    if (self != nil) {
        // Game Manager initialized
        CCLOG(@"Game Manager Singleton, init");
        isMusicON = YES;
        isSoundEffectsON = YES;
        hasPlayerDied = NO;
        hasAudioBeenInitialized = NO;
        soundEngine = nil;
        managerSoundState = kAudioManagerUninitialized;
        currentScene = kNoSceneUninitialized;
        elapsedTime = 0;  
        _namePlayer = nil;
        _gameTime = 0;
        _gameState = kStateLose;
    }
    return self;
}
- (NSString*)formatSceneTypeToString:(SceneTypes)sceneID {
    
    NSString *result = nil;
    
    switch(sceneID) {
        case kNoSceneUninitialized:
            result = @"kNoSceneUninitialized";
            break;
        case kMainMenuScene:
            result = @"kMainMenuScene";
            break;
        case kIntroScene:
            result = @"kIntroScene";
            break;
        case kLevelCompleteScene:
            result = @"kLevelCompleteScene";
            break;
        case kGamelevel1:
            result = @"kGamelevel1";
            break;
        case kBonusLevel1:
            result = @"kBonusLevel1";
            break;
        case kBonusLevel2:
            result = @"kBonusLevel2";
            break;
        default:
            [NSException raise:NSGenericException format:@"Unexpected SceneType."];
    }
    return result;
}

-(NSString*)formatPlayerTypeToString:(int)level{
    
    NSString* result = nil;
    
    switch (level) {
            
        case 1:
            result = @"myagi";
            break;
        case 2:
            result = @"crocodile";
            break;
        case 3:
            result = @"cinziah";
            break;
        case 5:
            result = @"maa";
            break;
        case 6:
            result = @"joco";
            break;
        case 7:
            result = @"jenny";
            break;
        case 8:
            result = @"bud";
            break;
        case 10:
            result = @"JeanPaul";
            break;
        case 11:
            result = @"steven";
            break;
        case 12:
            result = @"chuck";
            break;
        default:
            break;
    }
    
    return result;
}

-(NSString*)formatPlayerNameTypeToString{
    
    NSString* result = nil;
    
    switch (_currentLevel) {
            
        case 1:
            result = @"Maestro Miaghi";
            break;
        case 2:
            result = @"Johnny Denti";
            break;
        case 3:
            result = @"Cinziah";
            break;
        case 5:
            result = @"Maa Sallo";
            break;
        case 6:
            result = @"Jocopoco";
            break;
        case 7:
            result = @"Jenny Lava";
            break;
        case 8:
            result = @"Charlie Jumbo";
            break;
        case 10:
            result = @"Jean Paul";
            break;
        case 11:
            result = @"Steven";
            break;
        case 12:
            result = @"Chuck";
            break;
        default:
            break;
    }
    
    return result;
}

-(void)formatGameTime{
    
    switch (_currentLevel) {
            
        case 1:
            _gameTime = 10;
            break;
        case 2:
            _gameTime = 43;
            break;
        case 3:
            _gameTime = 43;
            break;
        case 5:
            _gameTime = 43;
            break;
        case 6:
            _gameTime = 43;
            break;
        case 7:
            _gameTime = 43;
            break;
        case 8:
            _gameTime = 43;
            break;
        case 10:
            _gameTime = 43;
            break;
        case 11:
            _gameTime = 43;
            break;
        case 12:
            _gameTime = 43;
            break;
        default:
            break;
    }
}

-(NSString *)formatAchievementTypeToString{
    
    NSString* result;
    
    return result;
}


-(void)initAudioAsync {
    // Initializes the audio engine asynchronously
    managerSoundState = kAudioManagerInitializing;
    
    // Indicate that we are trying to start up the Audio Manager
    [CDSoundEngine setMixerSampleRate:CD_SAMPLE_RATE_MID];
    
    //Init audio manager asynchronously as it can take a few seconds
    //The FXPlusMusicIfNoOtherAudio mode will check if the user is
    // playing music and disable background music playback if
    // that is the case.
    [CDAudioManager initAsynchronously:kAMM_FxPlusMusic];
    
    //Wait for the audio manager to initialize
    while ([CDAudioManager sharedManagerState] != kAMStateInitialised)
    {
        [NSThread sleepForTimeInterval:0.1];
    }
    
    //At this point the CocosDenshion should be initialized
    // Grab the CDAudioManager and check the state
    CDAudioManager *audioManager = [CDAudioManager sharedManager];
    
    if (audioManager.soundEngine == nil ||
        audioManager.soundEngine.functioning == NO) {
        CCLOG(@"CocosDenshion failed to init, no audio will play.");
        managerSoundState = kAudioManagerFailed;
    } else {
        [audioManager setResignBehavior:kAMRBStopPlay autoHandle:NO];
        soundEngine = [SimpleAudioEngine sharedEngine];
        managerSoundState = kAudioManagerReady;
        CCLOG(@"CocosDenshion is Ready");
    }
}


-(void)setupAudioEngine {
    if (hasAudioBeenInitialized == YES) {
        return;
    } else {
        hasAudioBeenInitialized = YES;
        NSOperationQueue *queue = [NSOperationQueue new];
        NSInvocationOperation *asyncSetupOperation =
        [[NSInvocationOperation alloc] initWithTarget:self
                                             selector:@selector(initAudioAsync)
                                               object:nil];
        [queue addOperation:asyncSetupOperation];
    }
}

-(NSDictionary *)getSoundEffectsListForSceneWithID:(SceneTypes)sceneID {
    
    NSString *fullFileName = @"SoundEffects.plist";
    NSString *plistPath;
    // 1: Get the Path to the plist file
    NSString *rootPath =
    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                         NSUserDomainMask, YES)
     objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:fullFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle]
                     pathForResource:@"SoundEffects" ofType:@"plist"];
    }
    // 2: Read in the plist file
    NSDictionary *plistDictionary =
    [NSDictionary dictionaryWithContentsOfFile:plistPath];
    // 3: If the plistDictionary was null, the file was not found.
    if (plistDictionary == nil) {
        CCLOG(@"Error reading SoundEffects.plist");
        return nil; // No Plist Dictionary or file found
    }
    // 4. If the list of soundEffectFiles is empty, load it
    if ((listOfSoundEffectFiles == nil) ||
        ([listOfSoundEffectFiles count] < 1)) {
        NSLog(@"Before");
        [self setListOfSoundEffectFiles:
         [[NSMutableDictionary alloc] init]];
        NSLog(@"after");
        for (NSString *sceneSoundDictionary in plistDictionary) {
            [listOfSoundEffectFiles
             addEntriesFromDictionary:
             [plistDictionary objectForKey:sceneSoundDictionary]];
        }
        CCLOG(@"Number of SFX filenames:%d",
              [listOfSoundEffectFiles count]);
    }
    // 5. Load the list of sound effects state, mark them as unloaded
    if ((soundEffectsState == nil) ||
        ([soundEffectsState count] < 1)) {
        [self setSoundEffectsState:[[NSMutableDictionary alloc] init]];
        for (NSString *SoundEffectKey in listOfSoundEffectFiles) {
            [soundEffectsState setObject:[NSNumber
                                          numberWithBool:SFX_NOTLOADED] forKey:SoundEffectKey];
        }
    }
    // 6. Return just the mini SFX list for this scene
    NSString *sceneIDName = [self formatSceneTypeToString:sceneID];
    NSDictionary *soundEffectsList = [plistDictionary objectForKey:sceneIDName];
    return soundEffectsList;
}

-(void)loadAudioForSceneWithID:(NSNumber*)sceneIDNumber {
    
    @autoreleasepool {
            
        SceneTypes sceneID = (SceneTypes)[sceneIDNumber intValue];
        // 1
        if (managerSoundState == kAudioManagerInitializing) {
            int waitCycles = 0;
            while (waitCycles < AUDIO_MAX_WAITTIME) {
                [NSThread sleepForTimeInterval:0.1f];
                if ((managerSoundState == kAudioManagerReady) ||
                    (managerSoundState == kAudioManagerFailed)) {
                    break;
                }
                waitCycles = waitCycles + 1;
            }
        }
        if (managerSoundState == kAudioManagerFailed) {
            return; // Nothing to load, CocosDenshion not ready
        }
        NSDictionary *soundEffectsToLoad = [NSDictionary dictionaryWithDictionary:
                                            [self getSoundEffectsListForSceneWithID:sceneID]];
        if (soundEffectsToLoad == nil) { // 2
            CCLOG(@"Error reading SoundEffects.plist");
            return;
        }
        // Get all of the entries and PreLoad // 3
        for( NSString *keyString in soundEffectsToLoad )
        {
            CCLOG(@"\nLoading Audio Key:%@ File:%@",
                  keyString,[soundEffectsToLoad objectForKey:keyString]);
            [soundEngine preloadEffect:
             [soundEffectsToLoad objectForKey:keyString]]; // 3
            // 4
            [soundEffectsState setObject:
             [NSNumber numberWithBool:SFX_LOADED] forKey:keyString];
        }
    }
}

-(void)unloadAudioForSceneWithID:(NSNumber*)sceneIDNumber {
    
    @autoreleasepool {
        
        SceneTypes sceneID = (SceneTypes)[sceneIDNumber intValue];
        
        if (sceneID == kNoSceneUninitialized) {
            return; // Nothing to unload
        }
        
        
        NSDictionary *soundEffectsToUnload = 
        [NSDictionary dictionaryWithDictionary:[self getSoundEffectsListForSceneWithID:sceneID]];
        if (soundEffectsToUnload == nil) {
            CCLOG(@"Error reading SoundEffects.plist in %@", NSStringFromSelector(_cmd));
            return;
        }
        if (managerSoundState == kAudioManagerReady) {
            // Get all of the entries and unload
            for( NSString *keyString in soundEffectsToUnload )
            {
                [soundEffectsState setObject:[NSNumber numberWithBool:SFX_NOTLOADED] forKey:keyString];
                [soundEngine unloadEffect:keyString];
                CCLOG(@"\nUnloading Audio Key:%@ File:%@", 
                      keyString,[soundEffectsToUnload objectForKey:keyString]);
                
            }
        }
    }
}

-(void)playBackgroundTrack:(NSString*)trackFileName {
    // Wait to make sure soundEngine is initialized
    if ((managerSoundState != kAudioManagerReady) &&
        (managerSoundState != kAudioManagerFailed)) {
        int waitCycles = 0;
        while (waitCycles < AUDIO_MAX_WAITTIME) {
            [NSThread sleepForTimeInterval:0.1f];
            if ((managerSoundState == kAudioManagerReady) ||
                (managerSoundState == kAudioManagerFailed)) {
                break;
            }
            waitCycles = waitCycles + 1;
        }
    }
    if (managerSoundState == kAudioManagerReady) {
        if ([soundEngine isBackgroundMusicPlaying]) {
            [soundEngine stopBackgroundMusic];
        }
        [soundEngine preloadBackgroundMusic:trackFileName];
        [soundEngine setBackgroundMusicVolume:1.0f];
        [soundEngine playBackgroundMusic:trackFileName loop:YES];
    }
}


-(void) stopBackgroundMusic{
    
    if (managerSoundState == kAudioManagerReady) {
        
        if ([soundEngine isBackgroundMusicPlaying]) {
            [soundEngine stopBackgroundMusic];
        }
    }
    
}
-(void)stopSoundEffect:(ALuint)soundEffectID {
        if (managerSoundState == kAudioManagerReady) {
            [soundEngine stopEffect:soundEffectID];
        }
    }
    
-(ALuint)playSoundEffect:(NSString*)soundEffectKey {
        ALuint soundID = 0;
        if (managerSoundState == kAudioManagerReady) {
            NSNumber *isSFXLoaded =
            [soundEffectsState objectForKey:soundEffectKey];
            if ([isSFXLoaded boolValue] == SFX_LOADED) {
                soundID =
                [soundEngine playEffect:
                 [listOfSoundEffectFiles objectForKey:soundEffectKey]];
            } else {
                CCLOG(@"GameMgr: SoundEffect %@ is not loaded.",
                      soundEffectKey);
            }
        } else {
            CCLOG(@"GameMgr: Sound Manager is not ready, cannot play %@",
                  soundEffectKey);
        }
        return soundID;
    }


-(void)resetBestScore{
    
    self.bestScore = 0;
}

#pragma mark -
#pragma mark ===  bestScore  ===
#pragma mark -

-(void)setBestScore:(int)newBestScore{
            
    NSString* score = [NSString stringWithFormat:@"%d",newBestScore];
    NSString* key = [NSString stringWithString:@"HighScore"];
    
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    [ud setObject:score forKey:key];
    [ud synchronize];
    
}

-(int)bestScore{
    
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    
    NSString * bestCurrentScore=[ud objectForKey:[NSString stringWithString:@"HighScore"]];

    int score = [bestCurrentScore intValue];
    
    return score;
}

-(void)runSceneWithID:(SceneTypes)sceneID
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];   
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    
    SceneTypes oldScene = currentScene;
    
    currentScene = sceneID;
    
    isBonusLevel = FALSE;
    
    CCLOG(@"SceneTypes:%d", sceneID);
    
    id sceneToRun = nil;
    
    switch (sceneID) {
            
        case kMainMenuScene:
            _currentLevel = 0;
            _totalScore = 0;
            isLastLevel = FALSE;
            self.isPerfect = TRUE;
            sceneToRun = [MenuScene node];
            break;
        case kIntroScene:
            _currentLevel++;
            hasPlayerDied = FALSE;
            
            _isPerfectForLevel = TRUE;
            
            isLastLevel = (_currentLevel == 12) ? TRUE : FALSE;
            patternForLevel = nil;
            if (_currentLevel == 4) {
                isBonusLevel = TRUE;
                sceneToRun = [WallScene node];
                currentScene = kBonusLevel1;
                break;
            }
            if (_currentLevel == 9) {
                isBonusLevel = TRUE;
                sceneToRun = [CarScene node];
                currentScene = kBonusLevel2;
                break;
            }
            patternForLevel = [[NSMutableArray alloc] initWithArray:[self.dao loadPlistForPatternWithLevel:_currentLevel]];
            self.namePlayer = [self formatPlayerTypeToString:_currentLevel];
            [self formatGameTime];
            sceneToRun = [IntroScene node];
            break;
        case kLevelCompleteScene:            
            sceneToRun = [EndScene node];
            break;
        case kGamelevel1:
            _currentScore = 0;
            sceneToRun = [GameScene node];
            break;
        case kBonusLevel1:
            isBonusLevel = TRUE;
            sceneToRun = [WallScene node];
            break;
        case kBonusLevel2:
            break;
        case kBonusLevel3:
            break;
        default:
            CCLOG(@"Unknown ID, cannot switch scenes");
            return;
            break;
    }
    
    if (sceneToRun == nil) {
        
        currentScene = oldScene;
        
        return;
    }
    
    [self performSelectorInBackground:
     @selector(unloadAudioForSceneWithID:)
                           withObject:[NSNumber
                                       numberWithInt: oldScene]];
    
    if ([[CCDirectorIOS sharedDirector] runningScene] == nil) {
        [[CCDirectorIOS sharedDirector] pushScene:sceneToRun];
        
    } else {
        
        [[CCDirectorIOS sharedDirector] replaceScene:sceneToRun];
    }
    
    
    [self performSelectorInBackground:
     @selector(loadAudioForSceneWithID:)
                           withObject:[NSNumber
                                       numberWithInt: currentScene]];
    
}

-(void)pauseGame{
    
    CCScene* runningScene = [[CCDirectorIOS sharedDirector] runningScene];
    
    if ([runningScene isKindOfClass:[GameScene class]]) {
        
        NSLog(@"%@ %@",self, NSStringFromSelector(_cmd));
        
        HUDLayer * hudlayer = (HUDLayer *)[runningScene getChildByTag:10];

        [hudlayer onPause:self];
    }
    
}

#pragma mark -
#pragma mark ===  Level Reached  ===
#pragma mark -


-(int)levelReached{
    
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"LevelReached"];

}

-(void)setLevelReached:(int)newLevel{
    
    [[NSUserDefaults standardUserDefaults]setInteger:newLevel forKey:@"LevelReached"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

#pragma mark -
#pragma mark ===  Tutorial  ===
#pragma mark -

-(BOOL)isTutorial{
    
    BOOL tutorial = (self.levelReached == 0) ? YES : NO;
    
    return tutorial;
}

#pragma mark -
#pragma mark ===  Game State Update  ===
#pragma mark -

-(void)updateGameState:(GameStates)newGameState{
    
    _gameState = newGameState;
    
    switch (newGameState) {
        
        case kStateThresholdReached:
            break;
        case kStateKo:
            break;
        case kStatePerfect:
            break;
        case kStateLose:
            break;
        default:
            break;
    }
    
}

#pragma mark -
#pragma mark ===  Perfect For Game  ===
#pragma mark -

-(void)setIsPerfect:(BOOL)perfect{
        
    [[NSUserDefaults standardUserDefaults] setBool:perfect forKey:@"Perfect"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)isPerfect{
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"Perfect"];
}

#pragma mark -
#pragma mark ===  Perfect For Level  ===
#pragma mark -


-(void)setIsPerfectForLevel:(BOOL)value{
    
    _isPerfectForLevel = value;
    
    if (self.isPerfect) self.isPerfect = FALSE;
}

-(BOOL)isPerfectForLevel{
    
    return _isPerfectForLevel;
}

#pragma mark -
#pragma mark ===  Ko for Game  ===
#pragma mark -

-(void)setIsKo:(BOOL)value{
    
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:@"Ko"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)isKo{
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"Ko"];
}

#pragma mark -
#pragma mark ===  Ko for Level  ===
#pragma mark -


-(void)setIsKoForLevel:(BOOL)isKoForLevel{
    
    _isKoForLevel = isKoForLevel;
    
    if (self.isKo) self.isKo = FALSE;
}

@end
