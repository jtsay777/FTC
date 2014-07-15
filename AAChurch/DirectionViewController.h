//
//  DirectionViewController.h
//  AAChurch
//
//  Created by Johnson Tsay on 8/5/12.
//  Copyright (c) 2012 Jway Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Church.h"
#import "AppDelegate.h"

@interface DirectionViewController : UIViewController <UIWebViewDelegate> {
    UIActivityIndicatorView *activityIndicator;
    AppDelegate *appDelegate;
}


@property (weak, nonatomic) Church *church;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
