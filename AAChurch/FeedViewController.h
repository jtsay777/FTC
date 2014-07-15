//
//  FeedViewController.h
//  AAChurch
//
//  Created by Ben Gomez on 8/10/12.
//  Copyright (c) 2012 Jway Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDataXMLNode.h"
#import "FeedPostViewController.h"

@interface FeedViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, FeedPostDelegate>
{
    NSMutableArray *newsList;
    NSMutableArray *eventsList;
    NSMutableArray *blogList;
    NSMutableArray *mediaList;
    int tabSelection;
}

//@property (weak, nonatomic) IBOutlet UIImageView *feedImageView;
//@property (weak, nonatomic) IBOutlet UITableView *mediaTableView;
@property (weak, nonatomic) IBOutlet UITableView *newsTableView;
@property (weak, nonatomic) IBOutlet UITableView *eventsTableView;
@property (weak, nonatomic) IBOutlet UITableView *blogTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *feedSegmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *line1Label;
@property (weak, nonatomic) IBOutlet UILabel *line2Label;

@end
