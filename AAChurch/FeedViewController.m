//
//  FeedViewController.m
//  AAChurch
//
//  Created by Ben Gomez on 8/10/12.
//  Copyright (c) 2012 Jway Group. All rights reserved.
//

#import "FeedViewController.h"
#import "FeedItem.h"
//#import "WebViewController.h"
#import "FeedPostViewController.h"
#import "AppDelegate.h"

//make a UIImage category to do crop function
@implementation UIImage (Crop)

- (UIImage *)crop:(CGRect)rect {
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    if (scale>1.0) {
        rect = CGRectMake(rect.origin.x*scale , rect.origin.y*scale, rect.size.width*scale, rect.size.height*scale);
        NSLog(@"scale = %f", scale);
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return result;
}

@end


@interface FeedViewController () {
    int newsCount;
    int eventsCount;
    int blogCount;
}

@end

@implementation FeedViewController

//web service & XML

@synthesize feedSegmentedControl;
@synthesize line1Label;
@synthesize line2Label;
//@synthesize feedImageView;
//@synthesize mediaTableView;
@synthesize newsTableView;
@synthesize eventsTableView;
@synthesize blogTableView;

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
    
    CGContextSetRGBFillColor(context, 48/255.0, 197/255.0, 244/255.0, 1.0);//work!
    
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



- (UIImage *)offlineImage:(NSString *)imageName
{
    // Create new offscreen context with desired size
    UIGraphicsBeginImageContext(CGSizeMake(320.0f, 480.0f));
    
    //CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIImage *image = [UIImage imageNamed:imageName];
    [image drawAtPoint:CGPointMake(0, 0)];
    
    // assign context to UIImage
    UIImage *outputImg = UIGraphicsGetImageFromCurrentImageContext();
    
    // end context
    UIGraphicsEndImageContext();
    
    return outputImg;
}


- (FeedItem *)getFeedItemByType:(int)type index:(int)selection {
    FeedItem *feedItem;
    
    /*
    switch (type) {
        case News:
            feedItem = (FeedItem *)[newsList objectAtIndex:selection];
            break;
            
        case Events:
            feedItem = (FeedItem *)[eventsList objectAtIndex:selection];
            break;
            
        case Blog:
            feedItem = (FeedItem *)[blogList objectAtIndex:selection];
            break;
    }
    */
    
    feedItem = (FeedItem *)[newsList objectAtIndex:selection];
    
    return  feedItem;
}

/*
- (BOOL)isOneOfListByType:(int)type link:(NSString *)link {
    NSArray *feedList;
    BOOL result = NO;
    
    switch (type) {
        case News:
            feedList = newsList;
            break;
            
        case Events:
            feedList = eventsList;
            break;
            
        case Blog:
            feedList = blogList;
            break;
    }
    
    for (int i = 0; i < [feedList count]; i++) {
        
        FeedItem *item = [feedList objectAtIndex:i];
        
        if ([item.link isEqualToString:link]) {
            result = YES;
            break;
        }
    }
    
    return result;
}
*/

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
        GDataXMLElement *featuredimg;
        
        /*
        if (tabSelection == News) {
            [newsList removeAllObjects];
        }
        else if (tabSelection == Events) {
            [eventsList removeAllObjects];
        }
        else if (tabSelection == Blog) {
            [blogList removeAllObjects];
        }
        */
        [newsList removeAllObjects];
        NSLog(@"newsList's count = %d, after removeAllObjects", [newsList count]);
        
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
            
            NSArray *featuredimgs = [item elementsForName:@"featuredimg"];
            featuredimg = [featuredimgs lastObject];
            NSString *featuredimgStr = featuredimg.stringValue;
            myItem.featuredImageURL = featuredimgStr;
            NSLog(@"featuredimg = %@", featuredimgStr);
            
            //try to get item's category
            NSArray *categories = [item elementsForName:@"category"];
            category = [categories lastObject];
            NSString *categoryStr = category.stringValue;
            NSLog(@"category = %@", categoryStr);
            
            /*
            if (tabSelection == News && [categoryStr isEqualToString:@"News"]) {
                myItem.type = News;
                [newsList addObject:myItem];
                NSLog(@"News Title = %@", myItem.title);
            }
            else if (tabSelection == Events && [categoryStr isEqualToString:@"Events"]) {
                myItem.type = Events;
                [eventsList addObject:myItem];
            }
            else if (tabSelection == Blog && [categoryStr isEqualToString:@"GetInvolved"]) {
                myItem.type = Blog;
                [blogList addObject:myItem];
            }
            */
            if (tabSelection == News && [categoryStr isEqualToString:@"News"]) {
                myItem.type = News;
                [newsList addObject:myItem];
                NSLog(@"News Title = %@", myItem.title);
            }
            else if (tabSelection == Events && [categoryStr isEqualToString:@"Events"]) {
                myItem.type = Events;
                [newsList addObject:myItem];
            }
            else if (tabSelection == Blog && [categoryStr isEqualToString:@"GetInvolved"]) {
                myItem.type = Blog;
                [newsList addObject:myItem];
            }
            
            /*
            if ([categoryStr isEqualToString:@"News"]) {
                [newsList addObject:myItem];
            }
            else if ([categoryStr isEqualToString:@"Events"]) {
                [eventsList addObject:myItem];
            }
            else if ([categoryStr isEqualToString:@"Blog"]) {
                [blogList addObject:myItem];
            }
            else if ([categoryStr isEqualToString:@"Media"]) {
                [mediaList addObject:myItem];
            }
            */

        }
    }
}

- (void)getFeed
{
    //NSString *urlString = @"http://app.apostolicassembly.org/index.php/feed/";
    //NSString *urlString = @"http://fountainoftruth.com/feed/";
    AppDelegate *appDelegate =
    (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *urlString = appDelegate.config.rssFeed;
    NSLog(@"urlString = %@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    //turn on activityindicator
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]  initWithFrame:CGRectMake(0.0f, 0.0f, 64.0f, 64.0f)];
    [activityIndicator setCenter:CGPointMake(160.0f, 120.0f)];
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
            /*
            if (tabSelection == News) {
                [newsTableView reloadData];
            }
            else if (tabSelection == Events) {
                [eventsTableView reloadData];
            }
            else if (tabSelection == Blog) {
                [blogTableView reloadData];
            }
            */
            [newsTableView reloadData];

            /*
            [newsTableView reloadData];
            [eventsTableView reloadData];
            [blogTableView reloadData];
            [mediaTableView reloadData];
            */
            
            [activityIndicator removeFromSuperview];
            
        });

        
    }];
}


- (IBAction)selectionChanged:(UISegmentedControl *)sender {
    NSLog(@"segmentedControl selection = %d", sender.selectedSegmentIndex);
    
    //UIColor *darkBlue = [UIColor colorWithRed: 53/255.0 green:109/255.0 blue:129/255.0 alpha:1.0];//dark blue
    //UIColor *lightBlue = [UIColor colorWithRed: 55/255.0 green:206/255.0 blue:255/255.0 alpha:1.0];//light blue
 
    AppDelegate *appDelegate =
    (AppDelegate*)[[UIApplication sharedApplication] delegate];

    UIColor *darkBlue = appDelegate.config.segmentedControlUnselectedColor;//dark blue
    UIColor *lightBlue = appDelegate.config.segmentedControlSelectedColor;//light blue
    

    
    for (int i=0; i<[sender.subviews count]; i++)
    {
        if ([[sender.subviews objectAtIndex:i]isSelected] )
        {
            [[sender.subviews objectAtIndex:i] setTintColor:lightBlue];
        } else {
            [[sender.subviews objectAtIndex:i] setTintColor:darkBlue];
        }
    }

    
    tabSelection = sender.selectedSegmentIndex;
    
    [self getFeed];
    
    /*
    switch (sender.selectedSegmentIndex) {
        case News:
            NSLog(@"do News");
            [self.view bringSubviewToFront:newsTableView];
            
            break;
            
        case Events:
            NSLog(@"do Events");
            [self.view bringSubviewToFront:eventsTableView];
            
            break;
            
        case Blog:
            NSLog(@"do Blog");
            [self.view bringSubviewToFront:blogTableView];
            
            break;
    }
    */

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
    
    AppDelegate *appDelegate =
    (AppDelegate*)[[UIApplication sharedApplication] delegate];

    
    UIColor *headerColor = [UIColor colorWithRed: 182/255.0 green:205/255.0 blue:216/255.0 alpha:1.0];
    
    line1Label.textColor = headerColor;
    line1Label.font = [UIFont fontWithName:appDelegate.config.fontName size:18];
    line1Label.text = @"Access the latest videos, blogs and news";
    line1Label.hidden = YES;
    
    line2Label.textColor = headerColor;
    line2Label.font = [UIFont fontWithName:appDelegate.config.fontName size:18];
    line2Label.text = @"from the Apostolic Assembly.";
    line2Label.hidden = YES;
    
    
    //self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"AAapp_bg_discover.png"]];
    
    //self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"AAapp_bg_plain.png"]];
    
    //self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"AAapp_bg_feed.png"]];
    
    /*
    UIImage *imageToCrop;
    UIImage *croppedImage;
    CGRect cropRect;
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    imageToCrop = [self offlineImage:@"AAapp_bg_feed.png"];
    if (scale > 1.0) {
        cropRect = CGRectMake(0, 25, 320, 460);
    }
    else {
        cropRect = CGRectMake(0, 50, 320, 460);
    }
    
    croppedImage = [imageToCrop crop:cropRect];
    
    //self.view.backgroundColor = [UIColor colorWithPatternImage: croppedImage];
     
    */
    
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"AAapp_bg_discover.png"]];

    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:appDelegate.config.discoverBackground]];//use imageview instead(Johnson)
    
    /*
    self.newsTableView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"AAapp_bg_plain.png"]];
    
    self.eventsTableView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"AAapp_bg_plain.png"]];
    
    self.blogTableView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"AAapp_bg_plain.png"]];
    
    self.mediaTableView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"AAapp_bg_plain.png"]];
    */

    
    [newsTableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:appDelegate.config.plainBackground]]];
    
    [eventsTableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:appDelegate.config.plainBackground]]];

    [blogTableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:appDelegate.config.plainBackground]]];
    
    //[mediaTableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AAapp_bg_plain.png"]]];

    ///*
    //testing//Johnson
    //the following is needed with the UINavigationBarCategory interface in AppDelegate.m
    if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        //[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"AApp_header.png"] forBarMetrics:UIBarMetricsDefault];
 
        //[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:appDelegate.config.header] forBarMetrics:UIBarMetricsDefault];
        
        [self.navigationController.navigationBar setBackgroundImage:[self headerImage] forBarMetrics:UIBarMetricsDefault];
    }
    //*/
    //[self.navigationController.navigationBar setBackgroundColor:[UIColor redColor]];
    //[self.navigationController.navigationBar setTintColor:[UIColor redColor]];
    //[[UINavigationBar appearance] setBarTintColor:[UIColor blueColor]];
    //self.title = @"Fountain Of Truth";//doesn't work
    //[self.navigationController.navigationBar setBackgroundColor:[UIColor yellowColor]];
    
    
    
    [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:80/255.0 green:157/255.0 blue:173/255.0 alpha:1.0]];
    
    //self.navigationItem.title = @"Discover";
    self.navigationItem.title = @"Back";
    
    //The following will not show the Back on the navigationItem title?
    UILabel *label = [[UILabel alloc] init];
    self.navigationItem.titleView = label;
    label.text = @"";
    
    /*
    //Johnson testing(modify status bar background)
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0,width, 20)];
    view.backgroundColor=[UIColor colorWithRed: 182/255.0 green:205/255.0 blue:216/255.0 alpha:1.0];
    [self.navigationController.view addSubview:view];
    */
    
    //self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AApp_header.png"]];//Johnson
    
    //testing
    //UIColor *darkBlue = [UIColor colorWithRed: 53/255.0 green:109/255.0 blue:129/255.0 alpha:1.0];//dark blue
    //UIColor *lightBlue = [UIColor colorWithRed: 55/255.0 green:206/255.0 blue:255/255.0 alpha:1.0];//light blue
    
    UIColor *darkBlue = appDelegate.config.segmentedControlUnselectedColor;//dark blue
    UIColor *lightBlue = appDelegate.config.segmentedControlSelectedColor;//light blue
    
    newsList = [[NSMutableArray alloc] init];
    eventsList = [[NSMutableArray alloc] init];
    blogList = [[NSMutableArray alloc] init];
    mediaList = [[NSMutableArray alloc] init];
    
    NSString *version = [[UIDevice currentDevice] systemVersion];
    int number = [version integerValue];
    NSLog(@"version = %d", number);

    if (number >= 6) {
        //With the introduction of iOS 6 setting the tint color of the selected item for the first time in the viewDidLoad method won't work, to get around this I used grand central dispatch to change the selected color after a fraction of a second like so:
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.05 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
            [self selectionChanged:feedSegmentedControl];
        });
     }
    else {
        //feedSegmentedControl.selectedSegmentIndex = 0;
        for (int i=0; i<[feedSegmentedControl.subviews count]; i++)
        {
            if ([[feedSegmentedControl.subviews objectAtIndex:i] isSelected] )
            {
                [[feedSegmentedControl.subviews objectAtIndex:i] setTintColor:lightBlue];
            } else {
                [[feedSegmentedControl.subviews objectAtIndex:i] setTintColor:darkBlue];
            }
        }

        [self getFeed];
    }
    
    [self.view bringSubviewToFront:newsTableView];
    
    /*
    newsTableView.hidden = NO;
    eventsTableView.hidden = YES;
    blogTableView.hidden = YES;
    mediaTableView.hidden = YES;
    */
}

- (void)viewDidUnload
{
    //[self setFeedImageView:nil];
    //[self setMediaTableView:nil];
    [self setNewsTableView:nil];
    [self setEventsTableView:nil];
    [self setBlogTableView:nil];
    [self setFeedSegmentedControl:nil];
    [self setLine1Label:nil];
    [self setLine2Label:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UIImage *)monthAndDayImage:(NSString *)month day:(NSString *)day
{
    AppDelegate *appDelegate =
    (AppDelegate*)[[UIApplication sharedApplication] delegate];

    UIColor *dateColor = [UIColor colorWithRed: 182/255.0 green:205/255.0 blue:216/255.0 alpha:1.0];
    
    // Create new offscreen context with desired size
    UIGraphicsBeginImageContext(CGSizeMake(40.0f, 40.0f));
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGColorRef fillColor = [[UIColor whiteColor] CGColor];//only black and white
	CGContextSetFillColor(context, CGColorGetComponents(fillColor));
	
	CGContextBeginPath(context);
    //CGContextFillRect(context, CGRectMake(0, 0, 40, 40));
    //CGContextFillEllipseInRect(context, CGRectMake(0, 0, 40, 40));
	CGContextFillPath(context);
    
    
    //CGContextSetFillColorWithColor(context, [[UIColor redColor] CGColor]);//redColor works
    CGContextSetFillColorWithColor(context, [dateColor CGColor]);
    
    //UIFont *font = [UIFont fontWithName:@"Helvetica" size:12];
    //UIFont *font = [UIFont fontWithName:@"Times New Roman" size:12];
    //UIFont *font = [UIFont fontWithName:@"Courier-Bold" size:12];
    
    UIFont *font = [UIFont fontWithName:appDelegate.config.fontName size:12];
    CGSize tempSize = [month sizeWithFont:font constrainedToSize:CGSizeMake(40.0, 20.0) lineBreakMode:UILineBreakModeClip];
    [month drawAtPoint:CGPointMake((40 - tempSize.width)/2, 0.0) withFont:font];
    
    //font = [UIFont fontWithName:@"Helvetica" size:16];
    font = [UIFont fontWithName:appDelegate.config.fontName size:20];
    tempSize = [day sizeWithFont:font constrainedToSize:CGSizeMake(40.0, 20.0) lineBreakMode:UILineBreakModeClip];
    [day drawAtPoint:CGPointMake((40 - tempSize.width)/2, 15.0) withFont:font];
    
    // assign context to UIImage
    UIImage *outputImg = UIGraphicsGetImageFromCurrentImageContext();
    
    // end context
    UIGraphicsEndImageContext();
    
    return outputImg;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSLog(@"newsList's count = %d", [newsList count]);
    newsCount = [newsList count];
    return [newsList count];
    
    /*
    if (tableView == self.newsTableView) {
        NSLog(@"newsTableView - number of rows: %d",[newsList count]);
        newsCount = [newsList count];
        return [newsList count];
    }
    else if (tableView == self.eventsTableView) {
        NSLog(@"eventsTableView - number of rows: %d",[eventsList count]);
        eventsCount = [eventsList count];
        return [eventsList count];
    }
    else if (tableView == self.blogTableView) {
        NSLog(@"blogTableView - number of rows: %d",[blogList count]);
        blogCount = [blogList count];
        return [blogList count];
    }
    */
    
    return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AppDelegate *appDelegate =
    (AppDelegate*)[[UIApplication sharedApplication] delegate];

    
    UIColor *authorColor = appDelegate.config.majorColor;//[UIColor colorWithRed: 88/255.0 green:158/255.0 blue:208/255.0 alpha:1.0];
    
    static NSString *newsCellIdentifier = @"newsCell";
    static NSString *eventsCellIdentifier = @"eventsCell";
    static NSString *blogCellIdentifier = @"blogCell";
    //static NSString *mediaCellIdentifier = @"mediaCell";
    
    UITableViewCell *cell;
    FeedItem *item;
    
    /*
    if (tableView == self.newsTableView) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:newsCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:newsCellIdentifier];
        }
        
        item = (FeedItem*)[newsList objectAtIndex:indexPath.row];
        cell.textLabel.text = item.title;
        cell.detailTextLabel.text = item.creator;
        
    } else if (tableView == self.eventsTableView) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:eventsCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:eventsCellIdentifier];
        }
        
        item = (FeedItem*)[eventsList objectAtIndex:indexPath.row];
        cell.textLabel.text = item.title;
        cell.detailTextLabel.text = item.creator;
        
    } else if (tableView == self.blogTableView) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:blogCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:blogCellIdentifier];
        }
        
        item = (FeedItem*)[blogList objectAtIndex:indexPath.row];
        cell.textLabel.text = item.title;
        cell.detailTextLabel.text = item.creator;
        
    }
    */
    cell = [tableView dequeueReusableCellWithIdentifier:newsCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:newsCellIdentifier];
    }
    
    item = (FeedItem*)[newsList objectAtIndex:indexPath.row];
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = item.creator;

    
    cell.imageView.image = [self monthAndDayImage:item.month day:item.day];
    
    cell.textLabel.font = [UIFont fontWithName:appDelegate.config.fontName size:20];
    cell.detailTextLabel.textColor = authorColor;
    cell.detailTextLabel.font = [UIFont fontWithName:appDelegate.config.fontName size:11];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:(76/255.0) green:(196/255.0) blue:(207/255.0) alpha:1];
    cell.selectedBackgroundView = selectionColor;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    //the following works but we will segue mechanism instead.
    /*
     NSLog(@"section = %d, row = %d", indexPath.section, indexPath.row);
     SearchDetailViewController *detailVC = [[SearchDetailViewController alloc] init];
     detailVC.dataSource = self;
     if (indexPath.section == 3) {
     //set isForState = YES
     detailVC.isForState = YES;
     }
     else if (indexPath.section == 4) {
     //set isForState = NO
     detailVC.isForState = NO;
     }
     
     [self.navigationController pushViewController:detailVC animated:YES];
     */
    
    //[self performSegueWithIdentifier:@"ShowLink" sender:self];
    //[self performSegueWithIdentifier:@"ShowFeedPost" sender:self];
}


// Do some customisation of our new view when a table item has been selected
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /*
    // Make sure we're referring to the correct segue
    if ([[segue identifier] isEqualToString:@"ShowLink"]) {
        
        // Get reference to the destination view controller
        WebViewController *detailVC = [segue destinationViewController];
        
        // get the selected index
        NSIndexPath *indexPath;
        
        NSString *link;
        
        if (tabSelection == News) {
            indexPath = [self.newsTableView indexPathForSelectedRow];
            link = ((FeedItem*)[newsList objectAtIndex:indexPath.row]).link;
        }
        else if (tabSelection == Events) {
            indexPath = [self.eventsTableView indexPathForSelectedRow];
            link = ((FeedItem*)[eventsList objectAtIndex:indexPath.row]).link;
        }
        else if (tabSelection == Blog) {
            indexPath = [self.blogTableView indexPathForSelectedRow];
            link = ((FeedItem*)[blogList objectAtIndex:indexPath.row]).link;
        }
        else if (tabSelection == Media) {
            indexPath = [self.mediaTableView indexPathForSelectedRow];
            link = ((FeedItem*)[mediaList objectAtIndex:indexPath.row]).link;
        }
        
        detailVC.link = link;
    }
    */
    
    // Make sure we're referring to the correct segue
    if ([[segue identifier] isEqualToString:@"ShowFeedPost"]) {
        
        // Get reference to the destination view controller
        FeedPostViewController *feedPostVC = [segue destinationViewController];
        
        // get the selected index
        NSIndexPath *indexPath;
        int selection;
        int count;
        int type;
        
        //NSString *link;
        FeedItem *feedItem;
        
        /*
        if (tabSelection == News) {
            indexPath = [self.newsTableView indexPathForSelectedRow];
            selection =indexPath.row;
            count = newsCount;
            type = News;
            feedItem = ((FeedItem*)[newsList objectAtIndex:indexPath.row]);
        }
        else if (tabSelection == Events) {
            indexPath = [self.eventsTableView indexPathForSelectedRow];
            selection =indexPath.row;
            count = eventsCount;
            type = Events;
            feedItem = ((FeedItem*)[eventsList objectAtIndex:indexPath.row]);
        }
        else if (tabSelection == Blog) {
            indexPath = [self.blogTableView indexPathForSelectedRow];
            selection =indexPath.row;
            count = blogCount;
            type = Blog;
            feedItem = ((FeedItem*)[blogList objectAtIndex:indexPath.row]);
        }
        */
        /*
        if (tabSelection == News) {
            indexPath = [self.newsTableView indexPathForSelectedRow];
            selection =indexPath.row;
            count = newsCount;
            type = News;
            feedItem = ((FeedItem*)[newsList objectAtIndex:indexPath.row]);
        }
        else if (tabSelection == Events) {
            indexPath = [self.newsTableView indexPathForSelectedRow];
            selection =indexPath.row;
            count = eventsCount;
            type = Events;
            feedItem = ((FeedItem*)[newsList objectAtIndex:indexPath.row]);
        }
        else if (tabSelection == Blog) {
            indexPath = [self.newsTableView indexPathForSelectedRow];
            selection =indexPath.row;
            count = blogCount;
            type = Blog;
            feedItem = ((FeedItem*)[newsList objectAtIndex:indexPath.row]);
        }
        */
        
        indexPath = [self.newsTableView indexPathForSelectedRow];
        selection =indexPath.row;
        count = newsCount;
        type = tabSelection;
        feedItem = ((FeedItem*)[newsList objectAtIndex:indexPath.row]);
        
        NSLog(@"type = %d, count = %d", tabSelection, count);
        
        
        feedPostVC.feedItem = feedItem;
        feedPostVC.currentSelection = selection;
        feedPostVC.totalCount = count;
        feedPostVC.feedType = type;
        feedPostVC.delegate = self;
    }

}


@end
