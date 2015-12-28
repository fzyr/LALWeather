//
//  LALWundergroundDownloader.m
//  LALWeather
//
//  Created by LAL on 15/12/18.
//  Copyright © 2015年 LAL. All rights reserved.
//

#import "LALWundergroundDownloader.h"

@interface LALWundergroundDownloader()
// API key
@property (nonatomic, strong) NSString *key;
// to determine the name of locations based on coordinates
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) NSURLSession *urlSession;
@end


@implementation LALWundergroundDownloader

+(LALWundergroundDownloader *)sharedDownloader{
    static LALWundergroundDownloader *sharedDownloader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDownloader = [[LALWundergroundDownloader alloc] init];
        sharedDownloader.key = @"1d97e6b7a96425a4";
        http://api.wunderground.com/api/1d97e6b7a96425a4/forecast/conditions/q/30.25,120.17.json
        sharedDownloader.geocoder = [[CLGeocoder alloc] init];
    });
    return sharedDownloader;
}

-(NSURLSession *)urlSession{
    if(!_urlSession){
        _urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return _urlSession;
}

-(void)dataForLocation:(CLLocation *)location withPlacemark:(CLPlacemark *)placemark withTag:(NSUInteger)tag completion:(LALWeatherDataDownloadCompletion)completion{
    
//    requests are not made if the location and completion is nil
    if(!location || !completion){
        return;
    }
    //turn on the nework activity indicator in the status bar
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURLRequest *urlRequest = [self urlRequestForLocation:location];
    //make an asynchronous request to the url
    __weak LALWundergroundDownloader *weakSelf = self;
    NSURLSessionDataTask *dataTask = [self.urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        LALWundergroundDownloader *strongSelf = weakSelf;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if(error){
            completion(nil,error);
        }else{
            NSDictionary *JSON = [strongSelf serializedData:data];
            LALWeatherData *weatherData = [strongSelf dataFromJSON:JSON];
            if(placemark){
                weatherData.placemark = placemark;
                completion(weatherData,error);
            }else{
                [strongSelf.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {

                    if([placemarks count] > 0){
                        weatherData.placemark = [placemarks lastObject];

                                    completion(weatherData,error);
                    }
                }];
                //如果completion(weatherData,error)放这里，则geocoder里面还没有执行完weatherData就被返回了（null）
            }
        }
    }];
    [dataTask resume];
}

-(void)dataForLocation:(CLLocation *)location withTag:(NSUInteger)tag completion:(LALWeatherDataDownloadCompletion)completion{
    [self dataForLocation:location withPlacemark:nil withTag:tag completion:completion];
}

-(void)dataForPlacemark:(CLPlacemark *)placemark withTag:(NSUInteger)tag completion:(LALWeatherDataDownloadCompletion)completion{
    [self dataForLocation:placemark.location withPlacemark:placemark withTag:tag completion:completion];
}

-(NSDictionary *)serializedData:(NSData *)data{
    
    NSError *JSONSerializationError;
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&JSONSerializationError];
    if(JSONSerializationError){
        [NSException raise:@"JSON Serialization Error" format:@"Failed to pasrse weather data"];
    }
    return JSON;
}

-(LALWeatherData *)dataFromJSON:(NSDictionary *)JSON{
    NSDictionary *currentObservation = [JSON objectForKey:@"current_observation"];
    NSDictionary *forecast = [JSON objectForKey:@"forecast"];
    NSDictionary *simgpleForecast = [forecast objectForKey:@"simpleforecast"];
    NSArray *forecastDays = [simgpleForecast objectForKey:@"forecastday"];
    NSDictionary *forecastDay0 = [forecastDays objectAtIndex:0];
    NSDictionary *forecastDay1 = [forecastDays objectAtIndex:1];
    NSDictionary *forecastDay2 = [forecastDays objectAtIndex:2];
    NSDictionary *forecastDay3 = [forecastDays objectAtIndex:3];
    
    LALWeatherData *weatherData = [[LALWeatherData alloc] init];
    
    weatherData.timeStamp = [NSDate date];
    
    LALWeatherDataSnapshot *weatherSnapshotDay0 = [[LALWeatherDataSnapshot alloc] init];
    weatherSnapshotDay0.hightTemperature = [NSNumber numberWithDouble: [forecastDay0[@"high"][@"celsius"] integerValue]];
    weatherSnapshotDay0.lowTemperature = [NSNumber numberWithDouble: [forecastDay0[@"low"][@"celsius"] integerValue]];
    weatherSnapshotDay0.currentTemperature = [NSNumber numberWithDouble: [currentObservation[@"temp_c"] integerValue]];
    weatherSnapshotDay0.weatherDescription = currentObservation[@"weather"];
    weatherSnapshotDay0.weekday = forecastDay0[@"date"][@"weekday"];
    weatherData.currentSnapshot = weatherSnapshotDay0;


    
    LALWeatherDataSnapshot *weatherSnapshotDay1 = [[LALWeatherDataSnapshot alloc] init];
    weatherSnapshotDay1.hightTemperature = [NSNumber numberWithDouble: [forecastDay1[@"high"][@"celsius"] doubleValue]];
    weatherSnapshotDay1.lowTemperature = [NSNumber numberWithDouble: [forecastDay1[@"low"][@"celsius"] doubleValue]];
    weatherSnapshotDay1.weatherDescription = forecastDay1[@"conditions"];
    weatherSnapshotDay1.weekday = forecastDay1[@"date"][@"weekday"];
    [weatherData.forecastSnapshots addObject:weatherSnapshotDay1];
    
    LALWeatherDataSnapshot *weatherSnapshotDay2 = [[LALWeatherDataSnapshot alloc] init];
    weatherSnapshotDay2.hightTemperature = [NSNumber numberWithDouble: [forecastDay2[@"high"][@"celsius"] doubleValue]];
    weatherSnapshotDay2.lowTemperature = [NSNumber numberWithDouble: [forecastDay2[@"low"][@"celsius"] doubleValue]];
    weatherSnapshotDay2.weatherDescription = forecastDay2[@"conditions"];
    weatherSnapshotDay2.weekday = forecastDay2[@"date"][@"weekday"];
    [weatherData.forecastSnapshots addObject:weatherSnapshotDay2];
    
    LALWeatherDataSnapshot *weatherSnapshotDay3 = [[LALWeatherDataSnapshot alloc] init];
    weatherSnapshotDay3.hightTemperature = [NSNumber numberWithDouble: [forecastDay3[@"high"][@"celsius"] doubleValue]];
    weatherSnapshotDay3.lowTemperature = [NSNumber numberWithDouble: [forecastDay3[@"low"][@"celsius"] doubleValue]];
    weatherSnapshotDay3.weatherDescription = forecastDay3[@"conditions"];
    weatherSnapshotDay3.weekday = forecastDay3[@"date"][@"weekday"];
    [weatherData.forecastSnapshots addObject:weatherSnapshotDay3];
    
    return weatherData;
}

-(NSURLRequest *)urlRequestForLocation:(CLLocation *)location{
    NSString *baseURL = [NSString stringWithFormat:@"http://api.wunderground.com/api/%@",self.key];
    NSString *parameters = @"/forecast/conditions/q/";
    NSString *finalURL = [NSString stringWithFormat:@"%@%@%f,%f.json",baseURL,parameters,location.coordinate.latitude,location.coordinate.longitude];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString: finalURL]];

    return urlRequest;
}

@end
