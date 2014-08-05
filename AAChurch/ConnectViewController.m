//
//  ConnectViewController.m
//  AAChurch
//
//  Created by Ben Gomez on 8/10/12.
//  Copyright (c) 2012 Jway Group. All rights reserved.
//

#import "ConnectViewController.h"
#import "WebViewController.h"
#import "AppDelegate.h"

@interface ConnectViewController () {
    int swipeCount;
    int swipeLeftCount;
}

@end

@implementation ConnectViewController
@synthesize tableView;
@synthesize connectLabel;


- (UIImage *)headerImage
{
    NSString *title = @"FOUNTAIN OF TRUTH";
    AppDelegate *appDelegate =
    (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    float width = self.view.bounds.size.width;
    float height = 44.0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) height = 64.0;
    
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
    
    UIFont *font = [UIFont fontWithName:appDelegate.config.fontName size:22];
    CGSize tempSize = [title sizeWithFont:font constrainedToSize:CGSizeMake(width, height) lineBreakMode:UILineBreakModeClip];
    NSLog(@"tempSize: width = %.2f, height = %.2f", tempSize.width, tempSize.height);
    //[title drawAtPoint:CGPointMake((320 - tempSize.width)/2, 0.0) withFont:font];
    [title drawAtPoint:CGPointMake((width - tempSize.width)/2, (height - tempSize.height)/2) withFont:font];
    
    // assign context to UIImage
    UIImage *outputImg = UIGraphicsGetImageFromCurrentImageContext();
    
    // end context
    UIGraphicsEndImageContext();
    
    return outputImg;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
            break;
            
        default:
            break;
    }
    
}

- (void)swipeLeft:(UISwipeGestureRecognizer *)gestureRecognizer
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
            if (swipeCount >= 7) {
                swipeLeftCount++;
            }
            
            if (swipeLeftCount >= 8) {
                NSLog(@"Swipe 7 and 8 times!");
                swipeCount = 0;
                swipeLeftCount = 0;
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
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //testing
    float width = self.view.bounds.size.width;
    
    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [rightRecognizer setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:rightRecognizer];
    
    UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    leftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [leftRecognizer setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:leftRecognizer];
    
    
    UIColor *headerColor = [UIColor colorWithRed: 182/255.0 green:205/255.0 blue:216/255.0 alpha:1.0];
    
    AppDelegate *appDelegate =
    (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    connectLabel.textColor = appDelegate.config.majorColor;//headerColor;
    connectLabel.font = [UIFont fontWithName:appDelegate.config.fontName size:20];
    connectLabel.text = @"Ways to connect.";
    
    
    //self.tableView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"AAapp_bg_plain.png"]];
    
    //[tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AAapp_bg_plain.png"]]];

    [tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:appDelegate.config.plainBackground]]];
    
    
    //self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"AAapp_bg_home.png"]];
    
    //self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"AAapp_bg_connect.png"]];
    //self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:appDelegate.config.connectBackground]];
    
    //testing
    //the following is needed with the UINavigationBarCategory interface in AppDelegate.m
    if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        //[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"AApp_header.png"] forBarMetrics:UIBarMetricsDefault];
        //[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:appDelegate.config.header] forBarMetrics:UIBarMetricsDefault];
        
        [self.navigationController.navigationBar setBackgroundImage:[self headerImage] forBarMetrics:UIBarMetricsDefault];
    }
    
    //self.navigationItem.title = @"Connect";
    self.navigationItem.title = @"Back";
    
    UILabel *label = [[UILabel alloc] init];
    self.navigationItem.titleView = label;
    label.text = @"";
    
    /*
    //Johnson testing(modify status bar background)
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0,width, 20)];
    view.backgroundColor=[UIColor colorWithRed: 182/255.0 green:205/255.0 blue:216/255.0 alpha:1.0];
    [self.navigationController.view addSubview:view];
     */

}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setConnectLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

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

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	switch (result) {
		case MessageComposeResultCancelled:
			NSLog(@"Cancelled");
			break;
		case MessageComposeResultFailed:
			break;
		case MessageComposeResultSent:
			
			break;
		default:
			break;
	}
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSLog(@"alertView, buttonIndex=%d", buttonIndex);
    
    AppDelegate *appDelegate =
    (AppDelegate *)[[UIApplication sharedApplication] delegate];

	
	if (buttonIndex == 1) {//Enter button
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appDelegate.config.website]];
	}
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectio {
	
     return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    AppDelegate *appDelegate =
    (AppDelegate*)[[UIApplication sharedApplication] delegate];
    

    UIColor *detailColor = appDelegate.config.majorColor;//[UIColor colorWithRed: 88/255.0 green:158/255.0 blue:208/255.0 alpha:1.0];
    
    static NSString *CellIdentifier = @"connectCell";
    
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
        
    switch (indexPath.row) {
        case Facebook:
            cell.textLabel.text = @"Facebook";
            cell.detailTextLabel.text = @"Like Us on Facebook";
            cell.imageView.image = [UIImage imageNamed:@"AAapp_ico_fb.png"];
            break;
        case Twitter:
            cell.textLabel.text = @"Twitter";
            //cell.detailTextLabel.text = @"Follow Apostolic Assembly on Twitter";
            cell.detailTextLabel.text = @"Follow Fountain Church on Twitter";
            cell.imageView.image = [UIImage imageNamed:@"AAapp_ico_tw.png"];
            break;
        case Email:
            cell.textLabel.text = @"Email";
            //cell.detailTextLabel.text = @"pr@apostolicassembly.org";
            cell.detailTextLabel.text = @"ftcchurchfontana@aol.com";
            cell.imageView.image = [UIImage imageNamed:@"AAapp_ico_em.png"];
            break;
        case Website:
            //cell.textLabel.text = @"ApostolicAssembly.org";
            //cell.detailTextLabel.text = @"Apostolic Assembly's offical Website";
            cell.textLabel.text = @"fountainoftruth.com";
            cell.detailTextLabel.text = @"Fountain Church's offical Website";
            //cell.imageView.image = [UIImage imageNamed:@"AAapp_ico_aa.png"];
            cell.imageView.image = [UIImage imageNamed:appDelegate.config.logo];
            break;
            
        default:
            break;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.font = [UIFont fontWithName:appDelegate.config.fontName size:20];
    cell.detailTextLabel.textColor = detailColor;
    cell.detailTextLabel.font = [UIFont fontWithName:appDelegate.config.fontName size:11];

    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:(76/255.0) green:(196/255.0) blue:(207/255.0) alpha:1];
    cell.selectedBackgroundView = selectionColor;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MFMailComposeViewController *picker;
    
    AppDelegate *appDelegate =
    (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    switch (indexPath.row) {
        case Facebook:
            [self performSegueWithIdentifier:@"ShowConnection" sender:appDelegate.config.facebook];
            //[self performSegueWithIdentifier:@"ShowConnection" sender:self];
            break;
            
        case Twitter:
            [self performSegueWithIdentifier:@"ShowConnection" sender:appDelegate.config.twitter];
            //[self performSegueWithIdentifier:@"ShowConnection" sender:self];
            break;
            
        case Email:
            if ([MFMailComposeViewController canSendMail]) {
                picker = [[MFMailComposeViewController alloc] init];
                picker.mailComposeDelegate = self;
                NSString *recipient = appDelegate.config.email;
                NSArray *recipientsArray = [NSArray arrayWithObject:recipient];
                [picker setToRecipients:recipientsArray];
                [self presentModalViewController:picker animated:YES];
            }
            else {
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Information"
                                                                  message:@"You need to set up an email account to be able to send an email."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
                
                [message show];
                
            }

            break;
        
        case Website:
            //[self performSegueWithIdentifier:@"ShowConnection" sender:@"http://www.apostolicassembly.org/"];
            //[self performSegueWithIdentifier:@"ShowConnection" sender:self];
        {
            /*
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Browsing Confirmation"
                                                                message:@"\n\n\n\n\n" // IMPORTANT
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"OK", nil];
            
            UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(12, 50, 260, 90)];
            textView.editable = NO;
            
            NSString *temp = [NSString stringWithFormat:@"This page will open in Safari: %@", appDelegate.config.website];
            textView.text = temp;
            
            CGFloat labelFontSize = [UIFont labelFontSize];
            textView.font = [UIFont boldSystemFontOfSize:labelFontSize];
            [alertView addSubview:textView];
             [alertView show];
             */
            
            NSString *msg = [NSString stringWithFormat:@"This page will open in Safari: %@", appDelegate.config.website];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Browsing Confirmation"
                                                                message:msg
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"OK", nil];
            
            [alertView show];

            
            
        }

            
            break;
 
    }
    
}

// Do some customisation of our new view when a table item has been selected
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure we're referring to the correct segue
    if ([[segue identifier] isEqualToString:@"ShowConnection"]) {
        
        // Get reference to the destination view controller
        WebViewController *connectVC = [segue destinationViewController];
        
        // get the selected index
        //NSIndexPath *indexPath;
        NSString *link = (NSString *)sender;
        //NSString *link = @"http://www.apostolicassembly.org/";
                
        connectVC.link = link;
    }

    
}

@end
