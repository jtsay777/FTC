//
//  DirectionViewController.m
//  AAChurch
//
//  Created by Johnson Tsay on 8/5/12.
//  Copyright (c) 2012 Jway Group. All rights reserved.
//

#import "DirectionViewController.h"

@interface DirectionViewController ()

@end

@implementation DirectionViewController

@synthesize church;
@synthesize webView;

- (void)webViewDidStartLoad:(UIWebView *) webview
{
    NSLog(@"Enter %s", __PRETTY_FUNCTION__);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *) webview
{
    NSLog(@"Enter %s", __PRETTY_FUNCTION__);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [activityIndicator stopAnimating];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //testing
    //the following is needed with the UINavigationBarCategory interface in AppDelegate.m
    if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        //[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"AApp_header.png"] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:appDelegate.config.header] forBarMetrics:UIBarMetricsDefault];
    }
    
    self.navigationItem.title = @"Back";
    
    UILabel *label = [[UILabel alloc] init];
    self.navigationItem.titleView = label;
    label.text = @"";

    
    double latitude = appDelegate.latitude;
    double longitude = appDelegate.longitude;
    
    activityIndicator = [[UIActivityIndicatorView alloc]  initWithFrame:CGRectMake(0.0f, 0.0f, 64.0f, 64.0f)];
    [activityIndicator setCenter:CGPointMake(160.0f, 208.0f)];
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:activityIndicator];
    
    //NSString *address = [NSString stringWithFormat:@"%@, %@, %@ %@", church.street, church.city, church.state, church.postalCode];
    
    NSString *address = @"";
    if (church.street) {
        address = [NSString stringWithFormat:@"%@", church.street];
    }
    if (church.city) {
        address = [NSString stringWithFormat:@"%@ %@", address, church.city];
    }
    if (church.state) {
        address = [NSString stringWithFormat:@"%@ %@", address, church.state];
    }
    if (church.postalCode) {
        address = [NSString stringWithFormat:@"%@ %@", address, church.postalCode];
    }
    
    
    NSString* urlStr = [NSString stringWithFormat: @"http://maps.google.com/maps?saddr=%f,%f&daddr=%@", latitude, longitude, [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"urlStr = %@", urlStr);
    
    NSURL *url=[NSURL URLWithString:urlStr];
    NSURLRequest *requestObj=[NSURLRequest requestWithURL:url];
    //webView.delegate = self;//have done in storyboard already
    
    [webView loadRequest:requestObj];

}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
