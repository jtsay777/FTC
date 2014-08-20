//
//  FeedPostViewController.h
//  Apostolic
//
//  Created by Ben Gomez on 11/6/12.
//  Copyright (c) 2012 Jway Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <Twitter/TWTweetComposeViewController.h>

#import "FeedItem.h"

@protocol FeedPostDelegate <NSObject>

- (FeedItem *)getFeedItemByType:(int)type index:(int)selection;
- (BOOL)isOneOfListByType:(int)type link:(NSString *)link;

@end

@interface FeedPostViewController : UIViewController <UIWebViewDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) id <FeedPostDelegate> delegate;
@property (weak, nonatomic) FeedItem *feedItem;
@property (assign) int currentSelection;
@property (assign) int totalCount;
@property (assign) int feedType;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *feedItemImageView;
@property (weak, nonatomic) IBOutlet UIWebView *feedItemWebView;
@property (weak, nonatomic) IBOutlet UIButton *prevButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *fbButton;
@property (weak, nonatomic) IBOutlet UIButton *twButton;

@end
