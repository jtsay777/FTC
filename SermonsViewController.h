//
//  SermonsViewController.h
//  Apostolic
//
//  Created by Ben Gomez on 11/6/12.
//  Copyright (c) 2012 Jway Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDataXMLNode.h"

@interface SermonsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
     NSMutableArray *sermonList;
    UIBarButtonItem *refreshButton;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
