//
//  AppDelegate.h
//  pattycombat
//
//  Created by Vincenzo Lapenta on 26/03/12.
//  Copyright Fratello 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "Facebook.h"

@interface AppController : NSObject <UIApplicationDelegate, CCDirectorDelegate>
{
	UIWindow *window_;
	UINavigationController *navController_;

	 CCDirectorIOS	*  __weak director_;	// weak ref
     Facebook* _facebook;
}

@property (nonatomic) UIWindow *window;
@property (readonly) UINavigationController *navController;
@property (weak, readonly) CCDirectorIOS *director;
@property (nonatomic, strong)Facebook* facebook;

@end
