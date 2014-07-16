//
//  AppDelegate.m
//  AAChurch
//
//  Created by Ben Gomez on 8/3/12.
//  Copyright (c) 2012 Jway Group. All rights reserved.
//

#import "AppDelegate.h"
#import "GDataXMLNode.h"

#define SPLASHSCREEN_DELAY 3

NSString *const FBSessionStateChangedNotification =
@"com.jway.aachurch.Login:FBSessionStateChangedNotification";

@interface AppDelegate () {    
    TWTweetComposeViewController *_tweetSheet;
    NSString *lastPost;
}
@end

@implementation AppDelegate

@synthesize latitude, longitude;

- (void)doMail:(NSString *)msg
{
    NSLog(@"Enter: %s", __PRETTY_FUNCTION__);
    
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        
        [picker setSubject:@"Apostolic Assembly sharing"];
        // Fill out the email body text
        NSString *emailBody = msg;
        emailBody = [emailBody stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
        NSMutableString *html = [NSMutableString string];
        [html appendString:@"<html><body><p>"];
        [html appendString:emailBody];
        [html appendString:@"</p>"];
        //[html appendString:@"<p>Download <a href=\"http://itunes.apple.com/us/app/mobyoffers/id505632114?mt=8\">MobyOffers</a> from the App Store to get this coupon.</p></body></html>"];
        
        //[picker setMessageBody:emailBody isHTML:NO];
        [picker setMessageBody:html isHTML:YES];
        
        [self.currentVC presentModalViewController:picker animated:YES];
        //[picker release];
        //[emailArray release];
        
    }
    else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Information"
                                                          message:@"You need to set up an email account to be able to send an email."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];
        //[message release];
        
    }

}

- (int) getSystemVersionAsAnInteger{
    int index = 0;
    int version = 0;
    
    NSArray* digits = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    NSEnumerator* enumer = [digits objectEnumerator];
    NSString* number;
    while (number = [enumer nextObject]) {
        if (index>2) {
            break;
        }
        int multipler = powf(100, 2-index);
        version += [number intValue]*multipler;
        index++;
    }
    return version;
}

- (void)doTwitter:(NSString *)msg
{
    int version = [self getSystemVersionAsAnInteger];
    
    if (version >= __IPHONE_5_0) {
        if (_tweetSheet == nil) {
            // Make an instance
            _tweetSheet = [[TWTweetComposeViewController alloc] init];
            
            // Specify the completion handler
            TWTweetComposeViewControllerCompletionHandler completionHandler =
            ^(TWTweetComposeViewControllerResult result) {
                
                [self.currentVC dismissModalViewControllerAnimated:YES];
                
            };
            
            [_tweetSheet setCompletionHandler:completionHandler];
        }
        
        BOOL allowed;
        NSString *twitterInfo;
        
        twitterInfo = msg;
        allowed = [_tweetSheet setInitialText:twitterInfo];
        
        if (allowed) {
            //NSLog(@"\nabout to Twitter! original text's length= %d\n, reduced text's length = %d", [offerInfoForTwitter length], [twitterInfo length]);(somehow crash?)
            
            //[_tweetSheet addURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/mobyoffers/id505632114?mt=8"]];
            [self.currentVC presentModalViewController:_tweetSheet animated:YES];
        }
    }
    else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Information"
                                                          message:@"You need to have iOS 5 or greater to be able to use Twitter message posting."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];
        //[message release];
        
    }

}

- (void)publishStory:(NSString *)msg
{
    
    NSDictionary *params = [NSDictionary dictionaryWithObject:msg forKey:@"message"];
    
    [FBRequestConnection
     startWithGraphPath:@"me/feed"
     parameters:params//parameters:self.postParams (both formats work)
     HTTPMethod:@"POST"
     completionHandler:^(FBRequestConnection *connection,
                         id result,
                         NSError *error) {
         NSString *alertText;
         if (error) {
             alertText = [NSString stringWithFormat:
                          @"error: domain = %@, code = %d",
                          error.domain, error.code];
         } else {
             //alertText = [NSString stringWithFormat:@"Posted action, id: %@", [result objectForKey:@"id"]];
             alertText = @"Post to Facebook done.";
             
             // Show the result in an alert
             [[[UIAlertView alloc] initWithTitle:@"Result"
                                         message:alertText
                                        delegate:self
                               cancelButtonTitle:@"OK!"
                               otherButtonTitles:nil]
              show];

             
         }
      }];
}

-(void)doFacebookPost:(NSString *)msg {
    
    // Ask for publish_actions permissions in context
    if ([FBSession.activeSession.permissions
         indexOfObject:@"publish_actions"] == NSNotFound) {
        // No permissions found in session, ask for it
        [FBSession.activeSession
         reauthorizeWithPublishPermissions:
         [NSArray arrayWithObject:@"publish_actions"]
         defaultAudience:FBSessionDefaultAudienceFriends
         completionHandler:^(FBSession *session, NSError *error) {
             if (!error) {
                 // If permissions granted, publish the story
                 [self publishStory:msg];
             }
         }];
    } else {
        // If permissions present, publish the story
        [self publishStory:msg];
    }
    
}

- (void)doFacebookIOS6:(NSString *)msg
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
            if (result == SLComposeViewControllerResultCancelled) {
                
                NSLog(@"ResultCancelled");
                
            } else
                
            {
                NSLog(@"Success");
            }
            
            [controller dismissViewControllerAnimated:YES completion:Nil];
        };
        controller.completionHandler =myBlock;
        
        //[controller setInitialText:@"Learn iOS6 Social Framework integration"];
        //[controller addURL:[NSURL URLWithString:@"http://www.yashesh87.wordpress.com"]];
        //[controller addImage:[UIImage imageNamed:@"salmantiger.jpeg"]];
        
        [controller setInitialText:msg];
        
        [self.currentVC presentViewController:controller animated:YES completion:Nil];
        
    }
    else{
        
        NSLog(@"UnAvailable");
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Facebook Login Required"
                                                          message:@"To enable Facebook sharing in app simply go to your iOS Settings and sign in."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];

    }

}

- (void)doFacebook:(NSString *)msg
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
    {
        NSLog(@"Running in IOS-6");
        [self doFacebookIOS6:msg];
        return;
    }
    else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Information"
                                                          message:@"You need to have iOS 6 or greater to be able to use Facebook message posting."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];
        return;
    }

    // If the user is authenticated, log out when the button is clicked.
    // If the user is not authenticated, log in when the button is clicked.
    if (FBSession.activeSession.isOpen) {
        if ([msg isEqualToString:lastPost]) {
            [[[UIAlertView alloc] initWithTitle:@"Posting Notice"
                                        message:@"The same content has been posted already."
                                       delegate:self
                              cancelButtonTitle:@"OK!"
                              otherButtonTitles:nil]
             show];

        } else {
            //[appDelegate closeSession];//disable by Johnson
            //can we do post here?
            NSLog(@"\ntry to do a posting!!\n");
            [self doFacebookPost:msg];
            lastPost = msg;
        }
    } else {
        // The user has initiated a login, so call the openSession method
        // and show the login UX if necessary.
        [self openSessionWithAllowLoginUI:YES];
        NSLog(@"\ncheck point03\n");
    }

}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	//message.hidden = NO;
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			//message.text = @"Result: canceled";
			break;
		case MFMailComposeResultSaved:
			//message.text = @"Result: saved";
			break;
		case MFMailComposeResultSent:
			//message.text = @"Result: sent";
			break;
		case MFMailComposeResultFailed:
			//message.text = @"Result: failed";
			break;
		default:
			//message.text = @"Result: not sent";
			break;
	}
	[self.currentVC dismissModalViewControllerAnimated:YES];
}


//Facebook stuff
/*
 * Callback for session changes.
 */
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                // We have a valid session
                NSLog(@"User session found");
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:FBSessionStateChangedNotification
     object:session];
    
    if (error) {
        // do not show message if it is the following case
        NSRange range = [error.localizedDescription rangeOfString:@"error 2"];
        if (range.length > 0) {
            return;
        }
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

/*
 * Opens a Facebook session and optionally shows the login UX.
 */
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    return [FBSession openActiveSessionWithReadPermissions:nil
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session,
                                                             FBSessionState state,
                                                             NSError *error) {
                                             [self sessionStateChanged:session
                                                                 state:state
                                                                 error:error];
                                         }];
}

- (void) closeSession {
    [FBSession.activeSession closeAndClearTokenInformation];
}


/*
 * If we have a valid session at the time of openURL call, we handle
 * Facebook transitions by passing the url argument to handleOpenURL
 */
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
    {
        return NO;
    }
    
    return [FBSession.activeSession handleOpenURL:url];
}

//end of Facebook stuff


- (void)getCoordinate {
	if (locationManager == nil) {
		locationManager = [[CLLocationManager alloc] init];
		locationManager.delegate = self;
		locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
		//locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
		//locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; // 10 m
		locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	}
	[locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
	NSLog(@"latitude: %f, longitude: %f\n", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
	NSLog(@"horizontalAccuracy = %.2f\n", newLocation.horizontalAccuracy);
	
    
	
#if TARGET_IPHONE_SIMULATOR
	
	NSLog(@"Running in Simulator\n");
	//accuracy in meters
	if (newLocation.horizontalAccuracy > 200) {
		return;
	}
	
#else
	NSLog(@"Running on the Device\n");
	NSTimeInterval howRecent = [newLocation.timestamp timeIntervalSinceNow];
	if (howRecent < -10) {
		return;
	}
	
	//accuracy in meters
	if (newLocation.horizontalAccuracy > 100) {
		return;
	}
	
#endif
	
	latitude = newLocation.coordinate.latitude;
	longitude = newLocation.coordinate.longitude;
    
    NSLog(@"latitude = %f, longitude = %f", latitude, longitude);
    
	[locationManager stopUpdatingLocation];

}

-(void) locationDenied {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                              //message:@"\n\n\n\n\n\n" // IMPORTANT
                                                        message:@"Sorry, AAChurch has to know your location in order to work. Go to iPhone Settings to manually turn on Location Service for AAChurch."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [alertView setTransform:CGAffineTransformMakeTranslation(0.0, 110.0)];
    [alertView show];
}


- (void)locationManager:(CLLocationManager*)aManager didFailWithError:(NSError*)anError
{
    NSString *message;
    switch([anError code])
    {
            //NSString *message;
        case kCLErrorLocationUnknown: // location is currently unknown, but CL will keep trying
            break;
            
        case kCLErrorDenied: // CL access has been denied (eg, user declined location use)
            //message = @"Sorry, AAChurch has to know your location in order to work. Go to Settings to manually turn on Location Service for AAChurch.";
            [self locationDenied];
            break;
            
        case kCLErrorNetwork: // general, network-related error
            message = @"AAChurch can't find you - please check your network connection or that you are not in airplane mode";
    }
}

-(void) removeSplashScreen
{
    [splashViewController.view removeFromSuperview];
}

- (void)printSubviews: (UIView *)view {
	NSArray* subviews = [view subviews];
	
    self.fullScreenVideoIsPlaying = NO;
    
	if (subviews.count == 0) {
	}
	else {
		//NSLog(@"count of subviews = %d", subviews.count);
		for (int i = 0; i < subviews.count; i++) {
			UIView * currentView = [subviews objectAtIndex:i];
			[self printSubviews:currentView];
            NSString *name = [NSString stringWithFormat:@"%@", [currentView class]];
            //NSLog(@"name = %@\n", name);
            if ([name isEqualToString:@"MPFullScreenVideoOverlay"]) {
                self.fullScreenVideoIsPlaying = YES;
                NSLog(@"name = %@\n", name);
            }
        }
	}	
}

- (void)xmlParse:(GDataXMLDocument *)doc
{
    NSArray *configList = [doc nodesForXPath:@"//Config" error:nil];
    if (configList) {
        GDataXMLElement *config;
        GDataXMLElement *rssFeed;
        GDataXMLElement *logo;
        GDataXMLElement *splash;
        GDataXMLElement *header;
        GDataXMLElement *plainBackground;
        GDataXMLElement *discoverBackground;
        GDataXMLElement *sermonsBackground;
        GDataXMLElement *connectBackground;
        GDataXMLElement *fontName;
        GDataXMLElement *facebook;
        GDataXMLElement *twitter;
        GDataXMLElement *email;
        GDataXMLElement *website;
        GDataXMLElement *segmentedControlSelectedColor;
        GDataXMLElement *segmentedControlUnselectedColor;
        GDataXMLElement *sliderControlColor;
        GDataXMLElement *red;
        GDataXMLElement *green;
        GDataXMLElement *blue;
        
        config = [configList lastObject];
        NSArray *temp = [config elementsForName:@"RSSfeed"];
        rssFeed = [temp lastObject];
        NSLog(@"rssFeed = %@\n", rssFeed.stringValue);
        self.config.rssFeed = rssFeed.stringValue;
        
        temp = [config elementsForName:@"Logo"];
        logo = [temp lastObject];
        NSLog(@"logo = %@\n", logo.stringValue);
        self.config.logo = logo.stringValue;
        
        temp = [config elementsForName:@"Splash"];
        splash = [temp lastObject];
        NSLog(@"splash = %@\n", splash.stringValue);
        self.config.splash = splash.stringValue;
        
        temp = [config elementsForName:@"Header"];
        header = [temp lastObject];
        self.config.header = header.stringValue;
        
        temp = [config elementsForName:@"PlainBackground"];
        plainBackground = [temp lastObject];
        self.config.plainBackground = plainBackground.stringValue;
        
        temp = [config elementsForName:@"DiscoverBackground"];
        discoverBackground = [temp lastObject];
        self.config.discoverBackground = discoverBackground.stringValue;
        
        temp = [config elementsForName:@"SermonsBackground"];
        sermonsBackground = [temp lastObject];
        self.config.sermonsBackground = sermonsBackground.stringValue;
        
        temp = [config elementsForName:@"ConnectBackground"];
        connectBackground = [temp lastObject];
        self.config.connectBackground = connectBackground.stringValue;
        
        temp = [config elementsForName:@"FontName"];
        fontName = [temp lastObject];
        self.config.fontName = fontName.stringValue;
        
        temp = [config elementsForName:@"Facebook"];
        facebook = [temp lastObject];
        self.config.facebook = facebook.stringValue;
        
        temp = [config elementsForName:@"Twitter"];
        twitter = [temp lastObject];
        self.config.twitter = twitter.stringValue;
        
        temp = [config elementsForName:@"Email"];
        email = [temp lastObject];
        self.config.email = email.stringValue;
        
        temp = [config elementsForName:@"Website"];
        website = [temp lastObject];
        self.config.website = website.stringValue;
        
        temp = [config elementsForName:@"SegmentedControlSelectedColor"];
        segmentedControlSelectedColor = [temp lastObject];
        temp = [segmentedControlSelectedColor elementsForName:@"Red"];
        red = [temp lastObject];
        NSLog(@"SelectedColor\n");
        NSLog(@"red = %@\n", red.stringValue);
        temp = [segmentedControlSelectedColor elementsForName:@"Green"];
        green = [temp lastObject];
        NSLog(@"green = %@\n", green.stringValue);
        temp = [segmentedControlSelectedColor elementsForName:@"Blue"];
        blue = [temp lastObject];
        NSLog(@"blue = %@\n", blue.stringValue);
        self.config.segmentedControlSelectedColor = [UIColor colorWithRed:[red.stringValue floatValue] green:[green.stringValue floatValue] blue:[blue.stringValue floatValue] alpha:1.0];
        
        temp = [config elementsForName:@"SegmentedControlUnselectedColor"];
        segmentedControlUnselectedColor = [temp lastObject];
        temp = [segmentedControlUnselectedColor elementsForName:@"Red"];
        red = [temp lastObject];
        NSLog(@"UnselectedColor\n");
        NSLog(@"red = %@\n", red.stringValue);
        temp = [segmentedControlUnselectedColor elementsForName:@"Green"];
        green = [temp lastObject];
        NSLog(@"green = %@\n", green.stringValue);
        temp = [segmentedControlUnselectedColor elementsForName:@"Blue"];
        blue = [temp lastObject];
        NSLog(@"blue = %@\n", blue.stringValue);
        self.config.segmentedControlUnselectedColor = [UIColor colorWithRed:[red.stringValue floatValue] green:[green.stringValue floatValue] blue:[blue.stringValue floatValue] alpha:1.0];
        
        temp = [config elementsForName:@"SliderControlColor"];
        sliderControlColor = [temp lastObject];
        temp = [sliderControlColor elementsForName:@"Red"];
        red = [temp lastObject];
        NSLog(@"SliderControlColor\n");
        NSLog(@"red = %@\n", red.stringValue);
        temp = [sliderControlColor elementsForName:@"Green"];
        green = [temp lastObject];
        NSLog(@"green = %@\n", green.stringValue);
        temp = [sliderControlColor elementsForName:@"Blue"];
        blue = [temp lastObject];
        NSLog(@"blue = %@\n", blue.stringValue);
        self.config.sliderControlColor = [UIColor colorWithRed:[red.stringValue floatValue] green:[green.stringValue floatValue] blue:[blue.stringValue floatValue] alpha:1.0];
        
        temp = [config elementsForName:@"MajorColor"];
        sliderControlColor = [temp lastObject];
        temp = [sliderControlColor elementsForName:@"Red"];
        red = [temp lastObject];
        NSLog(@"MajorColor\n");
        NSLog(@"red = %@\n", red.stringValue);
        temp = [sliderControlColor elementsForName:@"Green"];
        green = [temp lastObject];
        NSLog(@"green = %@\n", green.stringValue);
        temp = [sliderControlColor elementsForName:@"Blue"];
        blue = [temp lastObject];
        NSLog(@"blue = %@\n", blue.stringValue);
        self.config.majorColor = [UIColor colorWithRed:[red.stringValue floatValue] green:[green.stringValue floatValue] blue:[blue.stringValue floatValue] alpha:1.0];
        
        temp = [config elementsForName:@"MinorColor"];
        sliderControlColor = [temp lastObject];
        temp = [sliderControlColor elementsForName:@"Red"];
        red = [temp lastObject];
        NSLog(@"MinorColor\n");
        NSLog(@"red = %@\n", red.stringValue);
        temp = [sliderControlColor elementsForName:@"Green"];
        green = [temp lastObject];
        NSLog(@"green = %@\n", green.stringValue);
        temp = [sliderControlColor elementsForName:@"Blue"];
        blue = [temp lastObject];
        NSLog(@"blue = %@\n", blue.stringValue);
        self.config.minorColor = [UIColor colorWithRed:[red.stringValue floatValue] green:[green.stringValue floatValue] blue:[blue.stringValue floatValue] alpha:1.0];
    }
}

- (void)getConfig {
    
    NSError *xmlError;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"FountainConfig" ofType:@"xml"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:data
                                                           options:0 error:&xmlError];
    
    if (xmlError) {
        NSLog(@"Error: %@\n", xmlError.localizedDescription);
    }
    
    if (doc) {
        [self xmlParse:doc];
    }
    
}

- (NSUInteger) application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    
    //testing
    NSArray *subviews = window.subviews;
    NSLog(@"subviews count = %d\n", subviews.count);
    for (int i = 0; i < subviews.count; i++) {
        UIView * currentView = [subviews objectAtIndex:i];
        NSString *name = [NSString stringWithFormat:@"%@", [currentView class]];
        //NSLog(@"name = %@\n", name);
        [self printSubviews:currentView];
    }
    
    if (self.fullScreenVideoIsPlaying) {
        NSLog(@"Enter: %s", __PRETTY_FUNCTION__);
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    else {
        return UIInterfaceOrientationMaskPortrait;
    }
    //return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.config = [[Config alloc] init];
    [self getConfig];
    
    //storyboard loading testing
    double osVersion = [[[UIDevice currentDevice] systemVersion] doubleValue];
    UIStoryboard *storyboard;
    if (osVersion >= 7.0) {
        storyboard = [UIStoryboard storyboardWithName:@"iOS7Storyboard" bundle:[NSBundle mainBundle]];
    }
    else {
        storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    }

    UIViewController *vc =[storyboard instantiateInitialViewController];
    
    // Set root view controller and make windows visible
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    
    // end of storyboard loading testing
    
    splashViewController = [[SplashViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
    //[self.window addSubview:splashViewController.view];
    [self.window.rootViewController.view addSubview:splashViewController.view];

    [self performSelector:@selector(removeSplashScreen) withObject:nil afterDelay:SPLASHSCREEN_DELAY];

        
    [self getCoordinate];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // We need to properly handle activation of the application with regards to SSO
    // (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0)
    {
       [FBSession.activeSession handleDidBecomeActive];
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0)
    {
        [FBSession.activeSession close];
    }
}

@end

//the following seems redundant
/*
@implementation UINavigationBar (UINavigationBarCategory)
- (void)drawRect:(CGRect)rect {
    UIImage *img = [UIImage imageNamed:@"AApp_header.png"];
    [img drawInRect:rect];
    //[img drawInRect:CGRectMake(0, 0, self.frame.size.width, 44)];
}
@end
*/

