//
//  PSRMapViewController.m
//  PSRFlicroMap
//
//  Created by M on 09.10.14.
//  Copyright (c) 2014 M. All rights reserved.
//

#import "PSRMapViewController.h"
#import "PSRFlickroPic.h"
#import "PSRFlickroClient.h"
#import "PSRMapPoint.h"

@interface PSRMapViewController ()

@property (nonatomic, strong) PSRFlickroClient *flickroClient;
@property (nonatomic, strong) NSMutableArray *flickroPicIds; // загружается методом делегата

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

- (void)lookupInFlickr:(NSString *)tags {
    
    if (!self.flickroClient) {
        self.flickroClient = [PSRFlickroClient sharedInstance];
        self.flickroClient.delegate = self;
    }
    
    [self.flickroClient loadFlickroPicsWithTags:tags];
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.flickrLookupTextField resignFirstResponder];
    self.flickrLookupTextField.hidden = YES;
    [self.activityIndicator startAnimating];
    
    [self lookupInFlickr:self.flickrLookupTextField.text];
    
    return YES;
}

#pragma mark - MKMapViewDelegate Methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    // http://stackoverflow.com/questions/19357941/show-user-location-in-mapview
    [self.worldView setCenterCoordinate:self.worldView.userLocation.coordinate animated:YES];
}

#pragma mark - PSRFlickroClientDelegate Methods

- (void)flickroClient:(PSRFlickroClient *)client didReceivePics:(NSArray *)flickroPicIds
{
    self.flickroPicIds = [flickroPicIds mutableCopy];
//    NSLog(@"%lu", (unsigned long)[self.flickroPicIds count]);
//    NSLog(@"%@", self.flickroPicIds);
    
    for (NSNumber *flickroPicId in self.flickroPicIds) {
        NSDictionary *geo = [self.flickroClient geoForFlickroPic:flickroPicId];
//        NSLog(@"%@", geo);
        PSRMapPoint *mapPoint = [[PSRMapPoint alloc] initWithLatitude:[geo[@"latitude"] doubleValue] longitude:[geo[@"longitude"] doubleValue]  andTitle:[self.flickroClient titleForFlickroPic:flickroPicId]];
        [self.worldView addAnnotation:mapPoint];
    }
    
    [[self activityIndicator] stopAnimating];
    self.flickrLookupTextField.hidden = NO;
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
