//
//  LALWeatherData.m
//  LALWeather
//
//  Created by LAL on 15/12/18.
//  Copyright © 2015年 LAL. All rights reserved.
//

#import "LALWeatherData.h"
#import "Climacons.h"
@implementation LALWeatherDataSnapshot

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if(self){
        self.weatherDescription = [aDecoder decodeObjectForKey:@"weather_description"];
        self.hightTemperature = [aDecoder decodeObjectForKey:@"high_temp"];
        self.lowTemperature = [aDecoder decodeObjectForKey:@"low_temp"];
        self.currentTemperature = [aDecoder decodeObjectForKey:@"current_temp"];
        self.weekday = [aDecoder decodeObjectForKey:@"weekday"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.weatherDescription forKey:@"weather_description"];
    [aCoder encodeObject:self.hightTemperature forKey:@"high_temp"];
    [aCoder encodeObject:self.lowTemperature forKey:@"low_temp"];
    [aCoder encodeObject:self.currentTemperature forKey:@"current_temp"];
    [aCoder encodeObject:self.weekday forKey:@"weekday"];
}

-(NSString *)iconText{
    if(!_iconText){
        _iconText = [NSString stringWithFormat:@"%c", ClimaconSun];
        NSString *lowerCaseWeatherDescription = [self.weatherDescription lowercaseString];
        if([lowerCaseWeatherDescription containsString:@"clear"]){
            _iconText = [NSString stringWithFormat:@"%c",ClimaconSun];
        }else if ([lowerCaseWeatherDescription containsString:@"cloud"]){
            _iconText = [NSString stringWithFormat:@"%c", ClimaconCloud];
        }else if ([lowerCaseWeatherDescription containsString:@"drizzle"]   ||
                  [lowerCaseWeatherDescription containsString:@"rain"]      ||
                  [lowerCaseWeatherDescription containsString:@"thunderstorm"]){
            _iconText = [NSString stringWithFormat:@"%c",ClimaconRain];
        }else if([lowerCaseWeatherDescription containsString:@"snow"]       ||
                 [lowerCaseWeatherDescription containsString:@"hail"]       ||
                 [lowerCaseWeatherDescription containsString:@"ice"]){
            _iconText = [NSString stringWithFormat:@"%c",ClimaconSnow];
        }else if([lowerCaseWeatherDescription containsString:@"fog"]        ||
                 [lowerCaseWeatherDescription containsString:@"overcast"]   ||
                 [lowerCaseWeatherDescription containsString:@"smoke"]      ||
                 [lowerCaseWeatherDescription containsString:@"dust"]       ||
                 [lowerCaseWeatherDescription containsString:@"ash"]        ||
                 [lowerCaseWeatherDescription containsString:@"mist"]       ||
                 [lowerCaseWeatherDescription containsString:@"haze"]       ||
                 [lowerCaseWeatherDescription containsString:@"spray"]      ||
                 [lowerCaseWeatherDescription containsString:@"squall"]){
            _iconText = [NSString stringWithFormat:@"%c",ClimaconHaze];
        }
    }
    return _iconText;
}

@end


@implementation LALWeatherData

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if(self){
        self.placemark = [aDecoder decodeObjectForKey:@"placemark"];
        self.timeStamp = [aDecoder decodeObjectForKey:@"time_stamp"];
        self.currentSnapshot = [aDecoder decodeObjectForKey:@"current_snapshot"];
        self.forecastSnapshots = [aDecoder decodeObjectForKey:@"forecast_snapshots"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.placemark forKey:@"placemark"];
    [aCoder encodeObject:self.timeStamp forKey:@"time_stamp"];
    [aCoder encodeObject:self.currentSnapshot forKey:@"current_snapshot"];
    [aCoder encodeObject:self.forecastSnapshots forKey:@"forecast_snapshots"];
}

-(NSMutableArray *)forecastSnapshots{
    if(!_forecastSnapshots){
        _forecastSnapshots = [NSMutableArray array];
    }
    return _forecastSnapshots;
}

-(NSString *)description{
    
    NSString *day0Description = [NSString stringWithFormat:@"%@, <%@,%@>, %@, %@, %@, %@", self.currentSnapshot. weatherDescription,self.currentSnapshot.lowTemperature,self.currentSnapshot.hightTemperature, self.currentSnapshot.weekday, self.currentSnapshot.weatherDescription, self.currentSnapshot.iconText, self.placemark.locality];
    
    LALWeatherDataSnapshot *day1 = [self.forecastSnapshots objectAtIndex:0];
    NSString *day1Description = [NSString stringWithFormat:@"%@, <%@,%@>, %@, %@, %@",day1.weatherDescription, day1.lowTemperature,day1.hightTemperature, day1.weekday, day1.weatherDescription, day1.iconText];
    
    LALWeatherDataSnapshot *day2 = [self.forecastSnapshots objectAtIndex:1];
    NSString *day2Description = [NSString stringWithFormat:@"%@, <%@,%@>, %@, %@, %@",day2.weatherDescription, day2.lowTemperature,day2.hightTemperature, day2.weekday, day2.weatherDescription, day2.iconText];
    
    LALWeatherDataSnapshot *day3 = [self.forecastSnapshots objectAtIndex:2];
    NSString *day3Description = [NSString stringWithFormat:@"%@, <%@,%@>, %@, %@, %@",day3.weatherDescription, day3.lowTemperature,day3.hightTemperature, day3.weekday, day3.weatherDescription, day3.iconText];
    
    NSString *descrip = [NSString stringWithFormat:@"day0: %@,\nday1: %@,\nday2: %@,\nday3: %@\n",day0Description, day1Description, day2Description, day3Description];
    
    return descrip;
    
}

-(NSDateFormatter *)dateFormatter{
    if(!_dateFormatter){
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
    }
    return _dateFormatter;
}


@end
