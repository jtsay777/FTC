//
//  Config.h
//  Apostolic
//
//  Created by Ben Gomez on 1/16/13.
//  Copyright (c) 2013 Jway Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Config : NSObject

@property (strong, nonatomic) NSString *rssFeed;
@property (strong, nonatomic) NSString *logo;
@property (strong, nonatomic) NSString *splash;
@property (strong, nonatomic) NSString *header;
@property (strong, nonatomic) NSString *plainBackground;
@property (strong, nonatomic) NSString *discoverBackground;
@property (strong, nonatomic) NSString *sermonsBackground;
@property (strong, nonatomic) NSString *connectBackground;
@property (strong, nonatomic) NSString *fontName;
@property (strong, nonatomic) NSString *facebook;
@property (strong, nonatomic) NSString *twitter;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *website;

@property (strong, nonatomic) UIColor *segmentedControlSelectedColor;
@property (strong, nonatomic) UIColor *segmentedControlUnselectedColor;
@property (strong, nonatomic) UIColor *sliderControlColor;
@property (strong, nonatomic) UIColor *majorColor;
@property (strong, nonatomic) UIColor *minorColor;
@property (strong, nonatomic) UIColor *headerColor;

@end
