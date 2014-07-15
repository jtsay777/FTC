//
//  WebViewController.m
//  AAChurch
//
//  Created by Ben Gomez on 8/15/12.
//  Copyright (c) 2012 Jway Group. All rights reserved.
//

#import "WebViewController.h"
#import "AppDelegate.h"

@interface WebViewController ()

@end

@implementation WebViewController

@synthesize webView;
@synthesize link;
@synthesize feedItem;

- (void)webViewDidStartLoad:(UIWebView *) webview
{
    NSLog(@"Enter %s", __PRETTY_FUNCTION__);
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *) webview
{
    NSLog(@"Enter %s", __PRETTY_FUNCTION__);
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
    
    //testing
    //the following is needed with the UINavigationBarCategory interface in AppDelegate.m
    if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        //[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"AApp_header.png"] forBarMetrics:UIBarMetricsDefault];
        AppDelegate *appDelegate =
        (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:appDelegate.config.header] forBarMetrics:UIBarMetricsDefault];
    }
    
    self.navigationItem.title = @"Back";
    
    UILabel *label = [[UILabel alloc] init];
    self.navigationItem.titleView = label;
    label.text = @"";

    
    activityIndicator = [[UIActivityIndicatorView alloc]  initWithFrame:CGRectMake(0.0f, 0.0f, 64.0f, 64.0f)];
    [activityIndicator setCenter:CGPointMake(160.0f, 160.0f)];
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:activityIndicator];
    
    [webView setScalesPageToFit:YES];
    
    //NSLog(@"in WebViewController viewDidLoad: link = %@", link);
    NSURL *url;// = [NSURL URLWithString:link];
    
    if (self.feedItem) {
        if (self.feedItem.type == Media) {
            url = [NSURL URLWithString:self.feedItem.video];
            NSLog(@"in WebViewController viewDidLoad: video = %@", self.feedItem.video);
        }
        else if (self.feedItem.type == Sermons) {
            url = [NSURL URLWithString:self.feedItem.audio];
            //url = [NSURL URLWithString:@"https://soundcloud.com/apostolicassembly-1/pastor-elias-elisondo-2010"];//testing
            NSLog(@"in WebViewController viewDidLoad: audio = %@", self.feedItem.audio);
        }
    }
    else if (self.link) {
        url = [NSURL URLWithString:link];
        NSLog(@"in WebViewController viewDidLoad: link = %@", link);
    }
    
    [webView loadRequest:[NSURLRequest requestWithURL:url]];

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
