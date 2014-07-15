//
//  HomeViewController.m
//  AAChurch
//
//  Created by Ben Gomez on 8/10/12.
//  Copyright (c) 2012 Jway Group. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"
#import "ShareViewController.h"

//make a UIImage category to do crop function
@implementation UIImage (Crop)

- (UIImage *)crop:(CGRect)rect {
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    if (scale>1.0) {
        rect = CGRectMake(rect.origin.x*scale , rect.origin.y*scale, rect.size.width*scale, rect.size.height*scale);
         NSLog(@"scale = %f", scale);
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return result;
}

@end


@interface HomeViewController ()

@end

@implementation HomeViewController
@synthesize discoverLabel1;
@synthesize discoverLabel2;
@synthesize discoverLabel3;
@synthesize locatorLabel1;
@synthesize locatorLabel2;
@synthesize locatorLabel3;
@synthesize locatorLabel4;
@synthesize giveLabel1;
@synthesize giveLabel2;
@synthesize connectLabel1;
@synthesize connectLabel2;
@synthesize connectLabel3;

enum {
    Home,
    Feed,
    Locator,
    Give,
    Connect
};

//Facebook stuff
- (void)sessionStateChanged:(NSNotification*)notification {
    if (FBSession.activeSession.isOpen) {
        self.publishButton.hidden = NO;
        [self.authButton setTitle:@"Logout" forState:UIControlStateNormal];
    } else {
        self.publishButton.hidden = YES;
        [self.authButton setTitle:@"Login" forState:UIControlStateNormal];
    }
}

- (IBAction)authButtonAction:(UIButton *)sender {
    AppDelegate *appDelegate =
    [[UIApplication sharedApplication] delegate];
    
    // If the user is authenticated, log out when the button is clicked.
    // If the user is not authenticated, log in when the button is clicked.
    if (FBSession.activeSession.isOpen) {
        [appDelegate closeSession];
    } else {
        // The user has initiated a login, so call the openSession method
        // and show the login UX if necessary.
        [appDelegate openSessionWithAllowLoginUI:YES];
    }

}

- (IBAction)publishButtonAction:(UIButton *)sender {
    ///*
    ShareViewController *viewController = [[ShareViewController alloc]
                                           initWithNibName:@"ShareViewController"
                                           bundle:nil];
    [self presentViewController:viewController animated:YES completion:nil];
    //*/

}

- (IBAction)goFeed:(UIButton *)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    UITabBarController *tabBarController = (UITabBarController *)self.view.window.rootViewController;
    tabBarController.selectedIndex = Feed;
}

- (IBAction)goLocator:(UIButton *)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    UITabBarController *tabBarController = (UITabBarController *)self.view.window.rootViewController;
    tabBarController.selectedIndex = Locator;
}

- (IBAction)goGive:(UIButton *)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    UITabBarController *tabBarController = (UITabBarController *)self.view.window.rootViewController;
    tabBarController.selectedIndex = Give;
}

- (IBAction)goConnect:(UIButton *)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    UITabBarController *tabBarController = (UITabBarController *)self.view.window.rootViewController;
    tabBarController.selectedIndex = Connect;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (UIImage *)offlineImage:(NSString *)imageName
{    
    // Create new offscreen context with desired size
    UIGraphicsBeginImageContext(CGSizeMake(320.0f, 480.0f));
    
    //CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIImage *image = [UIImage imageNamed:imageName];
    [image drawAtPoint:CGPointMake(0, 0)];
    
    // assign context to UIImage
    UIImage *outputImg = UIGraphicsGetImageFromCurrentImageContext();
    
    // end context
    UIGraphicsEndImageContext();
    
    return outputImg;
}

- (void)swipe:(UISwipeGestureRecognizer *)gestureRecognizer
{
    UIView *view = [gestureRecognizer view];
    
    CGPoint p = [gestureRecognizer locationInView:view];
	//NSLog(@"x = %.2f, y = %.2f", p.x, p.y);
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
    }
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"Tap Begin: x = %.2f, y = %.2f", p.x, p.y);
            break;
        case UIGestureRecognizerStateEnded:
            NSLog(@"Swipe Ended: x = %.2f, y = %.2f", p.x, p.y);
            
            //[self swipeAction];
            swipeCount++;
            if (swipeCount == 7) {
                NSLog(@"Swipe 7 times!");
                swipeCount = 0;
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Developers"
                                                                    message:@"\n\n\n\n\n\n" // IMPORTANT
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                
                UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(12, 50, 260, 120)];
                textView.editable = NO;
                
                textView.text = @"Johnson Tsay";
                CGFloat labelFontSize = [UIFont labelFontSize];
                textView.font = [UIFont boldSystemFontOfSize:labelFontSize];
                [alertView addSubview:textView];
                
                [alertView show];                
            }
            
            break;
            
        default:
            break;
    }
    
}

- (void)viewDidLoad
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    /*
    UIImage *imageToCrop;
    UIImage *croppedImage;
    CGRect cropRect;
    CGFloat scale = [[UIScreen mainScreen] scale];

    imageToCrop = [self offlineImage:@"AAapp_bg_home.png"];
    if (scale > 1.0) {
        cropRect = CGRectMake(0, 10, 320, 460);
    }
    else {
        cropRect = CGRectMake(0, 20, 320, 460);
    }
    
    croppedImage = [imageToCrop crop:cropRect];

    self.view.backgroundColor = [UIColor colorWithPatternImage: croppedImage];
    */
    
    AppDelegate *appDelegate =
    (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
 
    self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"AAapp_bg_home.png"]];

    
    //testing
    //the following is needed with the UINavigationBarCategory interface in AppDelegate.m
    
    if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"AApp_header.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
    self.navigationItem.title = @"Back";
    
    UILabel *label = [[UILabel alloc] init];
    self.navigationItem.titleView = label;
    label.text = @"";
    
    discoverLabel1.text = @"Access the latest videos,";
    discoverLabel2.text = @"blogs and news from the";
    discoverLabel3.text = @"Apostolic Assembly.";
    discoverLabel1.font = [UIFont fontWithName:appDelegate.config.fontName size:12];
    discoverLabel2.font = [UIFont fontWithName:appDelegate.config.fontName size:12];
    discoverLabel3.font = [UIFont fontWithName:appDelegate.config.fontName size:12];
    discoverLabel1.textColor = [UIColor whiteColor];
    discoverLabel2.textColor = [UIColor whiteColor];
    discoverLabel3.textColor = [UIColor whiteColor];
    
    locatorLabel1.text = @"Use our interactive";
    locatorLabel2.text = @"church locator to find";
    locatorLabel3.text = @"an Apostolic Church";
    locatorLabel4.text = @"near you.";
    locatorLabel1.font = [UIFont fontWithName:appDelegate.config.fontName size:12];
    locatorLabel2.font = [UIFont fontWithName:appDelegate.config.fontName size:12];
    locatorLabel3.font = [UIFont fontWithName:appDelegate.config.fontName size:12];
    locatorLabel4.font = [UIFont fontWithName:appDelegate.config.fontName size:12];
    locatorLabel1.textColor = [UIColor whiteColor];
    locatorLabel2.textColor = [UIColor whiteColor];
    locatorLabel3.textColor = [UIColor whiteColor];
    locatorLabel4.textColor = [UIColor whiteColor];
    
    giveLabel1.text = @"Invest into the work of";
    giveLabel2.text = @"the Kingdom.";
    giveLabel1.font = [UIFont fontWithName:appDelegate.config.fontName size:12];
    giveLabel2.font = [UIFont fontWithName:appDelegate.config.fontName size:12];
    giveLabel1.textColor = [UIColor whiteColor];
    giveLabel2.textColor = [UIColor whiteColor];
    
    connectLabel1.text = @"Connect with us on";
    connectLabel2.text = @"Facebook, Twitter and";
    connectLabel3.text = @"more...";
    connectLabel1.font = [UIFont fontWithName:appDelegate.config.fontName size:12];
    connectLabel2.font = [UIFont fontWithName:appDelegate.config.fontName size:12];
    connectLabel3.font = [UIFont fontWithName:appDelegate.config.fontName size:12];
    connectLabel1.textColor = [UIColor whiteColor];
    connectLabel2.textColor = [UIColor whiteColor];
    connectLabel3.textColor = [UIColor whiteColor];
    
    //testing
    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [rightRecognizer setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:rightRecognizer];
    
    //Facebook stuff
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(sessionStateChanged:)
     name:FBSessionStateChangedNotification
     object:nil];
    
    // Check the session for a cached token to show the proper authenticated
    // UI. However, since this is not user intitiated, do not show the login UX.
    //AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate openSessionWithAllowLoginUI:NO];
    //[appDelegate openSessionWithAllowLoginUI:YES];//testing

}

- (void)viewDidUnload
{
    [self setDiscoverLabel1:nil];
    [self setDiscoverLabel2:nil];
    [self setDiscoverLabel3:nil];
    [self setLocatorLabel1:nil];
    [self setLocatorLabel2:nil];
    [self setLocatorLabel3:nil];
    [self setLocatorLabel4:nil];
    [self setGiveLabel1:nil];
    [self setGiveLabel2:nil];
    [self setConnectLabel1:nil];
    [self setConnectLabel2:nil];
    [self setConnectLabel3:nil];
    [self setAuthButton:nil];
    [self setPublishButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end


