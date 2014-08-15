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

- (UIImage *)headerImage
{
    NSString *title = @"FOUNTAIN OF TRUTH";
    AppDelegate *appDelegate =
    (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    float yoffset = 0;
    int fontSize = 22;
    float width = self.view.bounds.size.width;
    float height = 44.0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        height = 64.0*2;
        width *= 2;
        fontSize *= 2;
        yoffset = 15;
    }
    
    
    //UIColor *dateColor = [UIColor colorWithRed: 182/255.0 green:205/255.0 blue:216/255.0 alpha:1.0];
    UIColor *textColor = [UIColor colorWithRed: 255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    
    // Create new offscreen context with desired size
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //CGColorRef fillColor = [[UIColor blackColor] CGColor];//only black and white?
	//CGContextSetFillColor(context, CGColorGetComponents(fillColor));
    
    //CGContextSetRGBFillColor(context, 48/255.0, 197/255.0, 244/255.0, 1.0);//work!
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    [appDelegate.config.headerColor getRed:&red green:&green blue:&blue alpha:&alpha];
    CGContextSetRGBFillColor(context, red, green, blue, 1.0);
    
    
	CGContextBeginPath(context);
    CGContextFillRect(context, CGRectMake(0, 0, width, height));
    //CGContextFillEllipseInRect(context, CGRectMake(0, 0, 40, 40));
	CGContextFillPath(context);
    
    //CGContextSetFillColorWithColor(context, [[UIColor redColor] CGColor]);//redColor works
    CGContextSetFillColorWithColor(context, [textColor CGColor]);
    
    //UIFont *font = [UIFont fontWithName:@"Helvetica" size:12];
    //UIFont *font = [UIFont fontWithName:@"Times New Roman" size:12];
    //UIFont *font = [UIFont fontWithName:@"Courier-Bold" size:12];
    
    UIFont *font = [UIFont fontWithName:appDelegate.config.fontName size:fontSize];
    CGSize tempSize = [title sizeWithFont:font constrainedToSize:CGSizeMake(width, height) lineBreakMode:UILineBreakModeClip];
    NSLog(@"tempSize: width = %.2f, height = %.2f", tempSize.width, tempSize.height);
    //[title drawAtPoint:CGPointMake((320 - tempSize.width)/2, 0.0) withFont:font];
    [title drawAtPoint:CGPointMake((width - tempSize.width)/2, (height - tempSize.height)/2 + yoffset) withFont:font];
    
    // assign context to UIImage
    UIImage *outputImg = UIGraphicsGetImageFromCurrentImageContext();
    
    // end context
    UIGraphicsEndImageContext();
    
    return outputImg;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    float width = self.view.bounds.size.width;
    
    //testing
    //the following is needed with the UINavigationBarCategory interface in AppDelegate.m
    if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        //[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"AApp_header.png"] forBarMetrics:UIBarMetricsDefault];
        //AppDelegate *appDelegate =
        //(AppDelegate*)[[UIApplication sharedApplication] delegate];
        //[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:appDelegate.config.header] forBarMetrics:UIBarMetricsDefault];
        
        [self.navigationController.navigationBar setBackgroundImage:[self headerImage] forBarMetrics:UIBarMetricsDefault];
    }
    
    self.navigationItem.title = @"Back";
    
    UILabel *label = [[UILabel alloc] init];
    self.navigationItem.titleView = label;
    label.text = @"";
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    /*
    //Johnson testing(modify status bar background)
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0,width, 20)];
    view.backgroundColor=[UIColor colorWithRed: 182/255.0 green:205/255.0 blue:216/255.0 alpha:1.0];
    [self.navigationController.view addSubview:view];
     */

    
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
