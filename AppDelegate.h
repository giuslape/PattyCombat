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

#if __has_feature(objc_arc_weak)
    CCDirectorIOS	*  __weak director_;	// weak ref
#elif __has_feature(objc_arc)
    CCDirectorIOS   * __unsafe_unretained director_;
#else
    CCDirectorIOS   * director_;
#endif
     Facebook* _facebook;
}

@property (nonatomic) UIWindow *window;
@property (readonly) UINavigationController *navController;

#if __has_feature(objc_arc_weak)
@property (readonly, weak) CCDirectorIOS *director;

#elif __has_feature(objc_arc)
@property (readonly, unsafe_unretained) CCDirectorIOS *director;

#else
@property (readonly, assign) CCDirectorIOS *director;
#endif

@property (nonatomic, strong)Facebook* facebook;

@end
