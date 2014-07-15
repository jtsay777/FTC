//
//  WebViewController.h
//  AAChurch
//
//  Created by Ben Gomez on 8/15/12.
//  Copyright (c) 2012 Jway Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedItem.h"

@interface WebViewController : UIViewController <UIWebViewDelegate> {
    UIActivityIndicatorView *activityIndicator;
}


@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSString *link;
@property (strong, nonatomic) FeedItem *feedItem;
@end
