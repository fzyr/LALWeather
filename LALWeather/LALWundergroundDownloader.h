//
//  LALWundergroundDownloader.h
//  LALWeather
//
//  Created by LAL on 15/12/18.
//  Copyright © 2015年 LAL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LALWeatherData.h"
#import <UIKit/UIKit.h>

typedef void (^LALWeatherDataDownloadCompletion) (LALWeatherData *data, NSError *error);
/**
 SOLWundergroundDownloader is a singleton object that queries the Wunderground Weather API and downloads weather data for a given location.
 */

@interface LALWundergroundDownloader : NSObject


/*singleton*/
+(LALWundergroundDownloader *)sharedDownloader;

/*download weather data based on location*/
-(void)dataForLocation:(CLLocation *)location withTag:(NSUInteger) tag completion:
(LALWeatherDataDownloadCompletion)completion;
-(void)dataForPlacemark:(CLPlacemark *)placemark withTag:(NSUInteger) tag completion:
(LALWeatherDataDownloadCompletion)completion;

@end
