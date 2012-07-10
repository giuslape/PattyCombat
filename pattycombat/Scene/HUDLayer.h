//
//  HUDLayer.h
//  PattyCombat
//

//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Bell.h"
#import "GPBar.h"
#import "UIAlertTableView.h"


@class HUDLayer;

@protocol HUDDelegate <NSObject>

-(void)gameOverHandler:(CharacterStates)gameOverState withScore:(NSNumber *)score;
-(void)pauseDidEnter:(HUDLayer *)layer;
-(void)pauseDidExit:(HUDLayer*)layer;

@end

@interface HUDLayer : CCLayer  <BellDelegate, GPBarDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    
    UIAlertTableView* _alert;
    CCSprite* _pauseButton;
    CCLabelBMFont* _scoreLabel;
    CCSpriteBatchNode* _commonElements;
    NSString* _productId;
    
    bool  _helpAlert;
    
#if __has_feature(objc_arc_weak)
    __weak id <HUDDelegate> _delegate;
#elif __has_feature(objc_arc)
    __unsafe_unretained id <HUDDelegate> _delegate;
#else
     id <HUDDelegate> _delegate;  
#endif
    
    BOOL isPause;    
    BOOL _touchIsOk;

    int _score;
    int _barProgress;
    int _comboMoltiplicator;
    int _threshold;
    
}

@property(nonatomic, strong) CCSprite* pauseButton;
@property(nonatomic, strong) CCLabelBMFont* scoreLabel;
@property (readwrite) int score;
@property (readwrite) int comboMoltiplicator;

#if __has_feature(objc_arc_weak)
@property(nonatomic, weak) id <HUDDelegate> delegate;
#elif __has_feature(objc_arc)
@property (nonatomic, unsafe_unretained) id <HUDDelegate> delegate;
#else
@property (nonatomic, assign) id <HUDDelegate> delegate;
#endif



-(void)onPause:(id)sender;

-(void)resumeGame:(id)sender;

-(void)mainMenu:(id)sender;

-(void)restartTapped:(id)sender;

-(void)updateStateWithDelta:(ccTime)deltaTime;

-(void)barDidEmpty:(GPBar *)bar;

-(void)bellDidFinishTime:(Bell *)bell;

-(void)updateHealthBar:(BOOL)touch;

@end
