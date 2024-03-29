//
//  AppDelegate.m
//  pattycombat
//
//  Created by Vincenzo Lapenta on 26/03/12.
//  Copyright Fratello 2012. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"

#import "GameManager.h"

#import "PattyCombatIAPHelper.h"

#import "GCHelper.h"

#import "Appirater.h"

static NSString* kAppId = @"321845184543524";

@implementation AppController

@synthesize window=window_, navController=navController_, director=director_, facebook=_facebook;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
        
    //App Purchase Init
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[PattyCombatIAPHelper sharedHelper]];
    
    //Game center Init
    
    [[GCHelper sharedInstance] authenticateLocalUser];

	// Create the main window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];


	// Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
								   depthFormat:0	//GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];

	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];

    //Audio Init
    [[GameManager sharedGameManager] setupAudioEngine];
    
    [glView setMultipleTouchEnabled:YES];
    
    // Facebook Init
    
    _facebook = [[Facebook alloc] initWithAppId:kAppId andDelegate:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        _facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        _facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    NSString *url = [NSString stringWithFormat:@"fb%@://authorize",kAppId];
    BOOL bSchemeInPlist = NO; // find out if the sceme is in the plist file.
    NSArray* aBundleURLTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    if ([aBundleURLTypes isKindOfClass:[NSArray class]] &&
        ([aBundleURLTypes count] > 0)) {
        NSDictionary* aBundleURLTypes0 = [aBundleURLTypes objectAtIndex:0];
        if ([aBundleURLTypes0 isKindOfClass:[NSDictionary class]]) {
            NSArray* aBundleURLSchemes = [aBundleURLTypes0 objectForKey:@"CFBundleURLSchemes"];
            if ([aBundleURLSchemes isKindOfClass:[NSArray class]] &&
                ([aBundleURLSchemes count] > 0)) {
                NSString *scheme = [aBundleURLSchemes objectAtIndex:0];
                if ([scheme isKindOfClass:[NSString class]] &&
                    [url hasPrefix:scheme]) {
                    bSchemeInPlist = YES;
                }
            }
        }
    }
    // Check if the authorization callback will work
    BOOL bCanOpenUrl = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString: url]];
    if (!bSchemeInPlist || !bCanOpenUrl) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Setup Error"
                                  message:@"Invalid or missing URL scheme. You cannot run the app until you set up a valid URL scheme in your .plist."
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil,
                                  nil];
        [alertView show];
    }

	director_.wantsFullScreenLayout = YES;

	// Display FSP and SPF
	[director_ setDisplayStats:NO];
    
	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];

	// attach the openglView to the director
	[director_ setView:glView];

	// for rotation and other messages
	[director_ setDelegate:self];
    
	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
//	[director setProjection:kCCDirectorProjection3D];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");

	// Create a Navigation Controller with the Director
	navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;

	// set the Navigation Controller as the root view controller
//	[window_ setRootViewController:rootViewController_];
	[window_ addSubview:navController_.view];

	// make main window visible
	[window_ makeKeyAndVisible];

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];

	// When in iPhone RetinaDisplay, iPad, iPad RetinaDisplay mode, CCFileUtils will append the "-hd", "-ipad", "-ipadhd" to all loaded files
	// If the -hd, -ipad, -ipadhd files are not found, it will load the non-suffixed version
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"
    
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

	// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
    
    [[GameManager sharedGameManager] runSceneWithID:kGinoScappelloni];
    
    [Appirater appLaunched:YES]; 

	return YES;
}

// Supported orientations: Landscape. Customize it for your own needs
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
        [[GameManager sharedGameManager] pauseGame];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
        [[GameManager sharedGameManager] resumeGame];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
        [[CCDirectorIOS sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
		[[CCDirectorIOS sharedDirector] startAnimation];
        [Appirater appEnteredForeground:YES]; 
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [_facebook handleOpenURL:url]; 
}

@end
