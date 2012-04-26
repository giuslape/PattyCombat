//
//  SceneDaoPlist.h
//  PattyCombat
//
//  Created by Giuseppe Lapenta on 07/10/11.
//  Copyright 2011 Lapenta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonProtocols.h"
#import "cocos2d.h"

@interface SceneDaoPlist : NSObject <SceneDao> 
{
    
}

-(NSDictionary *)loadScene:(int)sceneNumber;
-(CCAnimation*)loadPlistForAnimationWithName:(NSString*)animationName andClassName:(NSString*)className;
-(NSMutableArray*)loadPlistForPatternWithLevel:(int)sceneId andIsExtreme:(BOOL)isExtreme;
-(NSString*)loadBackgroundIntro:(NSString*)className atLevel:(int)currentLevel;
-(NSDictionary *)loadPlayerWithName:(NSString *)name;



@end
