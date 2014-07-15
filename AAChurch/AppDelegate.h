//
//  AppDelegate.h
//  AAChurch
//
//  Created by Ben Gomez on 8/3/12.
//  Copyright (c) 2012 Jway Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SplashViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <Twitter/TWTweetComposeViewController.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "Config.h"


extern NSString *const FBSessionStateChangedNotification;

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, MFMailComposeViewControllerDelegate>
{
    CLLocationManager *locationManager;
    SplashViewController *splashViewController;
}

@property (strong, nonatomic) UIWindow *window;
@property (weak) UIViewController *currentVC;

@property (assign) double latitude;
@property (assign) double longitude;
@property (assign) BOOL fullScreenVideoIsPlaying;

@property (strong, nonatomic) Config *config;

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
- (void) closeSession;

- (void)doMail:(NSString *)msg;
- (void)doTwitter:(NSString *)msg;
- (void)doFacebook:(NSString *)msg;
@end
