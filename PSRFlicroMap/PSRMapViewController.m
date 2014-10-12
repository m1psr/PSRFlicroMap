//
//  PSRMapViewController.m
//  PSRFlicroMap
//
//  Created by M on 09.10.14.
//  Copyright (c) 2014 M. All rights reserved.
//

#import "PSRMapViewController.h"
#import "PSRFlickroPicDetailViewController.h"
#import "PSRFlickroClient.h"
#import "PSRFlickroPic.h"
#import "PSRMapPoint.h"

@interface PSRMapViewController ()

@property (nonatomic, strong) PSRFlickroClient *flickroClient;
@property (nonatomic, strong) NSMutableArray *flickroPicIds; // добавленные на mapView точки
@property (nonatomic) BOOL updatedUserLocation;

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
    self.updatedUserLocation = NO;
    
    [self.flickrLookupTextField resignFirstResponder];
    self.flickrLookupTextField.hidden = YES;
    [self.activityIndicator startAnimating];
    
    [self lookupInFlickr:self.flickrLookupTextField.text];

    return YES;
}

#pragma mark - MKMapViewDelegate Methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (self.updatedUserLocation) {
        return;
    }
    
    // http://stackoverflow.com/questions/19357941/show-user-location-in-mapview
    [self.worldView setCenterCoordinate:self.worldView.userLocation.coordinate animated:YES];
    self.updatedUserLocation = YES;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (![annotation isKindOfClass:[PSRMapPoint class]]) {
        return nil;
    }
    
    NSString *reusableIdentifier = @"PSRAnnotationIdentifier";
    MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:reusableIdentifier];
    if (!aView) {
        aView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reusableIdentifier];
        aView.canShowCallout = YES;
    } else {
        aView.annotation = annotation;
        aView.image = nil;
    }
    
    PSRMapPoint *mapPoint = (PSRMapPoint *)annotation;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURL *imageSquareURL = [NSURL URLWithString:mapPoint.flickroPic.strURLImageSquare];
        NSData *imageData = [self.flickroClient cachedImageForUrl:imageSquareURL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            aView.image = [[UIImage alloc] initWithData:imageData];
        });
    });
    
    return aView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView
{
    [self performSegueWithIdentifier: @"flickroPicDetailSegue" sender: aView];
}

#pragma mark - PSRFlickroClientDelegate Methods

- (void)didReceiveNewPic:(NSString *)newPicId
{
    PSRMapPoint *mapPoint = [[PSRMapPoint alloc] initWithFlickroPic:[self.flickroClient flickroPicForPicId:newPicId]];
    
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ничего не найдено" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    [[self activityIndicator] stopAnimating];
    self.flickrLookupTextField.hidden = NO;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.destinationViewController isKindOfClass:[PSRFlickroPicDetailViewController class]]) {
        MKAnnotationView *aView = (MKAnnotationView *)sender;
        PSRFlickroPic *flickroPic = [(PSRMapPoint *)aView.annotation flickroPic];
        PSRFlickroPicDetailViewController *flickroPicDetailVC = (PSRFlickroPicDetailViewController *)segue.destinationViewController;
        flickroPicDetailVC.flickroPic = flickroPic;
    }
}

@end
