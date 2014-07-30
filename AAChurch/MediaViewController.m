//
//  MediaViewController.m
//  Apostolic
//
//  Created by Ben Gomez on 11/6/12.
//  Copyright (c) 2012 Jway Group. All rights reserved.
//

#import "MediaViewController.h"
#import "FeedItem.h"
#import "MediaPostViewController.h"
#import <QuartzCore/QuartzCore.h> 
#import "AppDelegate.h"

@interface MediaViewController ()

@end

@implementation MediaViewController

- (UIImage *)headerImage
{
    NSString *title = @"FOUNTAIN OF TRUTH";
    AppDelegate *appDelegate =
    (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    float width = self.view.bounds.size.width;
    float height = 64.0;
    
    //UIColor *dateColor = [UIColor colorWithRed: 182/255.0 green:205/255.0 blue:216/255.0 alpha:1.0];
    UIColor *textColor = [UIColor colorWithRed: 255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    
    // Create new offscreen context with desired size
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //CGColorRef fillColor = [[UIColor blackColor] CGColor];//only black and white?
	//CGContextSetFillColor(context, CGColorGetComponents(fillColor));
    
    CGContextSetRGBFillColor(context, 182/255.0, 205/255.0, 216/255.0, 1.0);//work!
    
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
    CGPoint top = CGPointMake(0, 0);
    [webview.scrollView setContentOffset:top animated:YES];
    

}



- (void) downloadXmlForURL:(NSURL *) url completionBlock:(void (^)(NSData *data, NSError *error)) block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
        NSData *returnData = [[NSData alloc] initWithContentsOfURL:url];
        if(returnData) {
            block(returnData, nil);
        } else {
            NSError *error = [NSError errorWithDomain:@"xml_download_error" code:1
                                             userInfo:[NSDictionary dictionaryWithObject:@"Can't fetch data" forKey:NSLocalizedDescriptionKey]];
            block(nil, error);
        }
        
    });
}

- (void)xmlParse:(GDataXMLDocument *)doc
{
    NSArray *itemList = [doc nodesForXPath:@"//channel/item" error:nil];
    if (itemList) {
        GDataXMLElement *item;
        GDataXMLElement *title;
        GDataXMLElement *link;
        GDataXMLElement *category;
        GDataXMLElement *creator;
        GDataXMLElement *pubDate;
        GDataXMLElement *video;
        GDataXMLElement *featuredimg;
        GDataXMLElement *thumbnail;
                
        [mediaList removeAllObjects];
        
        int count = [itemList count];
        NSLog(@"itemList count = %d", count);
        for (int i = 0; i < count; i++) {
            FeedItem *myItem = [[FeedItem alloc] init];
            item = [itemList objectAtIndex:i];
            NSArray *titles = [item elementsForName:@"title"];
            title  = [titles lastObject];
            NSString *titleStr = title.stringValue;
            myItem.title = titleStr;
            NSLog(@"title = %@", titleStr);
            
            NSArray *links = [item elementsForName:@"link"];
            link  = [links lastObject];
            NSString *linkStr = link.stringValue;
            myItem.link = linkStr;
            NSLog(@"link = %@", linkStr);
            
            NSArray *creators = [item elementsForName:@"dc:creator"];
            creator  = [creators lastObject];
            NSString *creatorStr = creator.stringValue;
            myItem.creator = creatorStr;
            NSLog(@"creator = %@", creatorStr);
            
            NSArray *pubDates = [item elementsForName:@"pubDate"];
            pubDate  = [pubDates lastObject];
            NSString *pubDateStr = pubDate.stringValue;
            NSLog(@"pubDate = %@", pubDateStr);
            NSArray *dateArray = [pubDateStr componentsSeparatedByString:@" "];
            if ([dateArray count] > 2) {
                NSString *year = [dateArray objectAtIndex:3];
                NSString *month = [dateArray objectAtIndex:2];
                NSString *day = [dateArray objectAtIndex:1];
                
                myItem.year = year;
                myItem.month = month;
                myItem.day = day;
            }
            
            NSArray *thumbnails = [item elementsForName:@"thumbnail"];
            thumbnail = [thumbnails lastObject];
            NSString *thumbnailStr = thumbnail.stringValue;
            myItem.thumbnailURL = thumbnailStr;
            NSLog(@"thumbnail = %@", thumbnailStr);

            
            NSArray *featuredimgs = [item elementsForName:@"featuredimg"];
            featuredimg = [featuredimgs lastObject];
            NSString *featuredimgStr = featuredimg.stringValue;
            myItem.featuredImageURL = featuredimgStr;
            NSLog(@"featuredimg = %@", featuredimgStr);
            
            NSArray *videos = [item elementsForName:@"video"];
            video = [videos lastObject];
            NSString *videoStr = video.stringValue;
            myItem.video = videoStr;
            NSLog(@"video = %@", videoStr);
            
            
            //try to get item's category
            NSArray *categories = [item elementsForName:@"category"];
            category = [categories lastObject];
            NSString *categoryStr = category.stringValue;
            NSLog(@"category = %@", categoryStr);
            
            
            if ([categoryStr isEqualToString:@"Media"]) {
                myItem.type = Media;
                [mediaList addObject:myItem];
            }
                        
        }
    }
}

- (void)getFeed
{
    //NSString *urlString = @"http://app.apostolicassembly.org/index.php/feed/";
    AppDelegate *appDelegate =
    (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *urlString = appDelegate.config.rssFeed;
    
    NSLog(@"urlString = %@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    
    refreshButton.enabled = NO;
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    //turn on activityindicator
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]  initWithFrame:CGRectMake(0.0f, 0.0f, 64.0f, 64.0f)];
    [activityIndicator setCenter:CGPointMake(160.0f, 240.0f)];
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    //[self.view.window addSubview:activityIndicator];
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
    [self downloadXmlForURL:url completionBlock:^(NSData *data, NSError *error) {
        
        //the following will remove invisible character under 10 to make GDataXML happy
        NSString *tempStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSMutableString *asciiCharacters = [NSMutableString string];
        //for (NSInteger i = 32; i < 127; i++)  {
        for (NSInteger i = 10; i < 255; i++)  {
            [asciiCharacters appendFormat:@"%c", i];
        }
        NSCharacterSet *nonAsciiCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:asciiCharacters] invertedSet];
        
        tempStr = [[tempStr componentsSeparatedByCharactersInSet:nonAsciiCharacterSet] componentsJoinedByString:@""];
        NSData* newData = [tempStr dataUsingEncoding:NSUTF8StringEncoding];
        
        
        NSError *xmlError;
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:newData
                                                               options:0 error:&xmlError];
        
        if (doc) {
            [self xmlParse:doc];
        }
        
        //turn off activityindicator
        //[activityIndicator removeFromSuperview];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.tableView reloadData];
            
            //show the first video
            if ([mediaList count] > 0) {
                FeedItem *firstItem = [mediaList objectAtIndex:0];
                
                //NSURL *url = [NSURL URLWithString:firstItem.video];//Johnson temporarily disable
                //[self.webView loadRequest:[NSURLRequest requestWithURL:url]];
                
                NSURL *url = [NSURL URLWithString:@"http://youtu.be/ql36y7Lut8Y"];
                
                [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
            }

            
            [activityIndicator removeFromSuperview];
            
            refreshButton.enabled = YES;
            
        });
        
        
    }];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)refreshClicked:(id)sender {
    NSLog(@"Enter: %s", __PRETTY_FUNCTION__);
    
    [self getFeed];
}

- (void)printSubviews: (UIView *)view {
	NSArray* subviews = [view subviews];
	
    self.fullScreenVideoIsPlaying = NO;
    
	if (subviews.count == 0) {
	}
	else {
		//NSLog(@"count of subviews = %d", subviews.count);
		for (int i = 0; i < subviews.count; i++) {
			UIView * currentView = [subviews objectAtIndex:i];
			[self printSubviews:currentView];
            NSString *name = [NSString stringWithFormat:@"%@", [currentView class]];
            //NSLog(@"name = %@\n", name);
            if ([name isEqualToString:@"MPFullScreenVideoOverlay"]) {
                self.fullScreenVideoIsPlaying = YES;
                NSLog(@"name = %@\n", name);
            }
        }
	}
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    NSLog(@"Enter %s", __PRETTY_FUNCTION__);
    
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


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    float width = self.view.bounds.size.width;
    
    AppDelegate *appDelegate =
    (AppDelegate *)[[UIApplication sharedApplication] delegate];

    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:appDelegate.config.plainBackground]]];
  
    //[self.webView setBackgroundColor:[UIColor whiteColor]];
    
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
    
    /*
    //Johnson testing(modify status bar background)
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0,width, 20)];
    view.backgroundColor=[UIColor colorWithRed: 182/255.0 green:205/255.0 blue:216/255.0 alpha:1.0];
    [self.navigationController.view addSubview:view];
    */

    
    refreshButton = [[UIBarButtonItem alloc]
                     initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                     target:self action:@selector(refreshClicked:)];
    self.navigationItem.rightBarButtonItem = refreshButton;

    
    mediaList = [[NSMutableArray alloc] init];
    
    [self getFeed];
    
    loadingIndicator = [[UIActivityIndicatorView alloc]  initWithFrame:CGRectMake(0.0f, 0.0f, 64.0f, 64.0f)];
    [loadingIndicator setCenter:CGPointMake(160.0f, 80.0f)];
    [loadingIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [loadingIndicator stopAnimating];
    [self.view addSubview:loadingIndicator];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	    
    return [mediaList count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIRectCorner cornerDef;
    if (indexPath.row == 0) {
        cornerDef = UIRectCornerTopLeft;
    } else if (indexPath.row == [mediaList count] - 1) {
        cornerDef = UIRectCornerBottomLeft;
    }
    
    if (indexPath.row == 0 || indexPath.row == [mediaList count] - 1) {
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        UIBezierPath *roundedPath = [UIBezierPath bezierPathWithRoundedRect:cell.bounds
                                                          byRoundingCorners:cornerDef cornerRadii:CGSizeMake(9.0f, 9.0f)];
        maskLayer.fillColor = [[UIColor whiteColor] CGColor];
        maskLayer.backgroundColor = [[UIColor clearColor] CGColor];
        maskLayer.path = [roundedPath CGPath];
        [cell.imageView.layer setMask:maskLayer];
        [cell.imageView.layer setMasksToBounds:YES];
        [cell.imageView setNeedsDisplay];
    }
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AppDelegate *appDelegate =
    (AppDelegate*)[[UIApplication sharedApplication] delegate];

    
    UIColor *authorColor = appDelegate.config.majorColor;//[UIColor colorWithRed: 88/255.0 green:158/255.0 blue:208/255.0 alpha:1.0];
    
    static NSString *mediaCellIdentifier = @"mediaCell";
    
    UITableViewCell *cell;
    FeedItem *item;
    
    cell = [tableView dequeueReusableCellWithIdentifier:mediaCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:mediaCellIdentifier];
    }
    
    item = (FeedItem*)[mediaList objectAtIndex:indexPath.row];
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = item.creator;
    
    
    //cell.imageView.image = [self monthAndDayImage:item.month day:item.day];
    NSURL * imageURL = [NSURL URLWithString:item.thumbnailURL];
    NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
    cell.imageView.image = [UIImage imageWithData:imageData];
    
    cell.textLabel.font = [UIFont fontWithName:appDelegate.config.fontName size:20];
    cell.detailTextLabel.textColor = authorColor;
    cell.detailTextLabel.font = [UIFont fontWithName:appDelegate.config.fontName size:11];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:(76/255.0) green:(196/255.0) blue:(207/255.0) alpha:1];
    cell.selectedBackgroundView = selectionColor;
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure we're referring to the correct segue
    if ([[segue identifier] isEqualToString:@"ShowMediaPost"]) {
        
        // Get reference to the destination view controller
        MediaPostViewController *mediaPostVC = [segue destinationViewController];
        
        // get the selected index
        NSIndexPath *indexPath;
        
        FeedItem *feedItem;
        indexPath = [self.tableView indexPathForSelectedRow];
        feedItem = ((FeedItem*)[mediaList objectAtIndex:indexPath.row]);
        
        mediaPostVC.feedItem = feedItem;
    }
}

@end
