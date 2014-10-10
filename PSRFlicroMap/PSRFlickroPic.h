//
//  PSRFlickroPic.h
//  PSRFlicroMap
//
//  Created by M on 09.10.14.
//  Copyright (c) 2014 M. All rights reserved.
//

@import Foundation;

@interface PSRFlickroPic : NSObject

@property (nonatomic, readonly) NSUInteger flickrId;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, readonly) double latitude;
@property (nonatomic, readonly) double longitude;

- (instancetype)initWithFlicroPicId:(NSUInteger)flickrPicId andTitle:(NSString *)title;

- (void)setLatitude:(double)latitude andLognitude:(double)longitude;

@end
