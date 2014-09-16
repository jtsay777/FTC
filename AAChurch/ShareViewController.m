//
//  ShareViewController.m
//  Apostolic
//
//  Created by Ben Gomez on 10/8/12.
//  Copyright (c) 2012 Jway Group. All rights reserved.
//

#import "ShareViewController.h"
#import <FacebookSDK/FacebookSDK.h>



@interface ShareViewController ()

@end

@implementation ShareViewController


- (void)cancelButtonAction:(UIButton *)button
{
    NSLog(@"Enter %s", __PRETTY_FUNCTION__);
    
    [[self presentingViewController]
     dismissModalViewControllerAnimated:YES];
}

- (void)shareButtonAction:(UIButton *)button
{
    NSLog(@"Enter %s", __PRETTY_FUNCTION__);
    
    /*
    // Hide keyboard if showing when button clicked
    if ([self.postMessageTextView isFirstResponder]) {
        [self.postMessageTextView resignFirstResponder];
    }
    // Add user message parameter if user filled it in
    if (![self.postMessageTextView.text
          isEqualToString:kPlaceholderPostMessage] &&
        ![self.postMessageTextView.text isEqualToString:@""]) {
        [self.postParams setObject:self.postMessageTextView.text
                            forKey:@"message"];
    }
    */
    
    /*
    // Ask for publish_actions permissions in context
    if ([FBSession.activeSession.permissions
         indexOfObject:@"publish_actions"] == NSNotFound) {
        NSLog(@"path 1");
        // No permissions found in session, ask for it
        [FBSession.activeSession
         reauthorizeWithPublishPermissions:
         [NSArray arrayWithObject:@"publish_actions"]
         defaultAudience:FBSessionDefaultAudienceFriends
         completionHandler:^(FBSession *session, NSError *error) {
             if (!error) {
                 // If permissions granted, publish the story
                 NSLog(@"path 3");
                 //[self publishStory];
             }
         }];
    } else {
        // If permissions present, publish the story
        NSLog(@"path 2");
        //[self publishStory];
    }
    */
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        /*
        self.postParams =
        [[NSMutableDictionary alloc] initWithObjectsAndKeys:
         @"https://developers.facebook.com/ios", @"link",
         @"https://developers.facebook.com/attachment/iossdk_logo.png", @"picture",
         @"Facebook SDK for iOS", @"name",
         @"Build great social apps and get more installs.", @"caption",
         @"The Facebook SDK for iOS makes it easier and faster to develop Facebook integrated iOS apps.", @"description",
         nil];
         */
        self.postParams =
        [[NSMutableDictionary alloc] initWithObjectsAndKeys:
         @"https://developers.facebook.com/ios", @"link",
         @"https://developers.facebook.com/attachment/iossdk_logo.png", @"picture",
         @"Facebook SDK for iOS", @"name",
         @"Build great social apps and get more installs.", @"caption",
         @"The Facebook SDK for iOS makes it easier and faster to develop Facebook integrated iOS apps.", @"description",
         nil];

       }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(cancelButtonAction:)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"Cancel" forState:UIControlStateNormal];
    button.frame = CGRectMake(5.0, 5.0, 64.0, 36.0);
    [self.view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(shareButtonAction:)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"Share" forState:UIControlStateNormal];
    button.frame = CGRectMake(320-5.0-64, 5.0, 64.0, 36.0);
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
}
@end
