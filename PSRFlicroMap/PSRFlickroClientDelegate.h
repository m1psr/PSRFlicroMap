//
//  PSRFlickroClientDelegate.h
//  PSRFlicroMap
//
//  Created by M on 10.10.14.
//  Copyright (c) 2014 M. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PSRFlickroClient;

@protocol PSRFlickroClientDelegate <NSObject>

- (void)flickroClient:(PSRFlickroClient *)client didReceivePics:(NSArray *)flickroPicIds;
//- (void)flickroClient:(PSRFlickroClient *)client didReceivePicLa

@end
