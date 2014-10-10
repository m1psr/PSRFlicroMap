//
//  PSRFlickroClient.m
//  PSRFlicroMap
//
//  Created by M on 10.10.14.
//  Copyright (c) 2014 M. All rights reserved.
//

#import "PSRFlickroClient.h"
#import "PSRFlickroPic.h"

NSString * const kPSRFlicroClientStrUrlBase = @"https://api.flickr.com/services/rest/?api_key=f577bf636cdb7f7af139c65271433102&format=json&nojsoncallback=1";

@implementation PSRFlickroClient
{
    NSMutableDictionary *_flickroPics;
    int _loading;
}

+ (PSRFlickroClient *)sharedInstance
{
    static dispatch_once_t pred;
    static PSRFlickroClient *sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void)loadFlickroPicsWithTags:(NSString *)tags
{
    _flickroPics = [NSMutableDictionary dictionaryWithCapacity:250];
    _loading = 0;
    
    // https://api.flickr.com/services/rest/?api_key=f577bf636cdb7f7af139c65271433102&format=json&nojsoncallback=1&method=flickr.photos.search&tags=xxx
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *str = [NSString stringWithFormat:@"%@&method=flickr.photos.search&has_geo=1&tags=%@", kPSRFlicroClientStrUrlBase, tags];
    NSString *strEncoding = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; // http://stackoverflow.com/questions/8163599/escaping-special-characters-%C3%B8-%C3%A6-for-use-inside-a-url
    NSURL *url = [[NSURL alloc] initWithString:strEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
        // NOTE: тут мы получаем только id'шники картинок и их тайтлы
        
        NSData *dataJSON = [[NSData alloc] initWithContentsOfURL:location];
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:dataJSON options:kNilOptions error:nil];
        
        NSInteger total = [responseDictionary[@"photos"][@"total"] integerValue];
//        NSLog(@"%lu", (unsigned long)total);
        
        if (total) {
            NSArray *photosData = responseDictionary[@"photos"][@"photo"];
            for (NSDictionary *photoInfo in photosData) {
                
                NSNumber *photoId = photoInfo[@"id"];
                NSString *photoTitle = photoInfo[@"title"];
                
                PSRFlickroPic *flicroPic = [[PSRFlickroPic alloc] initWithFlicroPicId:[photoId integerValue] andTitle:photoTitle];
                _flickroPics[photoId] = flicroPic;
            }
        }
        
        [self p_loadGeoInFlicroPics];
    }];
    
    [task resume];
}

- (NSDictionary *)geoForFlickroPic:(NSNumber *)flickroPicId
{
    PSRFlickroPic *flickroPic = (PSRFlickroPic *)_flickroPics[flickroPicId];
    NSDictionary *r = @{@"latitude" : [NSNumber numberWithDouble:flickroPic.latitude],
                        @"longitude" : [NSNumber numberWithDouble:flickroPic.longitude]};
    return r;
}

- (NSString *)titleForFlickroPic:(NSNumber *)flickroPicId
{
    PSRFlickroPic *flickroPic = (PSRFlickroPic *)_flickroPics[flickroPicId];
    return flickroPic.title;
}

#pragma mark - Private Methods

- (void)p_loadGeoInFlicroPics
{
    // добавляем широту и долготу к фликрокартинкам
    
    [_flickroPics enumerateKeysAndObjectsUsingBlock:^(NSNumber *picFlickrId, PSRFlickroPic *obj, BOOL *stop) {
        
        // https://api.flickr.com/services/rest/?api_key=f577bf636cdb7f7af139c65271433102&format=json&nojsoncallback=1&method=flickr.photos.geo.getLocation&photo_id=15205077469
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSString *str = [NSString stringWithFormat:@"%@&method=flickr.photos.geo.getLocation&photo_id=%@", kPSRFlicroClientStrUrlBase, picFlickrId];
        NSString *strEncoding = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [[NSURL alloc] initWithString:strEncoding];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            
            NSData *dataJSON = [[NSData alloc] initWithContentsOfURL:location];
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:dataJSON options:kNilOptions error:nil];
            
            NSNumber *picId = responseDictionary[@"photo"][@"id"];
            double latitude = [responseDictionary[@"photo"][@"location"][@"latitude"] doubleValue];
            double longitude = [responseDictionary[@"photo"][@"location"][@"longitude"] doubleValue];
            
            [_flickroPics[picId] setLatitude:latitude andLognitude:longitude]; // ???: а здесь мы обратиться по obj уже не можем, так?
            
            if (++_loading >= 250) {
//                NSLog(@"%d", _loading);
                [self.delegate flickroClient:self didReceivePics:[_flickroPics allKeys]];
            }
        }];
        
        [task resume];
    }];
}

// get Picture
//
//            // https://api.flickr.com/services/rest/?api_key=f577bf636cdb7f7af139c65271433102&format=json&nojsoncallback=1&method=flickr.photos.getSizes&photo_id=15448211786
//
//            NSString *str = [NSString stringWithFormat:@"%@&method=flickr.photos.getSizes&photo_id=%@", strUrlBase, photoId];
//            NSLog(@"%@", photoId);
//
//            NSString *strEncoding = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            NSURL *url = [[NSURL alloc] initWithString:strEncoding];
//            NSURLRequest *request = [NSURLRequest requestWithURL:url];
//            NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
//                NSData *dataJSON = [[NSData alloc] initWithContentsOfURL:location];
//                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:dataJSON options:kNilOptions error:nil];
//                NSLog(@"%@", responseDictionary);
//                for (NSDictionary *picture in responseDictionary[@"sizes"][@"size"]) {
//                    if ([picture[@"label"] isEqualToString:@"Square"]) {
//                        NSLog(@"%@", picture[@"source"]);
//                    }
//                    if ([picture[@"label"] isEqualToString:@"Large"]) {
//                        NSLog(@"%@", picture[@"source"]);
//                    }
//                }
//                //                                                                NSLog(@"%@", responseDictionary[@"photo"][@"location"][@"longitude"]);
//
//
//
//
//            }];
//            [task resume];

@end
