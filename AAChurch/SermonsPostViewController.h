//
//  SermonsPostViewController.h
//  Apostolic
//
//  Created by Ben Gomez on 11/8/12.
//  Copyright (c) 2012 Jway Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedItem.h"

@interface SermonsPostViewController : UIViewController

@property (weak, nonatomic) FeedItem *feedItem;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *creatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
