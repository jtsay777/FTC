//
//  MediaPostViewController.h
//  Apostolic
//
//  Created by Ben Gomez on 11/8/12.
//  Copyright (c) 2012 Jway Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedItem.h"

@interface MediaPostViewController : UIViewController <UIWebViewDelegate>
{
    UIActivityIndicatorView *loadingIndicator;
}

@property (weak, nonatomic) FeedItem *feedItem;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *creatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (assign) BOOL fullScreenVideoIsPlaying;

@end
