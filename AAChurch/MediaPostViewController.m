//
//  MediaPostViewController.m
//  Apostolic
//
//  Created by Ben Gomez on 11/8/12.
//  Copyright (c) 2012 Jway Group. All rights reserved.
//

#import "MediaPostViewController.h"
#import "WebViewController.h"
#import "AppDelegate.h"

@interface MediaPostViewController ()

@end

@implementation MediaPostViewController

- (void)webViewDidStartLoad:(UIWebView *) webview
{
    NSLog(@"Enter %s", __PRETTY_FUNCTION__);
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [loadingIndicator startAnimating];
    
}

- (void)webViewDidFinishLoad:(UIWebView *) webview
{
    NSLog(@"Enter %s", __PRETTY_FUNCTION__);
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [loadingIndicator stopAnimating];
    
    
    // fix for iOS 7+
    CGPoint top = CGPointMake(8, 8);
    [webview.scrollView setContentOffset:top animated:YES];

}



- (IBAction)watchAction:(UIButton *)sender {
    NSLog(@"Enter: %s", __PRETTY_FUNCTION__);
}

- (IBAction)facebookAction:(UIButton *)sender {
    NSLog(@"Enter: %s", __PRETTY_FUNCTION__);
    
    AppDelegate *appDelegate =
    [[UIApplication sharedApplication] delegate];
        
    //NSString *msg = [NSString stringWithFormat:@"Check out \"%@\" via the Apostolic Assembly mobile app. Download it today!", self.feedItem.title];
    NSString *msg = [NSString stringWithFormat:@"Check out \"%@\" via the Fountain Church mobile app. Download it today!", self.feedItem.title];
    [appDelegate doFacebook:msg];

}

- (IBAction)twitterAction:(UIButton *)sender {
    NSLog(@"Enter: %s", __PRETTY_FUNCTION__);
    
    AppDelegate *appDelegate =
    [[UIApplication sharedApplication] delegate];
    
    //NSString *msg = [NSString stringWithFormat:@"Check out \"%@\" via the Apostolic Assembly mobile app. Download it today!", self.feedItem.title];
    
    NSString *msg = [NSString stringWithFormat:@"Check out \"%@\" via the Fountain Church mobile app. Download it today!", self.feedItem.title];
    [appDelegate doTwitter:msg];

}

- (IBAction)mailAction:(UIButton *)sender {
    NSLog(@"Enter: %s", __PRETTY_FUNCTION__);
    
    AppDelegate *appDelegate =
    [[UIApplication sharedApplication] delegate];
    
    //NSString *msg = [NSString stringWithFormat:@"Check out \"%@\" via the Apostolic Assembly mobile app. Download it today!", self.feedItem.title];
    NSString *msg = [NSString stringWithFormat:@"Check out \"%@\" via the Fountain Church mobile app. Download it today!", self.feedItem.title];
    [appDelegate doMail:msg];
    

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)printSubviews: (UIView *)view {
	NSArray* subviews = [view subviews];
	
    //self.fullScreenVideoIsPlaying = NO;
    
	if (subviews.count == 0) {
	}
	else {
		//NSLog(@"count of subviews = %d", subviews.count);
		for (int i = 0; i < subviews.count; i++) {
			UIView * currentView = [subviews objectAtIndex:i];
			[self printSubviews:currentView];
            NSString *name = [NSString stringWithFormat:@"%@", [currentView class]];
            //NSLog(@"name = %@\n", name);
            //if ([name isEqualToString:@"MPFullScreenVideoOverlay"]) {
            if ([name isEqualToString:@"MPVideoPlaybackOverlayView"]) {
                self.fullScreenVideoIsPlaying = YES;
                NSLog(@"name = %@\n", name);
            }
        }
	}
}

//the following is for iOS 5
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    NSLog(@"Enter %s", __PRETTY_FUNCTION__);
    
    self.fullScreenVideoIsPlaying = NO;
    
    //testing
    NSArray *subviews = self.view.subviews;
    NSLog(@"subviews count = %d\n", subviews.count);
    for (int i = 0; i < subviews.count; i++) {
        UIView * currentView = [subviews objectAtIndex:i];
        NSString *name = [NSString stringWithFormat:@"%@", [currentView class]];
        //NSLog(@"name = %@\n", name);
        [self printSubviews:currentView];
    }
    
    if (self.fullScreenVideoIsPlaying) {
        NSLog(@"### Enter ### : %s", __PRETTY_FUNCTION__);
        return YES;
    }
    else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    
    //return YES;
}

-(void)embedVimeo{
    
    //NSString *embedHTML = @"<iframe width=\"320\" height=\"150\" src=\"http://www.vimeo.com/embed/rOPI5LDo7mg\" frameborder=\"0\" allowfullscreen></iframe>";
    
    //NSString *html = [NSString stringWithFormat:embedHTML];
    NSString *html = [NSString stringWithFormat:@"<iframe width=\"320\" height=\"150\" src=\"%@\" frameborder=\"0\" allowfullscreen></iframe>", self.feedItem.video];
    
    
    [_webView loadHTMLString:html baseURL:nil];
    //[self.view addSubview:_webView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.currentVC = self;
    
    //appDelegate.fullScreenVideoIsPlaying = YES;

    
    //self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:appDelegate.config.plainBackground]];
    
    UIColor *titleColor = appDelegate.config.headerColor;//appDelegate.config.majorColor; //[UIColor colorWithRed: 182/255.0 green:205/255.0 blue:216/255.0 alpha:1.0];
    
    self.titleLabel.backgroundColor=[UIColor clearColor];
    //self.titleLabel.shadowColor = [UIColor blackColor];
    //self.titleLabel.shadowOffset = CGSizeMake(0,2);
    self.titleLabel.textColor = titleColor; //[UIColor whiteColor];
    self.titleLabel.font = [UIFont fontWithName:appDelegate.config.fontName size:20];
    
    self.creatorLabel.textColor = appDelegate.config.minorColor;//[UIColor whiteColor];
    self.dateLabel.font = [UIFont fontWithName:appDelegate.config.fontName size:14];
    
    self.dateLabel.textColor = appDelegate.config.minorColor;//[UIColor whiteColor];
    self.dateLabel.font = [UIFont fontWithName:appDelegate.config.fontName size:14];
    
    self.titleLabel.text = self.feedItem.title;
    self.creatorLabel.text = self.feedItem.creator;
    self.dateLabel.text = [NSString stringWithFormat:@"%@ %@, %@", self.feedItem.month, self.feedItem.day, self.feedItem.year];
    
    NSURL * imageURL = [NSURL URLWithString:self.feedItem.featuredImageURL];
    NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
    self.imageView.image = [UIImage imageWithData:imageData];
    
    loadingIndicator = [[UIActivityIndicatorView alloc]  initWithFrame:CGRectMake(0.0f, 0.0f, 64.0f, 64.0f)];
    [loadingIndicator setCenter:CGPointMake(160.0f, 80.0f)];
    [loadingIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [loadingIndicator stopAnimating];
    [self.view addSubview:loadingIndicator];
    
    //check if missing http:
    if (![self.feedItem.video hasPrefix:@"http:"]) {
        self.feedItem.video = [NSString stringWithFormat:@"http:%@", self.feedItem.video];
    }
    NSURL *url = [NSURL URLWithString:self.feedItem.video];
    //NSURL *url = [NSURL URLWithString:@"http://youtu.be/ql36y7Lut8Y"];//Johnson temporarily
    
    NSLog(@"video check2 = %@", self.feedItem.video);
    
    self.webView.delegate = self;
    //[self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self embedVimeo];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setCreatorLabel:nil];
    [self setDateLabel:nil];
    [self setImageView:nil];
    [self setWebView:nil];
    [super viewDidUnload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure we're referring to the correct segue
    if ([[segue identifier] isEqualToString:@"ShowVideoView"]) {
        
        // Get reference to the destination view controller
        WebViewController *webVC = [segue destinationViewController];
        
        //webVC.link = self.feedItem.link;
        webVC.feedItem = self.feedItem;
        
    }
}

@end
