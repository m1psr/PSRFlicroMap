//
//  PSRFlickroPic.m
//  PSRFlicroMap
//
//  Created by M on 09.10.14.
//  Copyright (c) 2014 M. All rights reserved.
//

#import "PSRFlickroPic.h"

@interface PSRFlickroPic ()

@property (nonatomic, readwrite) NSUInteger flickrId;
@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, readwrite) double latitude;
@property (nonatomic, readwrite) double longitude;

@end

@implementation PSRFlickroPic

- (instancetype)initWithFlicroPicId:(NSUInteger)flickrPicId andTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        _flickrId = flickrPicId;
        _title = [title copy];
    }
    return self;
}

- (instancetype)init
{
    NSAssert(NO, @"Use initFlicroPicWithId:andTitle:");
    return nil;
}

- (void)setLatitude:(double)latitude andLognitude:(double)longitude
{
    self.latitude = latitude;
    self.longitude = longitude;
}

@end
