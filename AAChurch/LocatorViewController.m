//
//  LocatorViewController.m
//  AAChurch
//
//  Created by Ben Gomez on 8/3/12.
//  Copyright (c) 2012 Jway Group. All rights reserved.
//

#import "LocatorViewController.h"
#import "Church.h"
#import "ChurchDetailViewController.h"

//#define SERVICEROOT @"http://www.apostolicassembly.org/api"
//#define SERVICEROOT @"http://apostolic.cloudfoundry.com"
//#define SERVICEROOT @"http://ve.cwgbdp2f.vesrv.com:8080/apostolic"
#define SERVICEROOT @"http://aa4god.com/apostolic"

@implementation Annotation

@synthesize coordinate;
@synthesize mTitle, mSubTitle;

- (NSString *)subtitle{
	return mSubTitle;
}
- (NSString *)title{
	return mTitle;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
	//coordinate=c;
	NSLog(@"%f,%f",c.latitude,c.longitude);
    
    self = [super init];
    
    if (self != nil) {
        coordinate = c;
    }
    
	return self;
}

@end


@interface LocatorViewController ()

@end

@implementation LocatorViewController
@synthesize locatorSegmentedControl;
@synthesize locatorSearchBar;
@synthesize locatorTableView;
@synthesize mapView;
@synthesize radiusSlider;
@synthesize nearbyTableView;

enum {
	Nearby,
	Search,
    Map
};

//web service & XML
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



- (void)getCoordinate {
	if (locationManager == nil) {
		locationManager = [[CLLocationManager alloc] init];
		locationManager.delegate = self;
		locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
		//locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
		//locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; // 10 m
		locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	}
	[locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
	NSLog(@"latitude: %f, longitude: %f\n", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
	NSLog(@"horizontalAccuracy = %.2f\n", newLocation.horizontalAccuracy);
	
    
	
#if TARGET_IPHONE_SIMULATOR
	
	NSLog(@"Running in Simulator\n");
	//accuracy in meters
	if (newLocation.horizontalAccuracy > 200) {
		return;
	}
	
#else
	NSLog(@"Running on the Device\n");
	NSTimeInterval howRecent = [newLocation.timestamp timeIntervalSinceNow];
	if (howRecent < -10) {
		return;
	}
	
	//accuracy in meters
	if (newLocation.horizontalAccuracy > 100) {
		return;
	}
	
#endif
	
	latitude = newLocation.coordinate.latitude;
	longitude = newLocation.coordinate.longitude;
    
    appDelegate.latitude = latitude;
    appDelegate.longitude = longitude;
    
    NSLog(@"latitude = %f, longitude = %f", latitude, longitude);
		
	[locationManager stopUpdatingLocation];
    
    //[self doNearby];
    [self getChurchList];
	
	//[self performSelectorInBackground:@selector(backgroundTask) withObject:nil];
}

-(void) locationDenied {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                              //message:@"\n\n\n\n\n\n" // IMPORTANT
                                                        message:@"Sorry, AAChurch has to know your location in order to work. Go to iPhone Settings to manually turn on Location Service for AAChurch."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [alertView setTransform:CGAffineTransformMakeTranslation(0.0, 110.0)];
    [alertView show];
}


- (void)locationManager:(CLLocationManager*)aManager didFailWithError:(NSError*)anError
{
    NSString *message;
    switch([anError code])
    {
            //NSString *message;
        case kCLErrorLocationUnknown: // location is currently unknown, but CL will keep trying
            break;
            
        case kCLErrorDenied: // CL access has been denied (eg, user declined location use)
            //message = @"Sorry, AAChurch has to know your location in order to work. Go to Settings to manually turn on Location Service for AAChurch.";
            [self locationDenied];
            break;
            
        case kCLErrorNetwork: // general, network-related error
            message = @"AAChurch can't find you - please check your network connection or that you are not in airplane mode";
    }
}

//Map View stuff

- (void)doAnnotation {
    
    //clean the annotation first
    [mapView removeAnnotations:mapView.annotations];
    
    
	NSArray *annotationArray;
    
    if (selectionBeforeMap == Nearby) {
        annotationArray = nearbyChurchList;
    } else if (selectionBeforeMap == Search) {
        annotationArray = searchChurchList;
    }
	
	int count = [annotationArray count];
	//for (int i = 0; i < count; i++) {
    for (int i = count - 1; i >= 0; i--) {
		//NSDictionary *tempDict = [annotationArray objectAtIndex:i];
        Church *church = [annotationArray objectAtIndex:i];
		
		MKCoordinateRegion region;
		MKCoordinateSpan span;
		span.latitudeDelta=0.2;
		span.longitudeDelta=0.2;
        
		CLLocationCoordinate2D location;
        location.latitude = [church.latitude floatValue];
        location.longitude = [church.longitude floatValue];
		region.span=span;
		region.center=location;
		
		Annotation *annotation = [[Annotation alloc] initWithCoordinate:location];
        annotation.mTitle = church.name;
        annotation.mSubTitle = [NSString stringWithFormat:@"%@, %@, %@ %@", church.street, church.city, church.state, church.postalCode];
		
		[mapView addAnnotation:annotation];
		
		[mapView setRegion:region animated:TRUE];
		[mapView regionThatFits:region];
	}
    
    //[mapView setShowsUserLocation:YES];

}

- (MKAnnotationView *) mapView:(MKMapView *)sender viewForAnnotation:(id <MKAnnotation>) annotation{
	
    //without the following code the app will crash
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;  //return nil to use default blue dot view
    }

	
	MKPinAnnotationView *annView= (MKPinAnnotationView *)[sender dequeueReusableAnnotationViewWithIdentifier:@"churchAnnotation"];
	if (!annView) {
		annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"churchAnnotation"];
	}
	annView.annotation = annotation;//in case use the deque one
    	
	NSString *title = ((Annotation*)annotation).mTitle;
	NSLog(@"title in mapView = %@\n", title);
	if ([title isEqualToString:@"You are here"]) {
		annView.pinColor = MKPinAnnotationColorGreen;
	}
	else {
		annView.pinColor = MKPinAnnotationColorRed;
	}
	annView.animatesDrop=TRUE;
	annView.canShowCallout = YES;
	annView.calloutOffset = CGPointMake(-5, 5);
    
    //testing
    //instatiate a detail-disclosure button and set it to appear on right side of annotation
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    annView.rightCalloutAccessoryView = infoButton;
    
	return annView;
}

// mapView:annotationView:calloutAccessoryControlTapped: is called when the user taps on left & right callout accessory UIControls.
- (void)mapView:(MKMapView *)myMapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    NSLog(@"Enter %s", __PRETTY_FUNCTION__);
    
    NSString *name = [view.annotation  title];
    NSLog(@"church name = %@", name);
    
    NSArray *annotationArray;
    Church *church;
    
    if (selectionBeforeMap == Nearby) {
        annotationArray = nearbyChurchList;
    } else if (selectionBeforeMap == Search) {
        annotationArray = searchChurchList;
    }
	
	int count = [annotationArray count];
	for (int i = 0; i < count; i++) {
        Church *temp = [annotationArray objectAtIndex:i];
        if ([name isEqualToString:temp.name]) {
            church = temp;
            break;
        }
    }
    
    [self performSegueWithIdentifier:@"ShowChurchDetail" sender:church];
    
}

- (void)loadTempData
{
    Church *church;
    
    //nearbyChurchList = [[NSMutableArray alloc] init];
    //searchChurchList = [[NSMutableArray alloc] init];
    
    //for nearby test
    church = [[Church alloc] init];
    church.name = @"Racine";
    church.pastor = @"Juan Torres";
    church.district = @"Mid-West District";
    church.street = @"933 La Salle St.";
    church.city = @"Racine";
    church.state = @"WI";
    church.postalCode = @"53404";
    church.phone = @"3619722419";
    church.latitude = @"37.766834";
    church.longitude = @"-122.417417";
    church.website = @"http://westcoastct.com";
    church.email = @"info@westcoastct.com";
    [nearbyChurchList addObject:church];
    
    church = [[Church alloc] init];
    church.name = @"Albertville";
    church.pastor = @"Domingo Zuniga";
    church.district = @"National Missions";
    church.street = @"210 Sun Mountain Dr.";
    church.city = @"Albertville";
    church.state = @"AL";
    church.postalCode = @"35950";
    church.phone = @"2563551253";
    church.latitude = @"37.756834";
    church.longitude = @"-122.447417";
    church.website = @"http://westcoastct.com";
    church.email = @"info@westcoastct.com";
    [nearbyChurchList addObject:church];
    
    
    //for search test
    church = [[Church alloc] init];
    church.name = @"Racine";
    church.pastor = @"Juan Torres";
    church.district = @"Mid-West District";
    church.street = @"933 La Salle St.";
    church.city = @"Racine";
    church.state = @"WI";
    church.postalCode = @"53404";
    church.phone = @"3619722419";
    church.latitude = @"37.766834";
    church.longitude = @"-122.417417";
    [searchChurchList addObject:church];
    
    church = [[Church alloc] init];
    church.name = @"Albertville";
    church.pastor = @"Domingo Zuniga";
    church.district = @"National Missions";
    church.street = @"210 Sun Mountain Dr.";
    church.city = @"Albertville";
    church.state = @"AL";
    church.postalCode = @"35950";
    church.phone = @"2563551253";
    church.latitude = @"37.756834";
    church.longitude = @"-122.447417";
    [searchChurchList addObject:church];
    
    church = [[Church alloc] init];
    church.name = @"Avondale";
    church.pastor = @"Raymundo S Garcia";
    church.district = @"Avondale District";
    church.street = @"707 E Hill Dr.";
    church.city = @"Avondale";
    church.state = @"AZ";
    church.postalCode = @"85323";
    church.phone = @"6236984996";
    church.latitude = @"37.776834";
    church.longitude = @"-122.307417";
    [searchChurchList addObject:church];

}

//GDataXML

- (void)xmlParse:(GDataXMLDocument *)doc
{
    //NSError *error;
    /*
     //the following works
     NSArray *pastorLastNameList = [doc nodesForXPath:@"//churches/church/pastor/lastname" error:nil];
     if (pastorLastNameList) {
     NSLog(@"count of pasterLastNameList = %d", [pastorLastNameList count]);
     GDataXMLElement *lastName;
     int count = [pastorLastNameList count];
     if (count) {
     lastName = (GDataXMLElement *) [pastorLastNameList objectAtIndex:0];
     NSLog(@"pastorLastNameList[0] = %@", [pastorLastNameList objectAtIndex:0]);
     NSLog(@"first lastName = %@", lastName.stringValue);
     lastName = (GDataXMLElement *) [pastorLastNameList objectAtIndex:count-1];
     NSLog(@"pastorLastNameList[%d] = %@", count-1, [pastorLastNameList objectAtIndex:count-1]);
     NSLog(@"last lastName = %@", lastName.stringValue);
     }
     }
     */
    
    //the following works too
    NSArray *churchList = [doc nodesForXPath:@"//churches/church" error:nil];
    if (churchList) {
        GDataXMLElement *church;
        GDataXMLElement *church_name;
        GDataXMLElement *pastor;
        GDataXMLElement *district;
        GDataXMLElement *website;
        GDataXMLElement *email;
        GDataXMLElement *firstName;
        GDataXMLElement *middleInit;
        GDataXMLElement *lastName;
        GDataXMLElement *address;
        GDataXMLElement *street;
        GDataXMLElement *city;
        GDataXMLElement *state;
        GDataXMLElement *postalCode;
        GDataXMLElement *phone;
        GDataXMLElement *latitude;
        GDataXMLElement *longitude;
        NSLog(@"count of churchList = %d", [churchList count]);
        int count = [churchList count];
        /*
        if (count) {
            NSLog(@"churchList[0] = %@", [churchList objectAtIndex:0]);
            church = [churchList objectAtIndex:0];
            NSArray *phones = [church elementsForName:@"phone"];
            phone = [phones lastObject];
            NSLog(@"phone = %@", phone.stringValue);
            NSArray *church_names = [church elementsForName:@"church_name"];
            church_name = [church_names lastObject];
            NSLog(@"church_name = %@", church_name.stringValue);
            //try to get pastor's firstname and lastname
            NSArray *pastors = [church elementsForName:@"pastor"];
            pastor = [pastors lastObject];
            NSArray *firstNames = [pastor elementsForName:@"firstname"];
            firstName = [firstNames lastObject];
            NSLog(@"pastor's firstname = %@", firstName.stringValue);
            NSArray *lastNames = [pastor elementsForName:@"lastname"];
            lastName = [lastNames lastObject];
            NSLog(@"***pastor's lastname = %@", lastName.stringValue);
        }
        */
        
        
        if (tabSelection == Nearby) {
            [nearbyChurchList removeAllObjects];
        }
        else if (tabSelection == Search) {
            [searchChurchList removeAllObjects];
        }


        for (int i = 0; i < count; i++) {
        //for (int i = 0; i < 12; i++) {//testing
            Church *myChurch = [[Church alloc] init];
            church = [churchList objectAtIndex:i];
            NSArray *phones = [church elementsForName:@"phone"];
            if (phones) {
                phone = [phones lastObject];
                myChurch.phone = phone.stringValue;
            }

            NSArray *church_names = [church elementsForName:@"church_name"];
            if (church_names) {
                church_name = [church_names lastObject];
                myChurch.name = church_name.stringValue;
            }
 
            NSArray *latitudes = [church elementsForName:@"latitude"];
            latitude = [latitudes lastObject];
            myChurch.latitude = latitude.stringValue;
            NSArray *longitudes = [church elementsForName:@"longitude"];
            longitude = [longitudes lastObject];
            myChurch.longitude = longitude.stringValue;
            
            //try to get pastor's firstname and lastname
            NSArray *pastors = [church elementsForName:@"pastor"];
            if (pastors != nil) {
                pastor = [pastors lastObject];
                NSArray *firstNames = [pastor elementsForName:@"firstname"];
                firstName = [firstNames lastObject];
                NSArray *lastNames = [pastor elementsForName:@"lastname"];
                lastName = [lastNames lastObject];
                NSArray *middleInits = [pastor elementsForName:@"middleinit"];
                middleInit = [middleInits lastObject];
                NSString *pastorName;
                NSLog(@"middleinit length = %d", middleInit.stringValue.length);
                if (middleInit.stringValue && ![middleInit.stringValue isEqualToString:@" "]) {
                    pastorName = [NSString stringWithFormat:@"%@ %@ %@", firstName.stringValue, middleInit.stringValue, lastName.stringValue];
                    
                }
                else {
                    pastorName = [NSString stringWithFormat:@"%@ %@", firstName.stringValue, lastName.stringValue];
                }
                myChurch.pastor = pastorName;
            }

            NSLog(@"pastor's name = %@", myChurch.pastor);
            
            NSArray *districts = [church elementsForName:@"district_name"];
            if (districts) {
                district = [districts lastObject];
                myChurch.district = district.stringValue;
            }

            
            NSArray *websites = [church elementsForName:@"url"];
            website = [websites lastObject];
            if (website && [website.stringValue length] > 0) {
                myChurch.website = website.stringValue;
                NSLog(@"url = %@", website.stringValue);
            }
            

            NSArray *emails = [church elementsForName:@"email"];
            email = [emails lastObject];
            if (email && [email.stringValue length] > 0) {
                myChurch.email = email.stringValue;
                NSLog(@"email = %@", email.stringValue);
            }
            

            
            //address stuff
            NSArray *addresses = [church elementsForName:@"address"];
            address = [addresses lastObject];
            NSArray *streets = [address elementsForName:@"street"];
            if (streets) {
                street = [streets lastObject];
                myChurch.street = street.stringValue;
            }
  
            NSArray *citys = [address elementsForName:@"city"];
            if (citys) {
                city = [citys lastObject];
                myChurch.city = city.stringValue;
            }

            NSArray *states = [address elementsForName:@"state"];
            if (states) {
                state = [states lastObject];
                myChurch.state = state.stringValue;
            }
 
            NSArray *postalCodes = [address elementsForName:@"postalCode"];
            if (postalCodes) {
                postalCode = [postalCodes lastObject];
                myChurch.postalCode = postalCode.stringValue;
            }
  
            
            NSString *myStreet = [NSString stringWithFormat:@"%@, %@, %@ %@", myChurch.street, myChurch.city, myChurch.state, myChurch.postalCode];
            
            NSLog(@"church's address = %@", myStreet);
            
            if (tabSelection == Nearby) {
                [nearbyChurchList addObject:myChurch];
            }
            else if (tabSelection == Search) {
                [searchChurchList addObject:myChurch];
            }
        }
    }
}

- (void)xmlTest
{
    NSString *urlStr = @"http://www.apostolicassembly.org/api/churches.aspx";
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSData *xmlData = [[NSMutableData alloc] initWithContentsOfURL:url];
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
   
    if (doc) {
        //NSLog(@"%@", doc.rootElement);//this line will hang the Xcode !?
        
       [self xmlParse:doc];
    }
}

- (void)xmlTest2
{
    NSString *urlString = [NSString stringWithFormat:@"%@/churches.aspx", SERVICEROOT];
    NSLog(@"urlString = %@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    
    //turn on activityindicator
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]  initWithFrame:CGRectMake(0.0f, 0.0f, 64.0f, 64.0f)];
    [activityIndicator setCenter:CGPointMake(160.0f, 88.0f)];
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.view.window addSubview:activityIndicator];
    [activityIndicator startAnimating];

    [self downloadXmlForURL:url completionBlock:^(NSData *data, NSError *error) {
        
        NSError *xmlError;
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:data
                                                               options:0 error:&xmlError];
        
        if (doc) {
            [self xmlParse:doc];
        }
        
        //turn off activityindicator
        [activityIndicator removeFromSuperview];

    }];
}

- (void)getChurchList
{
    NSString *urlString;// = [NSString stringWithFormat:@"%@/churches.aspx", SERVICEROOT];
    if (tabSelection == Nearby) {
        urlString = [NSString stringWithFormat:@"%@/churches?latitude=%f&longitude=%f&radius=%f", SERVICEROOT, latitude, longitude, radius];
    }
    else if (tabSelection == Search) {
        //escape space with "%20"
        NSString *criterionNoSpace = [criterion stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        urlString = [NSString stringWithFormat:@"%@/churches?criteria=%@", SERVICEROOT, criterionNoSpace];
    }
    NSLog(@"urlString = %@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    
    //turn on activityindicator
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]  initWithFrame:CGRectMake(0.0f, 0.0f, 64.0f, 64.0f)];
    [activityIndicator setCenter:CGPointMake(160.0f, 88.0f)];
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.view.window addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
    [self downloadXmlForURL:url completionBlock:^(NSData *data, NSError *error) {
        
        NSString *tempStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        tempStr = [tempStr stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
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
            if (tabSelection == Nearby) {
                [self showNearby];
            }
            else if (tabSelection == Search) {
                [self showSearch];
            }
            
            [activityIndicator removeFromSuperview];

        });
        
    }];
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //[self loadTempData];
    }
    return self;
}

- (void)swipe:(UISwipeGestureRecognizer *)gestureRecognizer
{
    static int swipeCount;
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
            if (swipeCount >= 12) {
                NSLog(@"Swipe 12 times!");
                swipeCount = 0;
                
                radiusSlider.maximumValue = 12000;
             }
            
            break;
            
        default:
            break;
    }
    
}

- (IBAction)selectonChanged:(UISegmentedControl*)sender {
    NSLog(@"segmentedControl selection = %d", sender.selectedSegmentIndex);
    
    //testing
    UIColor *darkBlue = [UIColor colorWithRed: 53/255.0 green:109/255.0 blue:129/255.0 alpha:1.0];//dark blue
    UIColor *lightBlue = [UIColor colorWithRed: 55/255.0 green:206/255.0 blue:255/255.0 alpha:1.0];//light
    
    //locatorSegmentedControl.selectedSegmentIndex = 0;
    for (int i=0; i<[locatorSegmentedControl.subviews count]; i++)
    {
        if ([[locatorSegmentedControl.subviews objectAtIndex:i] isSelected] )
        {
            [[locatorSegmentedControl.subviews objectAtIndex:i] setTintColor:lightBlue];
        } else {
            [[locatorSegmentedControl.subviews objectAtIndex:i] setTintColor:darkBlue];
        }
    }
    
    
    tabSelection = sender.selectedSegmentIndex;
    
    switch (sender.selectedSegmentIndex) {
        case Nearby:
            NSLog(@"do Nearby");
            selectionBeforeMap = sender.selectedSegmentIndex;
            //[self doNearby];//called in didUpdateToLocation instead
            [self getCoordinate];
            
            locatorSearchBar.hidden = YES;
            self.mapView.hidden = YES;
            self.locatorTableView.hidden = YES;
            self.nearbyTableView.hidden = NO;
            self.radiusSlider.hidden = NO;
            [locatorSearchBar resignFirstResponder];
            
            break;
            
        case Search:
            NSLog(@"do Search");
            selectionBeforeMap = sender.selectedSegmentIndex;
            //[self xmlTest2];//testing
            //[self doSearch];
            self.mapView.hidden = YES;
            self.nearbyTableView.hidden = YES;
            self.radiusSlider.hidden = YES;
            self.locatorTableView.hidden = NO;
            self.locatorSearchBar.hidden = NO;
            
            break;
            
        case Map:
            NSLog(@"do Map");
            [self showMap];
            
            break;
            
        default:
            break;
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    locatorSearchBar.hidden = YES;
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:appDelegate.config.plainBackground]];
    
    /*
    self.nearbyTableView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"AAapp_bg_plain.png"]];
    
    self.locatorTableView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"AAapp_bg_plain.png"]];
    */
    
    [nearbyTableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:appDelegate.config.plainBackground]]];
    
    [locatorTableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:appDelegate.config.plainBackground]]];
    
    
    nearbyChurchList = [[NSMutableArray alloc] init];
    searchChurchList = [[NSMutableArray alloc] init];
    
    //testing
    //the following is needed with the UINavigationBarCategory interface in AppDelegate.m
    if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        //[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"AApp_header.png"] forBarMetrics:UIBarMetricsDefault];

        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:appDelegate.config.header] forBarMetrics:UIBarMetricsDefault];
    }
    
    //self.navigationItem.title = @"Locator";
    self.navigationItem.title = @"Back";
    
    UILabel *label = [[UILabel alloc] init];
    self.navigationItem.titleView = label;
    label.text = @"";
    
    
    //testing
    //UIColor *darkBlue = [UIColor colorWithRed: 53/255.0 green:109/255.0 blue:129/255.0 alpha:1.0];//dark blue
    //UIColor *lightBlue = [UIColor colorWithRed: 55/255.0 green:206/255.0 blue:255/255.0 alpha:1.0];//light
    
    UIColor *darkBlue = appDelegate.config.segmentedControlUnselectedColor;//dark blue
    UIColor *lightBlue = appDelegate.config.segmentedControlSelectedColor;//light blue
    
    //locatorSegmentedControl.selectedSegmentIndex = 0;
    for (int i=0; i<[locatorSegmentedControl.subviews count]; i++)
    {
        if ([[locatorSegmentedControl.subviews objectAtIndex:i] isSelected] )
        {
            [[locatorSegmentedControl.subviews objectAtIndex:i] setTintColor:lightBlue];
        } else {
            [[locatorSegmentedControl.subviews objectAtIndex:i] setTintColor:darkBlue];
        }
    }


    
    //the following is for testing only
    //[self loadTempData];
    //[self getChurchList];
    
    //[self xmlTest];
    //[self xmlTest2];
    
    //the following is for real
    radius = 50;
    
    //radiusSlider.thumbTintColor = [UIColor colorWithRed: 55/255.0 green:206/255.0 blue:255/255.0 alpha:1.0];
    
    //testing
    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [rightRecognizer setNumberOfTouchesRequired:1];
    //[self.view addGestureRecognizer:rightRecognizer];
    [self.navigationController.navigationBar addGestureRecognizer:rightRecognizer];
    

    //[self getCoordinate];
    
    NSString *version = [[UIDevice currentDevice] systemVersion];
    int number = [version integerValue];
    NSLog(@"version = %d", number);

    
    //testing
    [locatorSegmentedControl setSelectedSegmentIndex:0];
 
    //With the introduction of iOS 6 setting the tint color of the selected item for the first time in the viewDidLoad method won't work, to get around this I used grand central dispatch to change the selected color after a fraction of a second like so:
    if (number >= 6) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.05 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
            [self selectonChanged:locatorSegmentedControl];
        });
    }
    else {
       [locatorSegmentedControl sendActionsForControlEvents:UIControlEventValueChanged]; 
    }

}

- (void)viewDidUnload
{
    [self setLocatorSegmentedControl:nil];
    [self setLocatorSearchBar:nil];
    [self setLocatorTableView:nil];
    [self setMapView:nil];
    [self setNearbyTableView:nil];
    [self setRadiusSlider:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)showNearby {
    
    /*
    self.mapView.hidden = YES;
    self.locatorTableView.hidden = YES;
    self.nearbyTableView.hidden = NO;
    [locatorSearchBar resignFirstResponder];
    */
    [nearbyTableView reloadData];
}

- (void)showSearch {
    
    /*
    self.mapView.hidden = YES;
    self.nearbyTableView.hidden = YES;
    self.locatorTableView.hidden = NO;
    self.locatorSearchBar.hidden = NO;
    */
    [locatorTableView reloadData];
}

- (void)showMap {
    
    self.radiusSlider.hidden = YES;
    self.nearbyTableView.hidden = YES;
    self.locatorTableView.hidden = YES;
    self.locatorSearchBar.hidden = YES;
    [locatorSearchBar resignFirstResponder];
    self.mapView.hidden = NO;
    [self doAnnotation];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    if (tableView == self.nearbyTableView) {
        NSLog(@"number of rows: %d",[nearbyChurchList count]);
        return [nearbyChurchList count];
    }
    else if (tableView == self.locatorTableView) {
        NSLog(@"number of rows: %d",[searchChurchList count]);
        return [searchChurchList count];
    }
    
    return 0;
}


- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIColor *headerColor = [UIColor colorWithRed: 182/255.0 green:205/255.0 blue:216/255.0 alpha:1.0];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    UILabel *tempLabel=[[UILabel alloc]initWithFrame:CGRectMake(10,0,tableView.bounds.size.width,30)];
    tempLabel.backgroundColor=[UIColor clearColor];
    tempLabel.shadowColor = [UIColor blackColor];
    tempLabel.shadowOffset = CGSizeMake(0,2);
    tempLabel.textColor = headerColor; //[UIColor whiteColor]; //here u can change the text color of header
    tempLabel.font = [UIFont fontWithName:appDelegate.config.fontName size:20];
    //tempLabel.font = [UIFont boldSystemFontOfSize:18];
    
    NSString *header;
    if (tableView == locatorTableView) {
        header = [NSString stringWithFormat:@"%d Churches found", [searchChurchList count]];
    }
    else if (tableView == nearbyTableView) {
        header = [NSString stringWithFormat:@"%d Churches found within %0.f miles", [nearbyChurchList count], radius];
    }

    tempLabel.text = header;
    
    [headerView addSubview:tempLabel];


    
    return headerView;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *header;
    if (tableView == locatorTableView) {
        header = [NSString stringWithFormat:@"%d Churches found", [searchChurchList count]];
    }
    else if (tableView == nearbyTableView) {
        header = [NSString stringWithFormat:@"%d Churches found", [nearbyChurchList count]];
    }
    return header;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIColor *addressColor = [UIColor colorWithRed: 88/255.0 green:158/255.0 blue:208/255.0 alpha:1.0];
    
    static NSString *CellIdentifier = @"churchCell";
    static NSString *nearbyCellIdentifier = @"nearbyCell";
    
    UITableViewCell *cell;
    Church *church;

    if (tableView == self.locatorTableView) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }

        church = (Church*)[searchChurchList objectAtIndex:indexPath.row];
        cell.textLabel.text = church.pastor;
        //NSString *address = [NSString stringWithFormat:@"%@, %@, %@ %@", church.street, church.city, church.state, church.postalCode];
        //address = [address stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
        
        NSString *address = @"";
        /*
        if (church.street) {
            address = [NSString stringWithFormat:@"%@, %@, %@ %@", church.street, church.city, church.state, church.postalCode];
        }
        else {
            address = [NSString stringWithFormat:@"%@, %@ %@", church.city, church.state, church.postalCode];
        }
        */
        if (church.street) {
            address = [NSString stringWithFormat:@"%@", church.street];
        }
        if (church.city) {
            address = [NSString stringWithFormat:@"%@ %@", address, church.city];
        }
        if (church.state) {
            address = [NSString stringWithFormat:@"%@ %@", address, church.state];
        }
        if (church.postalCode) {
            address = [NSString stringWithFormat:@"%@ %@", address, church.postalCode];
        }
        

        cell.detailTextLabel.text = address;
        
    } else if (tableView == self.nearbyTableView) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:nearbyCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }

        church = (Church*)[nearbyChurchList objectAtIndex:indexPath.row];
        cell.textLabel.text = church.pastor;
        NSString *address = [NSString stringWithFormat:@"%@, %@, %@ %@", church.street, church.city, church.state, church.postalCode];
         cell.detailTextLabel.text = address;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.font = [UIFont fontWithName:appDelegate.config.fontName size:20];
    cell.detailTextLabel.textColor = addressColor;
    cell.detailTextLabel.font = [UIFont fontWithName:appDelegate.config.fontName size:12];
    
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
    
    [self performSegueWithIdentifier:@"ShowChurchDetail" sender:self];
}

// Do some customisation of our new view when a table item has been selected
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure we're referring to the correct segue
    if ([[segue identifier] isEqualToString:@"ShowChurchDetail"]) {
        
        // Get reference to the destination view controller
        ChurchDetailViewController *detailVC = [segue destinationViewController];
        
        // get the selected index
        NSIndexPath *indexPath;
        
        Church *church;
        if (tabSelection == Nearby) {
            indexPath = [self.nearbyTableView indexPathForSelectedRow];
            church = [nearbyChurchList objectAtIndex:indexPath.row];
        } else if (tabSelection == Search) {
            indexPath = [self.locatorTableView indexPathForSelectedRow];
            church = [searchChurchList objectAtIndex:indexPath.row];
        } else if (tabSelection == Map) {
            church = sender;
        }
        
        detailVC.church = church;
    }

}


#pragma mark <UISearchBarDelegate>

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{    
    NSLog(@"search text = %@", theSearchBar.text);
    
    criterion = theSearchBar.text;
    
    [theSearchBar resignFirstResponder];
    
    [self getChurchList];
    
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)theSearchBar
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return YES;
}

#pragma mark <UITextFieldDelegate> Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
NSLog(@"%s", __PRETTY_FUNCTION__);    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return YES;
}

//UISlider stuff
- (IBAction)radiusChanged:(UISlider *)sender {
    
    radius = sender.value;
    NSLog(@"radius = %f", radius);
}

- (IBAction)radiusTouchUpIndise:(UISlider *)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [self getChurchList];
}

@end
