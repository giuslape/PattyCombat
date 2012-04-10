//
//  LoadingScene.h
//  pattycombat
//
//  Created by Giuseppe Lapenta on 10/04/12.
//  Copyright (c) 2012 Fratello. All rights reserved.
//

#import "cocos2d.h"
#import "Constant.h"

@interface LoadingScene : CCScene
{
    
    SceneTypes _scene;
    
    CCSpriteBatchNode* _spriteBatchNode;
}

+(id) sceneWithTargetScene:(SceneTypes)targetScene;
-(id) initWithTargetScene:(SceneTypes)targetScene;


@end
