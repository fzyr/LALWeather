//
//  LALWeatherData.h
//  LALWeather
//
//  Created by LAL on 15/12/18.
//  Copyright © 2015年 LAL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LALWeatherDataSnapshot : NSObject <NSCoding>
@property (nonatomic, strong) NSNumber * hightTemperature;
@property (nonatomic, strong) NSNumber *lowTemperature;
@property (nonatomic, strong) NSNumber *currentTemperature;
@property (nonatomic, copy) NSString *weatherDescription;
@property (nonatomic, copy) NSString *weekday;
@property (nonatomic, copy) NSString *iconText;
@end



@interface LALWeatherData : NSObject <NSCoding>
@property (nonatomic, strong) CLPlacemark *placemark;
@property (nonatomic, strong) NSDate *timeStamp;
@property (nonatomic, strong) LALWeatherDataSnapshot *currentSnapshot;
@property (nonatomic, strong) NSMutableArray *forecastSnapshots;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end
