//
//  LocatorViewController.h
//  AAChurch
//
//  Created by Ben Gomez on 8/3/12.
//  Copyright (c) 2012 Jway Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AppDelegate.h"
#import "GDataXMLNode.h"

@interface Annotation : NSObject<MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	
	NSString *mTitle;
	NSString *mSubTitle;
}

@property (copy) NSString *mTitle;
@property (copy) NSString *mSubTitle;

-(id)initWithCoordinate:(CLLocationCoordinate2D)location;
@end


@interface LocatorViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UISearchBarDelegate, CLLocationManagerDelegate, MKMapViewDelegate>
{
    NSMutableArray *nearbyChurchList;
    NSMutableArray *searchChurchList;
    int tabSelection;
    int selectionBeforeMap;
    
    CLLocationManager *locationManager;
	double latitude;
	double longitude;
    AppDelegate *appDelegate;
    
    NSString *criterion;
    float radius;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *locatorSegmentedControl;
@property (weak, nonatomic) IBOutlet UISearchBar *locatorSearchBar;
@property (weak, nonatomic) IBOutlet UITableView *locatorTableView;
@property (weak, nonatomic) IBOutlet UITableView *nearbyTableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISlider *radiusSlider;


@end
