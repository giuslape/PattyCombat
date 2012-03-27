//
//  HUDLayer.m
//  PattyCombat
//
//  Created by Giuseppe Lapenta on 15/02/12.
//

#import "HUDLayer.h"
#import "SimpleAudioEngine.h"
#import "Constant.h"
#import "GameManager.h"


@implementation HUDLayer

@synthesize pauseButton = _pauseButton;
@synthesize delegate = _delegate;
@synthesize score = _score;
@synthesize comboMoltiplicator = _comboMoltiplicator;
@synthesize scoreLabel = _scoreLabel;


#pragma mark -
#pragma mark === Score ===
#pragma mark -

-(int)score{
    
    NSLog(@"%@ %@",self, NSStringFromSelector(_cmd));

    int signValue = (_touchIsOk) ? 1: 0;
    int signValueProgress = (_touchIsOk) ? 1 : -2;
    int moltiplicator = self.comboMoltiplicator;
    
    _barProgress += (signValueProgress * kScore * moltiplicator);
    
    if (_barProgress < 0) _barProgress = 0;
    
    _score += (signValue * kScore * moltiplicator);
    
    if (_score < 0) _score = 0;
    
    return _score;
}


-(void)setScore:(int)newScore{
    
    _score = newScore;
}


#pragma mark -
#pragma mark === Combo Moltiplicator ===
#pragma mark -

-(int)comboMoltiplicator{
    
    if (_touchIsOk)_comboMoltiplicator++;
    else _comboMoltiplicator = 1;
    
    return _comboMoltiplicator;
}

-(void)setComboMoltiplicator:(int)comboMoltiplicatorValue{
    
    _comboMoltiplicator = comboMoltiplicatorValue;
}

#pragma mark -
#pragma mark ===  Protocol Methods  ===
#pragma mark -

-(void)barDidEmpty:(GPBar *)bar{
    
    Bell* tempBell = (Bell *)[_commonElements getChildByTag:kBellTagValue];
    
    [tempBell changeState:[NSNumber numberWithInt:kStateBellGong]];
    
       
    [_delegate gameOverHandler:bar.characterState withScore:[NSNumber numberWithInt:_score] andPlayerIsDead:([bar progress] > _threshold ? YES : NO) fromLayer:self];
    
    }


-(void)bellDidFinish:(Bell *)bell{
    
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    [_delegate gameOverHandler:bell.characterState withScore:[NSNumber numberWithInt:_score] andPlayerIsDead:(_barProgress > _threshold ? YES : NO) fromLayer:self];
    
}


#pragma mark -
#pragma mark ===  Update Methods  ===
#pragma mark -

-(void)updateStateWithDelta:(ccTime)deltaTime{
    
    GameCharacter* bellChar = (GameCharacter*)[_commonElements getChildByTag:kBellTagValue];
    
    [bellChar updateStateWithDeltaTime:deltaTime];
    
}

-(void)updateHealthBar:(BOOL)touch{
   
    NSLog(@"%@ %@",self, NSStringFromSelector(_cmd));

    _touchIsOk = touch;
    
    GPBar* bar = (GPBar *)[self getChildByTag:kHealthTagValue];
    
    int currentScore = self.score;
            
    if (_touchIsOk) [_scoreLabel setString:[NSString stringWithFormat:@"%d",currentScore]];
    
    [bar setProgress:_barProgress];
    
}


#pragma mark -
#pragma mark ===  Init Methods  ===
#pragma mark -


-(void)createObjectOfType:(GameObjectType)objectType 
               atLocation:(CGPoint)spawnLocation
               withZValue:(int)ZValue{
    
    
    if (kObjectTypeBell == objectType) {
        
        CCLOG(@"Creating the Bell");
        Bell* bell = [Bell spriteWithSpriteFrameName:@"gong0001.png"];
        [bell setPosition:spawnLocation];
        [_commonElements addChild:bell z:ZValue tag:kBellTagValue];
        
        [bell setDelegate:self];
    }
    if (kObjectTypeHealth == objectType) {
        
        NSString* namePlayer = [[GameManager sharedGameManager] formatPlayerNameTypeToString];
        GPBar* bar = [GPBar barWithBar:@"bar_red.png" inset:@"bar_background.png" mask:@"bar_mask.png"]; 
        [bar setPosition:spawnLocation];
        [self  addChild:bar z:ZValue tag:kHealthTagValue];
        
        [bar setDelegate:self];
        
        CCLabelBMFont* namePlayerLabel = [CCLabelBMFont labelWithString:namePlayer fntFile:FONTLETTERS];
        [namePlayerLabel setPosition:ccp(240, 290)];
        [namePlayerLabel setScale:0.5];
        [self addChild:namePlayerLabel z:3];
    }
    if (kObjectTypeScoreLabel == objectType){
        
        _scoreLabel = [CCLabelBMFont labelWithString:@"0" fntFile:FONTNUMBERS];
        
        [self addChild:_scoreLabel z:ZValue tag:kLabelScoreTagValue];
        [_scoreLabel setAnchorPoint:ccp(1, 0)];
        [_scoreLabel setPosition:spawnLocation];
        [_scoreLabel setScale:1.5];
        
        
    }
    
}

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        _threshold = 60;
                
        _score = 0;
        
        _barProgress = 0;
        
        CGSize winSize = [[CCDirectorIOS sharedDirector]winSize];
        
        isPause = FALSE;
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithString:@"Common.plist"]];
        
        _commonElements = [CCSpriteBatchNode batchNodeWithFile:@"Common.png"];
        
        [self addChild:_commonElements];
                        
        [self createObjectOfType:kObjectTypeBell
                      atLocation:ccp(40,295) 
                      withZValue:kBellZValue];
        
        [self createObjectOfType:kObjectTypeHealth
                      atLocation:ccp(0, 140)
                      withZValue:kHealthZValue];
        
        [self createObjectOfType:kObjectTypeScoreLabel
                      atLocation:ccp(945/2, winSize.height - 46)
                      withZValue:kLabelScoreZValue];
        
        
        _pauseButton = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"pause_btn.png"]];
        
        [_commonElements addChild:_pauseButton z:10 tag:11];
        
        _pauseButton.position = ccp(winSize.width - 20, 20);

        
    }
    return self;
}

#pragma mark -
#pragma mark ===  Events Handler  ===
#pragma mark -


-(void)onPause:(id)sender{
    
    if (!isPause) {
        
    isPause = TRUE;
        
    CGSize winSize = [[CCDirectorIOS sharedDirector]winSize];
    
    NSLog(@"on pause");
    
    [[CDAudioManager sharedManager] pauseBackgroundMusic];
        
    [[CCDirectorIOS sharedDirector] pause];
            
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
    
    CCMenuItemImage* resume = [CCMenuItemImage itemWithNormalImage:@"resume_btn.png" selectedImage:@"resume_btn.png" target:self selector:@selector(resumeGame:)];
    
    CCMenuItemImage* restart = [CCMenuItemImage itemWithNormalImage:@"restart_btn.png" selectedImage:@"restart_btn.png" target:self selector:@selector(restartTapped:)];
    
    CCMenuItemImage* mainMenu = [CCMenuItemImage itemWithNormalImage:@"main_menu_btn.png" selectedImage:@"main_menu_btn.png" target:self selector:@selector(mainMenu:)];
    
    CCMenu *pauseMenu = [CCMenu menuWithItems:resume,restart,mainMenu, nil];
    
    [pauseMenu alignItemsVerticallyWithPadding:20];
    
    [self addChild:pauseMenu z:10 tag:10];
    
    pauseMenu.position = ccp(winSize.width/2,winSize.height/2);
    
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
            
    }

}

-(void)resumeGame:(id)sender{
    
    isPause = FALSE;
    
    CCMenu* pauseMenu = (CCMenu *)[self getChildByTag:10];
    
    
    [self removeChild: pauseMenu cleanup:YES]; 
        
    [[CCDirectorIOS sharedDirector] resume];
    [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
    
}

-(void)mainMenu:(id)sender{
    
    CCMenu* pauseMenu = (CCMenu *)[self getChildByTag:10];
    
    CCLayerColor* pauseLayer = (CCLayerColor *)[self getChildByTag:9];
    
    [self removeChild: pauseMenu cleanup:YES]; 
    [self removeChild: pauseLayer cleanup:YES];
    
    [[CCDirectorIOS sharedDirector] resume];
    [[CDAudioManager sharedManager] stopBackgroundMusic];
    [[GameManager sharedGameManager] runSceneWithID:kMainMenuScene];
    
}

-(void)restartTapped:(id)sender{
    
    
    CCMenu* pauseMenu = (CCMenu *)[self getChildByTag:10];
    
    CCLayerColor* pauseLayer = (CCLayerColor *)[self getChildByTag:9];
    
    [self removeChild: pauseMenu cleanup:YES]; 
    [self removeChild: pauseLayer cleanup:YES]; 
    
    
    [[CCDirectorIOS sharedDirector] resume];
    [[CDAudioManager sharedManager] stopBackgroundMusic];
    [[GameManager sharedGameManager] runSceneWithID:kGamelevel1];
}

#pragma mark -
#pragma mark ===  Dealloc  ===
#pragma mark -


- (void)dealloc {
    
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), self);
    
    _commonElements = nil;
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];

}



@end
