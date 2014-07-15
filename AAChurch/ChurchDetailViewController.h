//
//  ChurchDetailViewController.h
//  AAChurch
//
//  Created by Ben Gomez on 8/4/12.
//  Copyright (c) 2012 Jway Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Church.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

enum {
    DoDirection,
    DoDial,
    DoWebsite,
    DoEmail
};

@interface ChurchDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) Church *church;
@property (weak, nonatomic) IBOutlet UILabel *pastorName;
@property (weak, nonatomic) IBOutlet UILabel *churchName;
@property (weak, nonatomic) IBOutlet UILabel *districtName;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
