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
#define kGetCoinsBackgroundZValue 1

#define kPurchaseMenuTagValue 24
#define kPurchaseMenuZValue 3
#define kFacebookItemTagValue 4
#define kFacebookItemZValue 3
#define kFirstPurchaseItemTagValue 1
#define kFirstPurchaseItemZValue 3
#define kSecondPurchaseItemTagValue 2
#define kSecondPurchaseItemZValue 3
#define kThirdPurchaseItemTagValue 3
#define kThirdPurchaseItemZValue 3
#define kLabelCoinsReachedTagValue 25
#define kLabelCoinsReachedZValue 3

// Main Menu

#define kMainMenuBackgroundTagValue 11
#define kMainMenuBackgroundZValue 1
#define kCreditsBackgroundTagValue 17
#define kCreditsBackgroundZValue 3
#define kPlayerMiaghiTagValue 12
#define kPlayerMiaghiZValue 3
#define kItemPlayNodeTagValue 13
#define kItemPlayNodeZValue 3
#define kItemGetCoinsTagValue 14
#define kItemGetCoinsZValue 3
#define kItemStatsTagValue 15
#define kItemStatsZValue 3
#define kItemCreditsTagValue 16
#define kItemCreditsZValue 3
#define kMainMenuTagValue 18
#define kMainMenuZValue 3
#define kPattyCombatLogoTagValue 19
#define kPattyCombatLogoZValue 3

// Stats Menu

#define kStatsBackgroundTagValue 20
#define kStatsBackgroundZValue 1
#define kHighScoreLabelTagValue 21
#define kHighScoreLabelZValue 3
#define kLevelReachedValueTagValue 22
#define kLevelReachedValueZValue 3
#define kResetTagValue 23
#define kResetZValue 3


// Dark Layer

#define kDarkLayerTagValue 24
#define kDarkLayerZValue 2


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////   Intro   ///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#define kSpriteBatchNodeIntroTagValue 10
#define kSpriteBatchNodeIntroZValue 3
#define kHandFeedRightTagValue 11
#define kHandFeedRightZValue 3
#define kHandFeedLeftTagValue 12
#define kHandFeedLeftZValue 3
#define kArrowFeedTagValue 13
#define kLeftHandTagValue 14
#define kLeftHandZvalue 1
#define kRightHandZValue 1
#define kRightHandTagValue 15
#define kFightButtonTagValue 16
#define kFightButtonZValue 1
#define kDarkLayerIntroTagValue 17
#define kDarkValueIntroZValue 3
#define kLabelTutorialTagValue 18
#define kLabelTutorialZValue 3
#define kArrowLeftTutorialTagValue 19
#define kArrowRightTutorialTagValue 20
#define kArrowsTutorialZValue 3


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////   Game    ///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#define kBellTagValue 20
#define kBellZValue 1
#define kHealthTagValue 21
#define kHealthZValue 1
#define kPauseMenuTagValue 22
#define kPauseMenuZValue 1
#define kLabelScoreTagValue 23
#define kLabelScoreZValue 1
#define kLabelReadyTagValue 24
#define kLabelReadyZValue 1





#define GAMETIME 43
#define GAMETIMEBONUSLEVEL 10
#define DELAY 12
#define INTERVAL 0.50f
#define MAX_ELAPSED_TIME 0.08f


#define kPlayerTagValue 0
#define kPlayerZValue 1

#define kNextLevelLabelTagValue 25

#define kScore 1
#define kWallTagValue 1
#define kWallZValue 1
#define kTapForProgress 20
#define MaxZOrder 100
#define MinZOrder 2

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
