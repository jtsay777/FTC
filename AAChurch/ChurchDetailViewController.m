//
//  ChurchDetailViewController.m
//  AAChurch
//
//  Created by Ben Gomez on 8/4/12.
//  Copyright (c) 2012 Jway Group. All rights reserved.
//

#import "ChurchDetailViewController.h"
#import "DirectionViewController.h"
#import "WebViewController.h"

#define NoPhone @"No phone number available"

@interface ChurchDetailViewController () {
    int currentAction;
}

@end

@implementation ChurchDetailViewController

@synthesize church;
@synthesize pastorName;
@synthesize churchName;
@synthesize districtName;
@synthesize tableView;

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
    
    UIColor *headerColor = [UIColor colorWithRed: 182/255.0 green:205/255.0 blue:216/255.0 alpha:1.0];

    
    self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"AAapp_bg_results.png"]];
    
    //self.tableView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"AAapp_bg_plain.png"]];
    
    
    //[tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AAapp_bg_plain.png"]]];
    AppDelegate *appDelegate =
    (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:appDelegate.config.plainBackground]]];

    
    NSLog(@"church name = %@", church.name);
    
    if (church.pastor) {
        pastorName.text = [NSString stringWithFormat:@"Pastor %@", church.pastor];
    }
    //pastorName.font = [UIFont boldSystemFontOfSize:22];
    pastorName.font = [UIFont fontWithName:appDelegate.config.fontName size:22];
    pastorName.textColor = headerColor; //[UIColor whiteColor];
    
    //churchName.text = church.name;
    if (church.district && church.name) {
        churchName.text = [NSString stringWithFormat:@"%@ - %@", church.district, church.name];
    }
    else if (church.district) {
        churchName.text = [NSString stringWithFormat:@"%@", church.district];
    }
    else if (church.name) {
        churchName.text = [NSString stringWithFormat:@"%@", church.name];
    }
    
    churchName.font = [UIFont fontWithName:appDelegate.config.fontName size:14];
    churchName.textColor = [UIColor whiteColor];
    
    districtName.text = church.district;

    
    
    //testing
    //the following is needed with the UINavigationBarCategory interface in AppDelegate.m
    if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        //[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"AApp_header.png"] forBarMetrics:UIBarMetricsDefault];
        AppDelegate *appDelegate =
        (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:appDelegate.config.header] forBarMetrics:UIBarMetricsDefault];
    }
    
    //self.navigationItem.title = @"Church";
    self.navigationItem.title = @"Back";
    
    UILabel *label = [[UILabel alloc] init];
    self.navigationItem.titleView = label;
    label.text = @"";

}

- (void)viewDidUnload
{
    [self setPastorName:nil];
    [self setChurchName:nil];
    [self setDistrictName:nil];
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectio {
	
    int count = 2;
    
    if (church.website) {
        count++;
    }
    
    if (church.email) {
        count++;
    }
    
    return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AppDelegate *appDelegate =
    (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    UIColor *addressColor = [UIColor colorWithRed: 88/255.0 green:158/255.0 blue:208/255.0 alpha:1.0];
    
    static NSString *CellIdentifier = @"detailCell";
    
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    switch (indexPath.row) {
        case DoDirection:
            //
        {
            if (church.street) {
                cell.textLabel.text = [NSString stringWithFormat:@"%@", church.street];
            }
            else {
                cell.textLabel.text = @"";
            }
            
            NSString *temp = @"";
            if (church.city) {
                temp = [NSString stringWithFormat:@"%@", church.city];
            }
            if (church.state) {
                temp = [NSString stringWithFormat:@"%@ %@", temp, church.state];
            }
            if (church.postalCode) {
                temp = [NSString stringWithFormat:@"%@ %@", temp, church.postalCode];
            }

            
            //cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@ %@", church.city, church.state, church.postalCode];
            
            cell.detailTextLabel.text = temp;
            
            cell.imageView.image = [UIImage imageNamed:@"AAapp_ico_address.png"];
        }
            break;
        case DoDial:
        {
            if (church.phone) {
                cell.textLabel.text = [NSString stringWithFormat:@"%@", church.phone];
            }
            else {
               cell.textLabel.text = NoPhone;
            }
            
            cell.detailTextLabel.text = nil;
            cell.imageView.image = [UIImage imageNamed:@"AAapp_ico_phone.png"];
            //
        }
            break;
        case DoWebsite:
            //force website higher priority than email
            if (church.website) {
                cell.textLabel.text = church.website;
                cell.imageView.image = [UIImage imageNamed:@"AAapp_ico_link.png"];
            }
            else if (church.email) {
                cell.textLabel.text = church.email;
                cell.imageView.image = [UIImage imageNamed:@"AAapp_ico_mail.png"];
            }
            cell.detailTextLabel.text = nil;
            break;
        case DoEmail:
            cell.textLabel.text = church.email;
            cell.detailTextLabel.text = nil;
            cell.imageView.image = [UIImage imageNamed:@"AAapp_ico_mail.png"];
            break;
            
        default:
            break;
    }
    
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.font = [UIFont fontWithName:appDelegate.config.fontName size:20];
    cell.detailTextLabel.textColor = addressColor;
    cell.detailTextLabel.font = [UIFont fontWithName:appDelegate.config.fontName size:12];
    
    return cell;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSLog(@"alertView, buttonIndex=%d", buttonIndex);
     NSString *phoneNumber;
	
	if (buttonIndex == 1) {//Enter button
        if (currentAction == DoWebsite) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:church.website]];
        }
        else if (currentAction == DoDial) {
            phoneNumber = [NSString stringWithFormat:@"TEL://%@", church.phone];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: phoneNumber]];
        }
	}
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *phoneNumber;
    MFMailComposeViewController *picker;
    
    switch (indexPath.row) {
        case DoDirection:
            //
            [self performSegueWithIdentifier:@"ShowDirection" sender:self];
            break;
        case DoDial:
            currentAction = DoDial;
            //phoneNumber = [NSString stringWithFormat:@"TEL://%@", church.phone];
            //[[UIApplication sharedApplication] openURL:[NSURL URLWithString: phoneNumber]];
            //
            {
                if (church.phone && ![church.phone isEqualToString:NoPhone]) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Dialing Confirmation"
                                                                        message:@"\n\n\n\n\n" // IMPORTANT
                                                                       delegate:self
                                                              cancelButtonTitle:@"Cancel"
                                                              otherButtonTitles:@"OK", nil];
                    
                    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(12, 50, 260, 90)];
                    textView.editable = NO;
                    NSString *msg = [NSString stringWithFormat:@"You are calling the following number: %@", church.phone];
                    textView.text = msg;
                    
                    CGFloat labelFontSize = [UIFont labelFontSize];
                    textView.font = [UIFont boldSystemFontOfSize:labelFontSize];
                    [alertView addSubview:textView];
                    
                    [alertView show];

                }
                else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Dialing Confirmation"
                                                                        message:@"\n\n\n\n\n" // IMPORTANT
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                    
                    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(12, 50, 260, 90)];
                    textView.editable = NO;
                    NSString *msg = [NSString stringWithFormat:@"%@.", NoPhone];
                    textView.text = msg;
                    
                    CGFloat labelFontSize = [UIFont labelFontSize];
                    textView.font = [UIFont boldSystemFontOfSize:labelFontSize];
                    [alertView addSubview:textView];
                    
                    [alertView show];
                    
                }
            }

            break;
        case DoWebsite:
            //force website higher priority than email
            if (church.website) {
                //[[UIApplication sharedApplication] openURL:[NSURL URLWithString: church.website]];
                //[self performSegueWithIdentifier:@"ShowConnection" sender:church.website];
                currentAction = DoWebsite;
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Browsing Confirmation"
                                                                    message:@"\n\n\n\n\n" // IMPORTANT
                                                                   delegate:self
                                                          cancelButtonTitle:@"Cancel"
                                                          otherButtonTitles:@"OK", nil];
                
                UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(12, 50, 260, 90)];
                textView.editable = NO;
                NSString *msg = [NSString stringWithFormat:@"This page will open in Safari: %@", church.website];
                textView.text = msg;
        
                CGFloat labelFontSize = [UIFont labelFontSize];
                textView.font = [UIFont boldSystemFontOfSize:labelFontSize];
                [alertView addSubview:textView];
                
                [alertView show];

            }
            else if (church.email) {
                picker = [[MFMailComposeViewController alloc] init];
                picker.mailComposeDelegate = self;
                NSString *recipient = church.email;
                NSArray *recipientsArray = [NSArray arrayWithObject:recipient];
                [picker setToRecipients:recipientsArray];
                [self presentModalViewController:picker animated:YES];
            }

            //
            break;
        case DoEmail:
            if ([MFMailComposeViewController canSendMail]) {
                picker = [[MFMailComposeViewController alloc] init];
                picker.mailComposeDelegate = self;
                NSString *recipient = church.email;
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
    }

}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure we're referring to the correct segue
    if ([[segue identifier] isEqualToString:@"ShowDirection"]) {
        // Get reference to the destination view controller
        DirectionViewController *directionVC = [segue destinationViewController];
        
        directionVC.church = church;
    }
    else if ([[segue identifier] isEqualToString:@"ShowConnection"]) {
        // Get reference to the destination view controller
        WebViewController *connectVC = [segue destinationViewController];
        
        NSString *link = (NSString *)sender;
         
        connectVC.link = link;
    }
}

@end
