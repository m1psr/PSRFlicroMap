//
//  PSRMapPoint.m
//  PSRFlicroMap
//
//  Created by M on 10.10.14.
//  Copyright (c) 2014 M. All rights reserved.
//

#import "PSRMapPoint.h"
#import "PSRFlickroPic.h"

@implementation PSRMapPoint

@dynamic coordinate, title;

- (instancetype)initWithFlickroPic:(PSRFlickroPic *)flickroPic
{
    self = [super init];
    if (self) {
        _flickroPic = flickroPic;
    }
    return self;
}

- (instancetype)init
{
    NSAssert(NO, @"Use initWithFlicroPic:");
    return nil;
}

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake(self.flickroPic.latitude, self.flickroPic.longitude);
}

- (NSString *)title
{
    return self.flickroPic.title;
}

@end
