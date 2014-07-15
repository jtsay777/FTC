//
//  HomeViewController.h
//  AAChurch
//
//  Created by Ben Gomez on 8/10/12.
//  Copyright (c) 2012 Jway Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController {
    int swipeCount;
}

@property (weak, nonatomic) IBOutlet UILabel *discoverLabel1;
@property (weak, nonatomic) IBOutlet UILabel *discoverLabel2;
@property (weak, nonatomic) IBOutlet UILabel *discoverLabel3;
@property (weak, nonatomic) IBOutlet UILabel *locatorLabel1;
@property (weak, nonatomic) IBOutlet UILabel *locatorLabel2;
@property (weak, nonatomic) IBOutlet UILabel *locatorLabel3;
@property (weak, nonatomic) IBOutlet UILabel *locatorLabel4;
@property (weak, nonatomic) IBOutlet UILabel *giveLabel1;
@property (weak, nonatomic) IBOutlet UILabel *giveLabel2;
@property (weak, nonatomic) IBOutlet UILabel *connectLabel1;
@property (weak, nonatomic) IBOutlet UILabel *connectLabel2;
@property (weak, nonatomic) IBOutlet UILabel *connectLabel3;
@property (weak, nonatomic) IBOutlet UIButton *authButton;
@property (weak, nonatomic) IBOutlet UIButton *publishButton;

@end
