//
//  HUDLayer.h
//  PattyCombat
//

//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Bell.h"
#import "GPBar.h"

@protocol HUDDelegate <NSObject>

-(void)gameOverHandler:(CharacterStates)gameOverState withScore:(NSNumber *)score andPlayerIsDead:(BOOL)playerIsDead fromLayer:(id)layer ;

@end

@interface HUDLayer : CCLayer  <BellDelegate, GPBarDelegate>{
    
    CCSprite* _pauseButton;
    CCLabelBMFont* _scoreLabel;
    CCSpriteBatchNode* _commonElements;
    
    __weak id <HUDDelegate> _delegate;
    
    BOOL isPause;    
    BOOL _touchIsOk;

    int _score;
    int _barProgress;
    int _comboMoltiplicator;
    int _threshold;
    
}

@property(nonatomic, strong) CCSprite* pauseButton;
@property(nonatomic, strong) CCLabelBMFont* scoreLabel;
@property(nonatomic, weak) id <HUDDelegate> delegate;
@property (readwrite) int score;
@property (readwrite) int comboMoltiplicator;




-(void)onPause:(id)sender;

-(void)resumeGame:(id)sender;

-(void)mainMenu:(id)sender;

-(void)restartTapped:(id)sender;

-(void)updateStateWithDelta:(ccTime)deltaTime;

-(void)barDidEmpty:(GPBar *)bar;

-(void)bellDidFinish:(Bell *)bell;

-(void)updateHealthBar:(BOOL)touch;

@end