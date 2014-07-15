//
//  FeedItem.h
//  AAChurch
//
//  Created by Ben Gomez on 8/14/12.
//  Copyright (c) 2012 Jway Group. All rights reserved.
//
// testing for github connection

#import <Foundation/Foundation.h>

enum {
    News,
    Events,
    Blog,
    Sermons,
    Media
};


@interface FeedItem : NSObject

@property (assign, nonatomic) int type;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *link;
@property (strong, nonatomic) NSString *thumbnailURL;
@property (strong, nonatomic) NSString *creator;
@property (strong, nonatomic) NSString *year;
@property (strong, nonatomic) NSString *month;
@property (strong, nonatomic) NSString *day;
@property (strong, nonatomic) NSString *video;
@property (strong, nonatomic) NSString *audio;
@property (strong, nonatomic) NSString *featuredImageURL;
@property (strong, nonatomic) NSString *speaker;

@end
