//
//  CommonProtocols.h
//  PattyCakeFighter
//
//  Created by Giuseppe Lapenta on 10/08/11.
//  Copyright 2011 Lapenta. All rights reserved.
//
typedef enum{
    
    kStateSpawning,
    kStateRightHandOpen,
    kStateLeftHandOpen,
    kStateLeftHandClose,
    kStateRightHandClose,
    kStateTwoHandsAreOpen,
    kStateTwoHandsAreClosed,
    kStateLeftCrossHandOpen,
    kStateLeftCrossHandClose,
    kStateRightCrossHandOpen,
    kStateRightCrossHandClose,
    kStateLeftCrossHandHit,
    kStateRightCrossHandHit,
    kStateNone,
    kStateDead,
    kStateIdle,
    kStateLeftHandHit,
    kStateRightHandHit,
    kStateTwoHandsHit,
    kStateHitBackground,
    kStateOneTouchWaiting,
    kStateHealthIsEmpty,
    kStateHealthUpThreshold,
    kStateHealthIdle
}CharacterStates;

typedef enum{
    
    kStateBellUpdate,
    kStateBellGongFinish,
    kStateBellStart,
    kStateBellFinish,
    
}BellStates;


typedef enum{
    
    kObjectTypeNone,
    kObjectLeftHand,
    kObjectRightHand,
    kObjectTypePlayer,
    kObjectTypeBell,
    kObjectTypeHealth,
    kObjectTypeScoreLabel
    
}GameObjectType;


@protocol GameplayLayerDelegate
-(void)createObjectOfType:(GameObjectType)objectType 
               atLocation:(CGPoint)spawnLocation 
               withZValue:(int)ZValue;

@end

@protocol PlayerDelegate

-(void)didPlayerChangeHands:(BOOL)handIsTouched;
-(void)didPlayerHasTouched:(BOOL)handsIsTouched;
-(void)didPlayerOpenHand:(CharacterStates)states;

@end


@protocol SceneDao <NSObject>

-(NSDictionary *)loadScene:(int)sceneNumber;
-(id)loadPlistForAnimationWithName:(NSString*)animationName andClassName:(NSString*)className;
-(NSMutableArray*)loadPlistForPatternWithLevel:(int)sceneId;
-(NSDictionary *)loadPlayerWithName:(NSString *)name;

@optional
-(NSString*)loadBackgroundIntro:(NSString*)className atLevel:(int)currentLevel;
-(NSString*)loadBackgroundGame:(NSString*)className atLevel:(int)currentLevel;
-(NSString*)loadBackgroundEnd:(NSString*)className atLevel:(int)currentLevel andWin:(BOOL)win;




@end