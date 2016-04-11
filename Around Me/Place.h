//
//  Place.h
//  Around Me
//
//  Created by jdistler on 11.02.13.
//  Copyright (c) 2013 Jean-Pierre Distler. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLLocation;

@interface Place : NSObject

@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, copy) NSString *reference;
@property (nonatomic, copy) NSString *placeName;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *website;
@property (nonatomic, assign) double distance;

- (id)initWithLocation:(CLLocation *)location reference:(NSString *)reference name:(NSString *)name address:(NSString *)address distance:(double)distance;
- (NSString *)infoText;

@end
