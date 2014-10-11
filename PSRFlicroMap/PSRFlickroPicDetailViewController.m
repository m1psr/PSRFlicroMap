//
//  PSRFlickroPicDetailViewController.m
//  PSRFlicroMap
//
//  Created by M on 11.10.14.
//  Copyright (c) 2014 M. All rights reserved.
//

#import "PSRFlickroPicDetailViewController.h"

@implementation PSRFlickroPicDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.activityIndicator startAnimating];
    self.navigationItem.title = self.flickroPic.title;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:self.flickroPic.strURLImageLarge]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.detailImage.image = [[UIImage alloc] initWithData:imageData];
            [self.activityIndicator stopAnimating];
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
