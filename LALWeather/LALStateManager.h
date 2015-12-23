//
//  LALStateManager.h
//  LALWeather
//
//  Created by LAL on 15/12/22.
//  Copyright © 2015年 LAL. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    LALFahrenheitScale = 0,
    LALCelsiusScale
} LALTemperatureScale;

/**
 LALStateManager allows for easy state persistence and acts as a thin wrapper around NSUserDefaults
*/
@interface LALStateManager : NSObject


+ (LALTemperatureScale)temperatureScale;
+ (void) setTemperatureScale:(LALTemperatureScale)scale;

+ (NSDictionary *)weatherData;
+(void)setWeatherData: (NSDictionary *)weatherData;

+(NSArray *)weatherTags;
+(void)setWeatherTags:(NSArray *)weatherTags;

@end
