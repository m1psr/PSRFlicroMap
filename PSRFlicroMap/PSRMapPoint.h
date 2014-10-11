//
//  PSRMapPoint.h
//  PSRFlicroMap
//
//  Created by M on 10.10.14.
//  Copyright (c) 2014 M. All rights reserved.
//

@import Foundation;
@import MapKit;

@interface PSRMapPoint : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title; // Title for use by selection UI

- (instancetype)initWithLatitude:(double)latitude longitude:(double)longitude andTitle:(NSString *)title;

@end
