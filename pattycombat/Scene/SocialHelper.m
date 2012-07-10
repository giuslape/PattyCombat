//
//  SocialHelper.m
//  pattycombat
//
//  Created by Vincenzo Lapenta on 29/06/12.
//  Copyright (c) 2012 Fratello. All rights reserved.
//

#import "SocialHelper.h"
#import <Twitter/Twitter.h>
#import "AppDelegate.h"
#import "PattyCombatIAPHelper.h"

@interface SocialHelper (){
    
    NSArray* _permissions;

}

@end

@implementation SocialHelper

static SocialHelper * _sharedHelper;

+(SocialHelper *)sharedHelper{
    
    if (_sharedHelper != nil) {
        return _sharedHelper;
    }
    _sharedHelper = [[SocialHelper alloc] init];
    return _sharedHelper;
    
}


- (id)init
{
    AppController* dele = (AppController *)[[UIApplication sharedApplication] delegate];
    
    [[dele facebook] setSessionDelegate:self];
    
    return self;
}

#pragma mark -
#pragma mark ===  Facebook Delegate  ===
#pragma mark -

- (void)storeAuthData:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
}


//Callback login on Facebook

- (void)fbDidLogin {
    
    AppController* dele = (AppController *)[[UIApplication sharedApplication] delegate];
    
    [self storeAuthData:[[dele facebook] accessToken] expiresAt:[[dele facebook] expirationDate]];
    
    [self postToFacebook:self];
    
}
-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    
    NSLog(@"token extended");
    [self storeAuthData:accessToken expiresAt:expiresAt];
}


// Called when the user canceled the authorization dialog.

-(void)fbDidNotLogin:(BOOL)cancelled {
    
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
}


// Called when the request logout has succeeded.

- (void)fbDidLogout {
    
    // Remove saved authorization information if it exists and it is
    // ok to clear it (logout, session invalid, app unauthorized)
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
}


// * Called when the session has expired.

- (void)fbSessionInvalidated {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Auth Exception"
                              message:@"Your session has expired."
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil,
                              nil];
    [alertView show];
    [self fbDidLogout];
}


// Call when button is pressed 

-(void)loginToFacebook:(id)sender{
    
    _permissions = [[NSArray alloc] initWithObjects:@"offline_access",@"publish_stream",nil];
    
    AppController* dele = (AppController *)[[UIApplication sharedApplication] delegate];
    
    if (![[dele facebook] isSessionValid]) {
        
        [[dele facebook] authorize:_permissions];
        
    }else {
        
        [self postToFacebook:self];
    }
    
    
}


-(void)postToFacebook:(id)sender{
    
    SBJSON *jsonWriter = [SBJSON new];
    
    // The action links to be shown with the post in the feed
    NSArray* actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                                      @"Get Started",
                                                      @"name",
                                                      @"http://bit.ly/HwglVX",
                                                      @"link",
                                                      @"I'm enjoying to be a PattyCombat beta tester. Wanna join the Patty Team? http://bit.ly/HwglVX",
                                                      @"message", nil], nil];
    
    NSString *actionLinksStr = [jsonWriter stringWithObject:actionLinks];
    
    // Dialog parameters
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"I'm Patty Combat beta tester", @"name",
                                   @"Patty Combat.", @"caption",
                                   @"I'm enjoying to be a PattyCombat beta tester. Wanna join the Patty Team? http://bit.ly/HwglVX", @"message",
                                   @"I'm enjoying to be a PattyCombat beta tester. Wanna join the Patty Team? http://bit.ly/HwglVX", @"description",
                                   @"http://bit.ly/HwglVX", @"link",
                                   @"http://www.balzo.eu/wp-content/uploads/2012/04/iTunesArtwork.png", @"picture",
                                   actionLinksStr, @"actions",
                                   nil];
    
    AppController* dele = (AppController *)[[UIApplication sharedApplication] delegate];
    
    [[dele facebook] dialog:@"feed"
                    andParams:params
                    andDelegate:self];
}


#pragma mark -
#pragma mark ===  Facebook Dialog Delegate  ===
#pragma mark -

// Called when dialog is finish

- (void)dialogCompleteWithUrl:(NSURL *)url {
    
    if (![url query]) {
        NSLog(@"User canceled dialog or there was an error");
        return;
    }
    
    [self updateForSocialCoins:@"Facebook"];
    // Test Flight
    
    [TestFlight passCheckpoint:@"Post su Facebook"];
    
    NSLog(@"Dialog Complete");
}

- (void)dialogDidNotComplete:(FBDialog *)dialog {
    
    NSLog(@"Dialog dismissed.");
}

- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError *)error {
    NSLog(@"Error message: %@", [[error userInfo] objectForKey:@"error_msg"]);
    //[self showMessage:@"Oops, something went haywire."];
}



#pragma mark -
#pragma mark ===  Twitter  ===
#pragma mark -

-(void)postOnTwitter:(id)sender{
    
    // Test Flight
    [TestFlight passCheckpoint:@"Post su Twitter"];
    TFLog(@"Post su twitter");
    
    if ([TWTweetComposeViewController canSendTweet])
    {
        TWTweetComposeViewController *tweetSheet =
        [[TWTweetComposeViewController alloc] init];
        tweetSheet.completionHandler = ^(TWTweetComposeViewControllerResult
                                         result){
            if (result == TWTweetComposeViewControllerResultCancelled)
            {
                NSLog(@"Cancelled the Tweet");
            }
            else
            {
                [self updateForSocialCoins:@"Twitter"];
            }
            [[CCDirectorIOS sharedDirector] dismissModalViewControllerAnimated:YES];
            
        };
        [tweetSheet setInitialText:
         [NSString stringWithFormat:@"I'm enjoying to be a #PattyCombat beta tester. Wanna join the Patty Team? http://bit.ly/HwglVX"]];
        [[CCDirectorIOS sharedDirector] presentViewController:tweetSheet animated:YES completion:^{
            
            NSLog(@"Completato");
        }];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
     
}

#pragma mark -
#pragma mark ===  Check if is First Post  ===
#pragma mark -

-(void)updateForSocialCoins:(NSString *)social{
    
    BOOL isFirstPost = [[NSUserDefaults standardUserDefaults] boolForKey:@"FirstPostFacebook"]; 
    
    if (!isFirstPost && [social isEqualToString:@"Facebook"]) {
        isFirstPost = YES;
        [[NSUserDefaults standardUserDefaults] setBool:isFirstPost forKey:@"FirstPostFacebook"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Social" object:nil];
        [[PattyCombatIAPHelper sharedHelper] updateQuantityForProductIdentifier:kProductPurchaseSocialCoins];
    }
    
    isFirstPost = [[NSUserDefaults standardUserDefaults] boolForKey:@"FirstPostTw"];
    
    if (!isFirstPost && [social isEqualToString:@"Twitter"]) {
        isFirstPost = YES;
        [[NSUserDefaults standardUserDefaults] setBool:isFirstPost forKey:@"FirstPostTw"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Social" object:nil];
        [[PattyCombatIAPHelper sharedHelper] updateQuantityForProductIdentifier:kProductPurchaseSocialCoins];
    }
}




@end
