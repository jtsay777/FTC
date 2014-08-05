//
//  SermonsViewController.m
//  Apostolic
//
//  Created by Ben Gomez on 11/6/12.
//  Copyright (c) 2012 Jway Group. All rights reserved.
//

#import "SermonsViewController.h"
#import "FeedItem.h"
#import "SermonsPostViewController.h"
#import "MyStreamingMovieViewController.h"
#import "Reachability.h"
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


@interface SermonsViewController ()

@end

@implementation SermonsViewController

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
        GDataXMLElement *audio;
        GDataXMLElement *featuredimg;
        GDataXMLElement *thumbnail;
        GDataXMLElement *speaker;
        
        [sermonList removeAllObjects];
        
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
            
            NSArray *speakers = [item elementsForName:@"speaker"];
            speaker = [speakers lastObject];
            NSString *speakerStr = speaker.stringValue;
            if (speakerStr != NULL) {
                myItem.creator = speakerStr;//for the time being
            }
            //myItem.creator = speakerStr;//for the time being
            NSLog(@"speaker = %@", speakerStr);
             
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

            
            NSArray *audios = [item elementsForName:@"audio"];
            audio = [audios lastObject];
            NSString *audioStr = audio.stringValue;
            myItem.audio = audioStr;
            NSLog(@"audio = %@", audioStr);
            
            
            //try to get item's category
            NSArray *categories = [item elementsForName:@"category"];
            category = [categories lastObject];
            NSString *categoryStr = category.stringValue;
            NSLog(@"category = %@", categoryStr);
            
            
            if ([categoryStr isEqualToString:@"Sermons"]) {
                myItem.type = Sermons;
                [sermonList addObject:myItem];
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
            
            [self.tableView reloadData];
            
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    float width = self.view.bounds.size.width;
    
    //self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"AAapp_bg_sermons.png"]];
    
    /*
    UIImage *imageToCrop;
    UIImage *croppedImage;
    CGRect cropRect;
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    imageToCrop = [self offlineImage:@"AAapp_bg_sermons.png"];
    if (scale > 1.0) {
        cropRect = CGRectMake(0, 25, 320, 460);
    }
    else {
        cropRect = CGRectMake(0, 50, 320, 460);
    }
    
    croppedImage = [imageToCrop crop:cropRect];
    
    //self.view.backgroundColor = [UIColor colorWithPatternImage: croppedImage];
    */
    
    AppDelegate *appDelegate =
    (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"AAapp_bg_sermons.png"]];
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:appDelegate.config.sermonsBackground]];//by Johnson(use logo instead)
    
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:appDelegate.config.plainBackground]]];
    
    //Johnson
    //the following is needed with the UINavigationBarCategory interface in AppDelegate.m
    if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        //[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"AApp_header.png"] forBarMetrics:UIBarMetricsDefault];

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

    
    sermonList = [[NSMutableArray alloc] init];
    
    [self getFeed];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [sermonList count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIRectCorner cornerDef;
    if (indexPath.row == 0) {
        cornerDef = UIRectCornerTopLeft;
    } else if (indexPath.row == [sermonList count] - 1) {
        cornerDef = UIRectCornerBottomLeft;
    }
    
    if (indexPath.row == 0 || indexPath.row == [sermonList count] - 1) {
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

    
    UIColor *authorColor = [UIColor colorWithRed: 88/255.0 green:158/255.0 blue:208/255.0 alpha:1.0];
    
    static NSString *sermonCellIdentifier = @"sermonCell";
    
    UITableViewCell *cell;
    FeedItem *item;
    
    cell = [tableView dequeueReusableCellWithIdentifier:sermonCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sermonCellIdentifier];
    }
    
    item = (FeedItem*)[sermonList objectAtIndex:indexPath.row];
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
    if ([[segue identifier] isEqualToString:@"ShowAudioStreamView"]) {
        
        // Get reference to the destination view controller
        //MyStreamingMovieViewController *sermonsPostVC = [segue destinationViewController];
        SermonsPostViewController *sermonsPostVC = [segue destinationViewController];
        
        // get the selected index
        NSIndexPath *indexPath;
        
        FeedItem *feedItem;
        indexPath = [self.tableView indexPathForSelectedRow];
        feedItem = ((FeedItem*)[sermonList objectAtIndex:indexPath.row]);
        //feedItem.audio = @"http://soundcloud.com/apostolicassembly-1/obispo-juan-fortino";//Johnson temporarily
        //feedItem.featuredImageURL = @"http://app.apostolicassembly.org/wp-content/uploads/2012/12/JuanF640x360.jpg";//Johnson temporarily
        
        sermonsPostVC.feedItem = feedItem;
    }
}

@end
