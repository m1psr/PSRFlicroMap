//
//  PSRFlickroClientDelegate.h
//  PSRFlicroMap
//
//  Created by M on 10.10.14.
//  Copyright (c) 2014 M. All rights reserved.
//

@import Foundation;

@class PSRFlickroClient;

@protocol PSRFlickroClientDelegate <NSObject>

- (void)didReceiveNewPic:(NSString *)newPicId;
- (void)picsNotFound;

@end
