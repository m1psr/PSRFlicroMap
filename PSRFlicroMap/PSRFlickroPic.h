//
//  PSRFlickroPic.h
//  PSRFlicroMap
//
//  Created by M on 09.10.14.
//  Copyright (c) 2014 M. All rights reserved.
//

@import Foundation;

@interface PSRFlickroPic : NSObject

@property (nonatomic, copy) NSString *flickrId;
@property (nonatomic, copy) NSString *title;

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@property (nonatomic, copy) NSString *strURLImageSquare;
@property (nonatomic, copy) NSString *strURLImageLarge;

- (instancetype)initWithFlicroPicId:(NSString *)flickrPicId andTitle:(NSString *)title;

- (void)setLatitude:(double)latitude andLognitude:(double)longitude;

@end
