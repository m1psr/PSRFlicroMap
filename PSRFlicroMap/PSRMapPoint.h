//
//  PSRMapPoint.h
//  PSRFlicroMap
//
//  Created by M on 10.10.14.
//  Copyright (c) 2014 M. All rights reserved.
//

@import MapKit;

@class PSRFlickroPic;

@interface PSRMapPoint : NSObject <MKAnnotation>

@property (nonatomic, strong, readonly) PSRFlickroPic *flickroPic;

- (instancetype)initWithFlickroPic:(PSRFlickroPic *)flickroPic;

// MKAnnotation

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title; // Title for use by selection UI

@end
