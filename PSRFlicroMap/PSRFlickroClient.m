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
    NSCache *_cacheImages;
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
    // request example: https://api.flickr.com/services/rest/?api_key=f577bf636cdb7f7af139c65271433102&format=json&nojsoncallback=1&method=flickr.photos.search&tags=xxx
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *str = [NSString stringWithFormat:@"%@&method=flickr.photos.search&has_geo=1&tags=%@", kPSRFlicroClientStrUrlBase, tags];
    NSString *strEncoding = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; // http://stackoverflow.com/questions/8163599/escaping-special-characters-%C3%B8-%C3%A6-for-use-inside-a-url
    NSURL *url = [[NSURL alloc] initWithString:strEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
        if (error) {
            [self.delegate picsNotFound];
            return;
        }
        
        // NOTE: тут мы получаем только id'шники картинок и их тайтлы
        
        NSData *dataJSON = [[NSData alloc] initWithContentsOfURL:location];
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:dataJSON options:kNilOptions error:nil];
        
        NSInteger total = [responseDictionary[@"photos"][@"total"] integerValue];
        
        if (!total) {
            [self.delegate picsNotFound];
            return;
        }
            
        _flickroPics = [NSMutableDictionary dictionaryWithCapacity:total];
        
        NSArray *photosData = responseDictionary[@"photos"][@"photo"];
        for (NSDictionary *photoInfo in photosData) {
            
            NSString *picId = photoInfo[@"id"];
            NSString *picTitle = photoInfo[@"title"];
            
            PSRFlickroPic *flicroPic = [[PSRFlickroPic alloc] initWithFlicroPicId:picId andTitle:picTitle];
            _flickroPics[picId] = flicroPic;
        }
        
        [self p_loadGeoForFlicroPics]; // подргужаем геоинфу к созданным объектам
    }];
    
    [task resume];
}

- (NSUInteger)howManyPicsWeAreWaiting
{
    return [_flickroPics count];
}

- (PSRFlickroPic *)flickroPicForPicId:(NSString *)picId
{
    return _flickroPics[picId];
}

- (NSData *)cachedImageForUrl:(NSURL *)imageUrl
{
    if (!_cacheImages) {
        _cacheImages = [NSCache new];
    }
    
    NSData *imageData = [_cacheImages objectForKey:imageUrl];
    if (!imageData) {
        imageData = [[NSData alloc] initWithContentsOfURL:imageUrl];
        [_cacheImages setObject:imageData forKey:imageUrl];
    }
    
    return imageData;
}

#pragma mark - Private Methods

- (void)p_loadGeoForFlicroPics
{
    // добавляем широту и долготу к фликрокартинкам
    
    [_flickroPics enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(NSString *picFlickrId, PSRFlickroPic *obj, BOOL *stop) {
    
        // request example: https://api.flickr.com/services/rest/?api_key=f577bf636cdb7f7af139c65271433102&format=json&nojsoncallback=1&method=flickr.photos.geo.getLocation&photo_id=15205077469
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSString *str = [NSString stringWithFormat:@"%@&method=flickr.photos.geo.getLocation&photo_id=%@", kPSRFlicroClientStrUrlBase, picFlickrId];
        NSString *strEncoding = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [[NSURL alloc] initWithString:strEncoding];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            
            NSData *dataJSON = [[NSData alloc] initWithContentsOfURL:location];
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:dataJSON options:kNilOptions error:nil];
            
            NSString *picId = responseDictionary[@"photo"][@"id"];
            double latitude = [responseDictionary[@"photo"][@"location"][@"latitude"] doubleValue];
            double longitude = [responseDictionary[@"photo"][@"location"][@"longitude"] doubleValue];
            
            [_flickroPics[picId] setLatitude:latitude andLognitude:longitude]; // ???: а здесь мы обратиться по obj уже не можем, так?
            
            [self p_loadImageURLsForFlickroPicWithFlickrId:picId]; // теперь подгружаем url'ы картинок
        }];
        
        [task resume];
    }];
}

- (void)p_loadImageURLsForFlickroPicWithFlickrId:(NSString *)picFlickrId
{
    // request example: https://api.flickr.com/services/rest/?api_key=f577bf636cdb7f7af139c65271433102&format=json&nojsoncallback=1&method=flickr.photos.getSizes&photo_id=15448211786
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *str = [NSString stringWithFormat:@"%@&method=flickr.photos.getSizes&photo_id=%@", kPSRFlicroClientStrUrlBase, picFlickrId];
    NSString *strEncoding = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [[NSURL alloc] initWithString:strEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
        NSData *dataJSON = [[NSData alloc] initWithContentsOfURL:location];
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:dataJSON options:kNilOptions error:nil];
        
        NSString *stringWithPicId = responseDictionary[@"sizes"][@"size"][0][@"url"];
        NSString *picId = [self p_extractFlickrPicIdFromImageUrlStr:stringWithPicId];

        for (NSDictionary *picture in responseDictionary[@"sizes"][@"size"]) {
            if ([picture[@"label"] isEqualToString:@"Square"]) {
                [_flickroPics[picId] setStrURLImageSquare:picture[@"source"]];
            } else if ([picture[@"label"] isEqualToString:@"Large"]) {
                [_flickroPics[picId] setStrURLImageLarge:picture[@"source"]];
            }
        }
        
        [self.delegate didReceiveNewPic:picId]; // сообщим делегату, что точку можно размещать на карте
    }];
    
    [task resume];
}

- (NSString *)p_extractFlickrPicIdFromImageUrlStr:(NSString *)stringWithPicId
{
    // example: stringWithPicId = https://www.flickr.com/photos/szirtesi/14695172858/sizes/sq/
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"/[0-9]+/sizes/" options:0 error:nil];
    
    NSRange range = [regex rangeOfFirstMatchInString:stringWithPicId options:0 range:NSMakeRange(0, [stringWithPicId length])];
    NSString *result = [stringWithPicId substringWithRange:range];
    NSString *picId = [result substringWithRange:NSMakeRange(1, [result length] - 8)];
    
    return picId;
}

@end
