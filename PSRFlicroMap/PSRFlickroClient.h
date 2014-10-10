//
//  PSRFlickroClient.h
//  PSRFlicroMap
//
//  Created by M on 10.10.14.
//  Copyright (c) 2014 M. All rights reserved.
//

@import Foundation;

#import "PSRFlickroClientDelegate.h"

@interface PSRFlickroClient : NSObject

@property (nonatomic, weak) id<PSRFlickroClientDelegate> delegate;

+ (PSRFlickroClient *)sharedInstance;

- (void)loadFlickroPicsWithTags:(NSString *)tags;

- (NSDictionary *)geoForFlickroPic:(NSNumber *)flickroPicId;
- (NSString *)titleForFlickroPic:(NSNumber *)flickroPicId;

@end
