//
//  Constant.h
//  PattyCakeFighter
//
//  Created by Giuseppe Lapenta on 10/08/11.
//  Copyright 2011 Lapenta. All rights reserved.
//





///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////     Menu    /////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// GetCoins
#define kGetCoinsBackgroundTagValue 10
#define kGetCoinsBackgroundZValue 0

#define kPurchaseMenuTagValue 11
#define kPurchaseMenuZValue 2
#define kFacebookItemTagValue 4
#define kFacebookItemZValue 2
#define kFirstPurchaseItemTagValue 1
#define kFirstPurchaseItemZValue 2
#define kSecondPurchaseItemTagValue 2
#define kSecondPurchaseItemZValue 2
#define kThirdPurchaseItemTagValue 0
#define kThirdPurchaseItemZValue 2
#define kSpriteBatchNodeMenuZValue 2
#define kLabelCoinsReachedTagValue 15
#define kLabelCoinsReachedZValue 2

// Main
#define kPlayerMiaghiTagValue 12
#define kPlayerMiaghiZValue 2







#define GAMETIME 43
#define GAMETIMEBONUSLEVEL 10
#define DELAY 12
#define INTERVAL 0.50f
#define MAX_ELAPSED_TIME 0.08f
#define kPlayerTagValue 0
#define kPlayerZValue 1
#define kLeftHandZvalue 101
#define kLeftHandTagValue 1
#define kRightHandZValue 101
#define kRightHandTagValue 2
#define kBellTagValue 20
#define kHealthTagValue 21
#define kHealthZValue 2
#define kBellZValue 0
#define kLabelScoreTagValue 22
#define kResetTagValue 23
#define kHighScoreLabelTagValue 24
#define kNextLevelLabelTagValue 25
#define kLabelScoreZValue 0
#define kHandFeedRight 90
#define kHandFeedLeft 91
#define kArrow 92
#define kScore 1
#define kWallTagValue 1
#define kWallZValue 1
#define kTapForProgress 20
#define MaxZOrder 100
#define MinZOrder 2


#define kHighScoresTag 51
#define kMenuSpriteTag 52

typedef enum{
    kNoSceneUninitialized=0,
    kMainMenuScene = 1,
    kLevelCompleteScene = 2,
    kBonusLevel1 = 3,
    kBonusLevel2 = 4,
    kBonusLevel3 = 5,
    kIntroScene = 100,
    kGamelevel1 = 101,
    kGamelevel2 = 102,
    kGamelevel3 = 103,
    kGamelevel4 = 104,
    kGamelevel5 = 105,
    kGamelevel6 = 106,
    kGamelevel7 = 107,
    kGamelevel8 = 108,
    kGamelevel9 = 109,
    kGamelevel10 = 110,
} SceneTypes;


typedef enum{
    
    kPlayerMiaghi,
    kPlayerCrocodile,
    kPlayerChunLi,
    kPlayerMaa,
    kPlayerJoco,
    kPlayerJenny,
    kPlayerBud,
    kPlayerJeanPaul,
    kPlayerSteven,
    kPlayerChuck,
    
} PlayerTypes;



#define BACKGROUND_TRACK_MAIN_MENU @"MainTheme.mp3"


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////     Font    /////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#define FONTHIGHSCORES @"Highscores_font.fnt"

#define FONTFEEDBACK @"Feedback_font.fnt"


#define AUDIO_MAX_WAITTIME 120

typedef enum {
    
    kAudioManagerUninitialized=0,
    kAudioManagerFailed=1,
    kAudioManagerInitializing=2,
    kAudioManagerInitialized=100,
    kAudioManagerLoading=200,
    kAudioManagerReady=300
    
} GameManagerSoundState;


// Audio Constants
#define SFX_NOTLOADED NO
#define SFX_LOADED YES

#define PLAYSOUNDEFFECT(...) \
[[GameManager sharedGameManager] playSoundEffect:@#__VA_ARGS__]

#define STOPSOUNDEFFECT(...) \
[[GameManager sharedGameManager] stopSoundEffect:__VA_ARGS__]
