//
//  PSRMapViewController.m
//  PSRFlicroMap
//
//  Created by M on 09.10.14.
//  Copyright (c) 2014 M. All rights reserved.
//

#import "PSRMapViewController.h"

@interface PSRMapViewController ()

@end

@implementation PSRMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.worldView.showsUserLocation = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (void)lookupInFlickr {
    self.flickrLookupTextField.hidden = YES;
    [self.activityIndicator startAnimating];
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.flickrLookupTextField resignFirstResponder];
    [self lookupInFlickr];
    return YES;
}

#pragma mark - MKMapViewDelegate Methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    // http://stackoverflow.com/questions/19357941/show-user-location-in-mapview
    [self.worldView setCenterCoordinate:self.worldView.userLocation.coordinate animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



@end
