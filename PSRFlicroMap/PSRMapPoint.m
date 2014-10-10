//
//  PSRMapPoint.m
//  PSRFlicroMap
//
//  Created by M on 10.10.14.
//  Copyright (c) 2014 M. All rights reserved.
//

#import "PSRMapPoint.h"

@implementation PSRMapPoint

- (instancetype)initWithLatitude:(double)latitude longitude:(double)longitude andTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        _coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        _title = [title copy];
    }
    return self;
}

@end
