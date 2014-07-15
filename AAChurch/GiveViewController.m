//
//  GiveViewController.m
//  AAChurch
//
//  Created by Ben Gomez on 8/10/12.
//  Copyright (c) 2012 Jway Group. All rights reserved.
//

#import "GiveViewController.h"
#import "WebViewController.h"
#import "AppDelegate.h"

@interface GiveViewController ()

@end

@implementation GiveViewController
@synthesize headerLabel;
@synthesize line1Label;
@synthesize line2Label;
@synthesize line3Label;
@synthesize line4Label;

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
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    AppDelegate *appDelegate =
    (AppDelegate*)[[UIApplication sharedApplication] delegate];

    
    UIColor *headerColor = [UIColor colorWithRed: 182/255.0 green:205/255.0 blue:216/255.0 alpha:1.0];
    
    headerLabel.text = @"Your investment makes a difference";
    headerLabel.textColor = headerColor;
    headerLabel.font = [UIFont fontWithName:appDelegate.config.fontName size:24];
    
    line1Label.text = @"In this area you can invest in the following:";
    line2Label.text = @"Offering, International Missions, National Missions,";
    line3Label.text = @"Social Assistance, Christian Education, Scholarships,";
    line4Label.text = @"Flor Azul and much more.";
    
    line1Label.font = [UIFont fontWithName:appDelegate.config.fontName size:16];
    line2Label.font = [UIFont fontWithName:appDelegate.config.fontName size:16];
    line3Label.font = [UIFont fontWithName:appDelegate.config.fontName size:16];
    line4Label.font = [UIFont fontWithName:appDelegate.config.fontName size:13];
    
    line1Label.textColor = [UIColor whiteColor];
    line2Label.textColor = [UIColor whiteColor];
    line3Label.textColor = [UIColor whiteColor];
    line4Label.textColor = [UIColor whiteColor];

     self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"AAapp_bg_give.png"]];
    
    //testing
    //the following is needed with the UINavigationBarCategory interface in AppDelegate.m
    if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        //[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"AApp_header.png"] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:appDelegate.config.header] forBarMetrics:UIBarMetricsDefault];
    }
    
    //self.navigationItem.title = @"Give";
    self.navigationItem.title = @"Back";
    
    UILabel *label = [[UILabel alloc] init];
    self.navigationItem.titleView = label;
    label.text = @"";

}

- (void)viewDidUnload
{
    [self setHeaderLabel:nil];
    [self setLine1Label:nil];
    [self setLine2Label:nil];
    [self setLine3Label:nil];
    [self setLine4Label:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Do some customisation of our new view when a table item has been selected
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure we're referring to the correct segue
    if ([[segue identifier] isEqualToString:@"ShowDonation"]) {
        
        // Get reference to the destination view controller
        WebViewController *donationVC = [segue destinationViewController];
        
        //donationVC.link = @"https://www.paypal.com/cgi-bin/marketingweb?cmd=_login-run";
        //donationVC.link = @"http://apostolicassembly.org/donate";
    }
    
    
}

- (IBAction)donate:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://apostolicassembly.org/donate"]];

}


@end
