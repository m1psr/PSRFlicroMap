//
//  PSRFlickroPicDetailViewController.m
//  PSRFlicroMap
//
//  Created by M on 11.10.14.
//  Copyright (c) 2014 M. All rights reserved.
//

#import "PSRFlickroPicDetailViewController.h"
#import "PSRFlickroClient.h"

@implementation PSRFlickroPicDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.activityIndicator startAnimating];
    self.navigationItem.title = self.flickroPic.title;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURL *imageUrl = [NSURL URLWithString:self.flickroPic.strURLImageLarge];
        NSData *imageData = [[PSRFlickroClient sharedInstance] cachedImageForUrl:imageUrl];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.detailImage.image = [[UIImage alloc] initWithData:imageData];
            [self.activityIndicator stopAnimating];
        });
    });
}

@end
