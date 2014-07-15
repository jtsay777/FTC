//
//  SermonsPostViewController.m
//  Apostolic
//
//  Created by Ben Gomez on 11/8/12.
//  Copyright (c) 2012 Jway Group. All rights reserved.
//

#import "SermonsPostViewController.h"
#import "WebViewController.h"
#import "MyStreamingMovieViewController.h"
#import "AppDelegate.h"

@interface SermonsPostViewController ()

@end

@implementation SermonsPostViewController

- (void)streamTest {
    MyStreamingMovieViewController *viewController = [[MyStreamingMovieViewController alloc]
                                          initWithNibName:@"StreamingView"
                                          bundle:nil];
    
    viewController.feedItem = self.feedItem;
    
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)listenAction:(UIButton *)sender {
    NSLog(@"Enter: %s", __PRETTY_FUNCTION__);
}

- (IBAction)facebookAction:(UIButton *)sender {
    NSLog(@"Enter: %s", __PRETTY_FUNCTION__);
    
    AppDelegate *appDelegate =
    (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *msg = [NSString stringWithFormat:@"Check out \"%@\" via the Apostolic Assembly mobile app. Download it today!", self.feedItem.title];
    [appDelegate doFacebook:msg];
    
}

- (IBAction)twitterAction:(UIButton *)sender {
    //[self streamTest];
    NSLog(@"Enter: %s", __PRETTY_FUNCTION__);
    
    AppDelegate *appDelegate =
    (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *msg = [NSString stringWithFormat:@"Check out \"%@\" via the Apostolic Assembly mobile app. Download it today!", self.feedItem.title];
    [appDelegate doTwitter:msg];
    
}

- (IBAction)mailAction:(UIButton *)sender {
    NSLog(@"Enter: %s", __PRETTY_FUNCTION__);
    
    AppDelegate *appDelegate =
    (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *msg = [NSString stringWithFormat:@"Check out \"%@\" via the Apostolic Assembly mobile app. Download it today!", self.feedItem.title];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.currentVC = self;
    
    
    self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:appDelegate.config.plainBackground]];
    
    UIColor *titleColor = appDelegate.config.majorColor;//[UIColor colorWithRed: 182/255.0 green:205/255.0 blue:216/255.0 alpha:1.0];
    
    self.titleLabel.backgroundColor=[UIColor clearColor];
    self.titleLabel.shadowColor = [UIColor blackColor];
    self.titleLabel.shadowOffset = CGSizeMake(0,2);
    self.titleLabel.textColor = titleColor; //[UIColor whiteColor];
    self.titleLabel.font = [UIFont fontWithName:appDelegate.config.fontName size:14];
    
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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setImageView:nil];
    [self setTitleLabel:nil];
    [self setCreatorLabel:nil];
    [self setDateLabel:nil];
    [super viewDidUnload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure we're referring to the correct segue
    if ([[segue identifier] isEqualToString:@"ShowAudioStreamView"]) {
        
        // Get reference to the destination view controller
        MyStreamingMovieViewController *streamVC = [segue destinationViewController];
        
        streamVC.feedItem = self.feedItem;
        
    }
}

@end
