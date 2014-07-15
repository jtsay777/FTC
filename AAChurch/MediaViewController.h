//
//  MediaViewController.h
//  Apostolic
//
//  Created by Ben Gomez on 11/6/12.
//  Copyright (c) 2012 Jway Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDataXMLNode.h"

@interface MediaViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate>
{
    NSMutableArray *mediaList;
    UIActivityIndicatorView *loadingIndicator;
    UIBarButtonItem *refreshButton;
}
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign) BOOL fullScreenVideoIsPlaying;

@end
