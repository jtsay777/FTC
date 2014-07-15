//
//  Church.h
//  AAChurch
//
//  Created by Ben Gomez on 8/4/12.
//  Copyright (c) 2012 Jway Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Church : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *pastor;
@property (strong, nonatomic) NSString *district;
@property (strong, nonatomic) NSString *street;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *postalCode;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;
@property (strong, nonatomic) NSString *website;
@property (strong, nonatomic) NSString *email;

@end
