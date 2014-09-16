//
//  FeedPostViewController.m
//  Apostolic
//
//  Created by Ben Gomez on 11/6/12.
//  Copyright (c) 2012 Jway Group. All rights reserved.
//

#import "FeedPostViewController.h"
#import "AppDelegate.h"
#import "NSString+FontAwesome.h"

@interface FeedPostViewController () {
    FeedItem *currentFeedItem;
    UIActivityIndicatorView *activityIndicator;
    
    TWTweetComposeViewController *_tweetSheet;
    
    NSString *currentURLString;
}

@end

@implementation FeedPostViewController

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSLog(@"alertView, buttonIndex=%d", buttonIndex);
	
	if (buttonIndex == 1) {//Enter button
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:currentURLString]];
	}
}


- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request
 navigationType:(UIWebViewNavigationType)navigationType {
    
    NSLog(@"Enter %s", __PRETTY_FUNCTION__);
    //CAPTURE USER LINK-CLICK.
    NSURL *url = [request URL];
    
    NSString *urlString = [url absoluteString];
    NSLog(@"\n\nurl String = %@\n\n", urlString);
    
    //check to see if the link is one of our Discover link list
//    if ([self.delegate isOneOfListByType:self.feedType link:urlString]) {
//        
//        return YES;
//    }
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
    
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        /*
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Browsing Confirmation"
                                                            message:@"\n\n\n\n\n" // IMPORTANT
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"OK", nil];
        
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(12, 50, 260, 90)];
        textView.editable = NO;
        NSString *msg = [NSString stringWithFormat:@"This page will open in Safari: %@", urlString];
        textView.text = msg;
        currentURLString = urlString;
        
        CGFloat labelFontSize = [UIFont labelFontSize];
        textView.font = [UIFont boldSystemFontOfSize:labelFontSize];
        [alertView addSubview:textView];
        */
        
        currentURLString = urlString;
        
        NSString *msg = [NSString stringWithFormat:@"This page will open in Safari: %@", urlString];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Browsing Confirmation"
                                                            message:msg
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"OK", nil];
        
        [alertView show];

        return NO;
    }
    
    return YES;

}



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

- (void)updateFeedItem:(FeedItem *)feedItem {
    self.titleLabel.text = feedItem.title;
    self.dateLabel.text = [NSString stringWithFormat:@"%@ %@, %@", feedItem.month, feedItem.day, feedItem.year];
    
    NSURL *url = [NSURL URLWithString:feedItem.link];
    NSLog(@"\nlink = %@\n", feedItem.link);
    [self.feedItemWebView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (IBAction)prevAction:(UIButton *)sender {
    NSLog(@"Enter: %s", __PRETTY_FUNCTION__);
    
    if (self.currentSelection > 0) {
        self.currentSelection--;
        self.nextButton.enabled = YES;
        if (self.currentSelection == 0) {
            self.prevButton.enabled = NO;
        }

        NSLog(@"currentSelection = %d", self.currentSelection);
        
        currentFeedItem = [self.delegate getFeedItemByType:self.feedType index:self.currentSelection];
        NSLog(@"title = %@", currentFeedItem.title);
        
        [self updateFeedItem:currentFeedItem];
    }
}

- (IBAction)nextAction:(UIButton *)sender {
    NSLog(@"Enter: %s", __PRETTY_FUNCTION__);
    
    if (self.currentSelection < self.totalCount-1) {
        self.currentSelection++;
        self.prevButton.enabled = YES;
        if (self.currentSelection == self.totalCount-1) {
            self.nextButton.enabled = NO;
        }
        NSLog(@"currentSelection = %d", self.currentSelection);
        
        currentFeedItem = [self.delegate getFeedItemByType:self.feedType index:self.currentSelection];
        NSLog(@"title = %@", currentFeedItem.title);
        
        [self updateFeedItem:currentFeedItem];
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
	[self dismissModalViewControllerAnimated:YES];
}


- (IBAction)mailAction:(UIButton *)sender {
    NSLog(@"Enter: %s", __PRETTY_FUNCTION__);
    
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        
        [picker setSubject:@"Apostolic Assembly sharing"];
        // Fill out the email body text
        NSString *emailBody = [NSString stringWithFormat:@"Check out \"%@\" via Fountain of Truth mobile app. Download it today!", self.feedItem.title];
        emailBody = [emailBody stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
        NSMutableString *html = [NSMutableString string];
        [html appendString:@"<html><body><p>"];
        [html appendString:emailBody];
        [html appendString:@"</p>"];
        //[html appendString:@"<p>Download <a href=\"http://itunes.apple.com/us/app/mobyoffers/id505632114?mt=8\">MobyOffers</a> from the App Store to get this coupon.</p></body></html>"];
        
        //[picker setMessageBody:emailBody isHTML:NO];
        [picker setMessageBody:html isHTML:YES];
        
        [self presentModalViewController:picker animated:YES];
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


-(void)ios5Twitter
{
    int version = [self getSystemVersionAsAnInteger];
    
    if (version >= __IPHONE_5_0) {
        if (_tweetSheet == nil) {
            // Make an instance
            _tweetSheet = [[TWTweetComposeViewController alloc] init];
            
            // Specify the completion handler
            TWTweetComposeViewControllerCompletionHandler completionHandler =
            ^(TWTweetComposeViewControllerResult result) {
                
                [self dismissModalViewControllerAnimated:YES];
                
            };
            
            [_tweetSheet setCompletionHandler:completionHandler];
        }
        
        BOOL allowed;
        NSString *twitterInfo;
        
        twitterInfo = [NSString stringWithFormat:@"Check out \"%@\" via the Apostolic Assembly mobile app. Download it today!", self.feedItem.title];
        allowed = [_tweetSheet setInitialText:twitterInfo];
        
        if (allowed) {
            //NSLog(@"\nabout to Twitter! original text's length= %d\n, reduced text's length = %d", [offerInfoForTwitter length], [twitterInfo length]);(somehow crash?)
            
            //[_tweetSheet addURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/mobyoffers/id505632114?mt=8"]];
            [self presentModalViewController:_tweetSheet animated:YES];
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


- (IBAction)twitterAction:(UIButton *)sender {
    NSLog(@"Enter: %s", __PRETTY_FUNCTION__);
    
    //[self ios5Twitter];
    
    AppDelegate *appDelegate =
    [[UIApplication sharedApplication] delegate];
    
    //NSString *msg = [NSString stringWithFormat:@"Check out \"%@\" via the Apostolic Assembly mobile app. Download it today!", self.feedItem.title];
    
    NSString *msg = [NSString stringWithFormat:@"Check out \"%@\" via Fountain of Truth Church mobile app. Download it today!", self.feedItem.title];
    [appDelegate doTwitter:msg];
}


- (IBAction)facebookAction:(UIButton *)sender {
    NSLog(@"Enter: %s", __PRETTY_FUNCTION__);
    
     
    AppDelegate *appDelegate =
    (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
    //NSString *msg = [NSString stringWithFormat:@"Check out \"%@\" via the Apostolic Assembly mobile app. Download it today!", currentFeedItem.title];
    NSString *msg = [NSString stringWithFormat:@"Check out \"%@\" via Fountain of Truth Church mobile app. Download it today!", self.feedItem.title];
    
    [appDelegate doFacebook:msg];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"AAapp_bg_plain.png"]];
    
    AppDelegate *appDelegate =
    (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
     UIColor *titleColor = appDelegate.config.headerColor;//[UIColor colorWithRed: 182/255.0 green:205/255.0 blue:216/255.0 alpha:1.0];
    
    NSLog(@"link = %@", self.feedItem.link);
    
    //fontawesome testing
    self.fbButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:15.f];
    //self.fbButton.titleLabel.text = [NSString fontAwesomeIconStringForEnum:FAFacebook];
    self.twButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:15.f];
    //self.twButton.titleLabel.text = [NSString fontAwesomeIconStringForEnum:FATwitter];
    
    [self.fbButton setTitleColor:titleColor forState:UIControlStateNormal];
    [self.twButton setTitleColor:titleColor forState:UIControlStateNormal];
    
    [self.fbButton setTitle:[NSString fontAwesomeIconStringForEnum:FAFacebook] forState:UIControlStateNormal];
    [self.fbButton setTitle:[NSString fontAwesomeIconStringForEnum:FAFacebook] forState:UIControlStateSelected];
    
    [self.twButton setTitle:[NSString fontAwesomeIconStringForEnum:FATwitter] forState:UIControlStateNormal];
    [self.twButton setTitle:[NSString fontAwesomeIconStringForEnum:FATwitter] forState:UIControlStateSelected];
    
    // round framed button
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        
        self.nextButton.layer.cornerRadius = 2;
        self.nextButton.layer.borderWidth = 1;
        self.nextButton.layer.borderColor = titleColor.CGColor;
        
        self.prevButton.layer.cornerRadius = 2;
        self.prevButton.layer.borderWidth = 1;
        self.prevButton.layer.borderColor = titleColor.CGColor;
        
    }
    [self.nextButton setTitleColor:titleColor forState:UIControlStateNormal];
    [self.prevButton setTitleColor:titleColor forState:UIControlStateNormal];

    
    /*
    //the following is needed with the UINavigationBarCategory interface in AppDelegate.m
    if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        //[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"AApp_header.png"] forBarMetrics:UIBarMetricsDefault];
        AppDelegate *appDelegate =
        (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:appDelegate.config.header] forBarMetrics:UIBarMetricsDefault];
    }
    */
    
    //[self.navigationController.navigationBar setBackgroundColor:[UIColor yellowColor]];
    
    //self.navigationItem.title = @"Back";
    //self.navigationItem.title = @"My Title";
    
    UILabel *label = [[UILabel alloc] init];
    self.navigationItem.titleView = label;
    label.text = @"";
    
    activityIndicator = [[UIActivityIndicatorView alloc]  initWithFrame:CGRectMake(0.0f, 0.0f, 64.0f, 64.0f)];
    [activityIndicator setCenter:CGPointMake(160.0f, 110.0f)];
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:activityIndicator];
    
    
    //self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:appDelegate.config.plainBackground]];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, 487);//487?
	self.scrollView.maximumZoomScale = 2.0;
	self.scrollView.minimumZoomScale = 0.5;
	self.scrollView.clipsToBounds = YES;
    
    self.titleLabel.backgroundColor=[UIColor clearColor];
    self.titleLabel.shadowColor = [UIColor blackColor];
    self.titleLabel.shadowOffset = CGSizeMake(0,2);
    self.titleLabel.textColor = titleColor; //[UIColor whiteColor];
    self.titleLabel.font = [UIFont fontWithName:appDelegate.config.fontName size:20];
    
    self.dateLabel.textColor = [UIColor whiteColor];
    self.dateLabel.font = [UIFont fontWithName:appDelegate.config.fontName size:14];

    
    //populate the feedItem
    [self updateFeedItem:self.feedItem];
    
    /*
    //Facebook stuff
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(sessionStateChanged:)
     name:FBSessionStateChangedNotification
     object:nil];
     */
    
    // Check the session for a cached token to show the proper authenticated
    // UI. However, since this is not user intitiated, do not show the login UX.
    //AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    //[appDelegate openSessionWithAllowLoginUI:NO];
    
    appDelegate.currentVC = self;
    
    currentFeedItem = self.feedItem;
    
    if (self.currentSelection == 0) {
        self.prevButton.enabled = NO;
    }
    
    if (self.currentSelection == self.totalCount - 1) {
        self.nextButton.enabled = NO;
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setDateLabel:nil];
    [self setFeedItemImageView:nil];
    [self setFeedItemWebView:nil];
    [self setScrollView:nil];
    [self setPrevButton:nil];
    [self setNextButton:nil];
    [super viewDidUnload];
}
@end
