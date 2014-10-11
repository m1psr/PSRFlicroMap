//
//  PSRFlickroPic.m
//  PSRFlicroMap
//
//  Created by M on 09.10.14.
//  Copyright (c) 2014 M. All rights reserved.
//

#import "PSRFlickroPic.h"

@implementation PSRFlickroPic

- (instancetype)initWithFlicroPicId:(NSString *)flickrPicId andTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        _flickrId = [flickrPicId copy];
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

-  (void)setStrURLImageSquare:(NSString *)strURLImageSquare andStrURLImageLarge:(NSString *)strURLImageLarge
{
    self.strURLImageSquare = strURLImageSquare;
    self.strURLImageLarge = strURLImageLarge;
}

#pragma mark - @Override

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ : %p; id: %@ geo(%f, %f); squareURL: %@, largeURL: %@>", [self class], self, _flickrId, _latitude, _longitude, _strURLImageSquare, _strURLImageLarge];
}

@end
