//
//  PSRFlickroPicDetailViewController.h
//  PSRFlicroMap
//
//  Created by M on 11.10.14.
//  Copyright (c) 2014 M. All rights reserved.
//

@import UIKit;

#import "PSRFlickroPic.h"

@interface PSRFlickroPicDetailViewController : UIViewController

@property (nonatomic, strong) PSRFlickroPic* flickroPic;

@property (weak, nonatomic) IBOutlet UIImageView *detailImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
