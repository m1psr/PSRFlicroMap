//
//  PSRMapViewController.h
//  PSRFlicroMap
//
//  Created by M on 09.10.14.
//  Copyright (c) 2014 M. All rights reserved.
//

@import UIKit;
@import MapKit;

#import "PSRFlickroClientDelegate.h"

@interface PSRMapViewController : UIViewController <MKMapViewDelegate, UITextFieldDelegate, PSRFlickroClientDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *worldView;
@property (weak, nonatomic) IBOutlet UITextField *flickrLookupTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
