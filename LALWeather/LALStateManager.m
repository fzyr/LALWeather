//
//  LALStateManager.m
//  LALWeather
//
//  Created by LAL on 15/12/22.
//  Copyright © 2015年 LAL. All rights reserved.
//

#import "LALStateManager.h"

@implementation LALStateManager

+(LALTemperatureScale)temperatureScale{
    return (LALTemperatureScale)[[NSUserDefaults standardUserDefaults] integerForKey:@
            "temp_scale"];
}
+(void)setTemperatureScale:(LALTemperatureScale)scale{
    [[NSUserDefaults standardUserDefaults] setInteger:scale forKey:@"temp_scale"];
}

+ (NSDictionary *)weatherData{
    
    NSData *encodedWeatherData = [[NSUserDefaults standardUserDefaults] objectForKey:@"weather_data"];
    if(encodedWeatherData){
       return (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:encodedWeatherData];
    }
    return nil;
}
+(void)setWeatherData:(NSDictionary *)weatherData{
    NSData *encodedWeatherData = [NSKeyedArchiver archivedDataWithRootObject:weatherData];
    [[NSUserDefaults standardUserDefaults] setObject:encodedWeatherData forKey:@"weather_data"];
}

+ (NSArray *)weatherTags{
    NSData *encodedWeatherTags = [[NSUserDefaults standardUserDefaults] objectForKey:@"weather_tags"];
    if(encodedWeatherTags){
        return (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:encodedWeatherTags];
    }
    return nil;
}

+ (void)setWeatherTags:(NSArray *)weatherTags{
    NSData *encodedWeatherTags = [NSKeyedArchiver archivedDataWithRootObject:weatherTags];
    [[NSUserDefaults standardUserDefaults] setObject:encodedWeatherTags forKey:@"weather_tags"];
}

@end
