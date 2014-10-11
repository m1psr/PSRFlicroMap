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
@property (nonatomic, strong) NSMutableArray *flickroPicIds; // добавленные на mapView точки

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

- (void)lookupInFlickr:(NSString *)tags
{
    
    if (!self.flickroClient) {
        self.flickroClient = [PSRFlickroClient sharedInstance];
        self.flickroClient.delegate = self;
    }
    self.flickroPicIds = [NSMutableArray array];
    [self.flickroClient loadFlickroPicsWithTags:tags];
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // http://stackoverflow.com/questions/5756256/trim-spaces-from-end-of-a-nsstring
    NSString *trimmedString = [self.flickrLookupTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.flickrLookupTextField.text = trimmedString;
    
    if (![self.flickrLookupTextField.text length]) {
        return YES;
    }
    
    [self.worldView removeAnnotations:self.worldView.annotations];
    
    [self.flickrLookupTextField resignFirstResponder];
    self.flickrLookupTextField.hidden = YES;
    [self.activityIndicator startAnimating];
    
    if ([self.flickrLookupTextField.text length]) {
        [self lookupInFlickr:self.flickrLookupTextField.text];
    } else {
        ; // TODO: show alert
    }
    return YES;
}

#pragma mark - MKMapViewDelegate Methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    // http://stackoverflow.com/questions/19357941/show-user-location-in-mapview
    [self.worldView setCenterCoordinate:self.worldView.userLocation.coordinate animated:YES];
}

#pragma mark - PSRFlickroClientDelegate Methods

- (void)didReceiveNewPic:(NSString *)newPicId
{
    
    NSDictionary *geo = [self.flickroClient geoForFlickroPic:newPicId];
    PSRMapPoint *mapPoint = [[PSRMapPoint alloc] initWithLatitude:[geo[@"latitude"] doubleValue] longitude:[geo[@"longitude"] doubleValue]  andTitle:[self.flickroClient titleForFlickroPic:newPicId]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.worldView addAnnotation:mapPoint];
    });
    [_flickroPicIds addObject:newPicId];
    
    if ([_flickroPicIds count] == [self.flickroClient howManyPicsWeAreWaiting]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self activityIndicator] stopAnimating];
            self.flickrLookupTextField.hidden = NO;
        });
    }
}

- (void)picsNotFound
{
    // TODO: show alert
    NSLog(@"*** %s", __PRETTY_FUNCTION__);
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
