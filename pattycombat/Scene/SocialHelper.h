//
//  SocialHelper.h
//  pattycombat
//
//  Created by Vincenzo Lapenta on 29/06/12.
//  Copyright (c) 2012 Fratello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

@interface SocialHelper : NSObject <FBSessionDelegate, FBDialogDelegate>

+(SocialHelper *)sharedHelper;

-(void)loginToFacebook:(id)sender;
-(void)postOnTwitter:(id)sender;

@end
