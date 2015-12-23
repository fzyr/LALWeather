//
//  LALMainViewController2.h
//  LALWeather
//
//  Created by LAL on 15/12/23.
//  Copyright © 2015年 LAL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LALPagingScrollView.h"
#import "LALWeatherData.h"
#import "LALWeatherView.h"
#import "LALWundergroundDownloader.h"
#import "LALStateManager.h"
@interface LALMainViewController2 : UIViewController<CLLocationManagerDelegate>

@property (nonatomic, strong) LALPagingScrollView *pagingScrollView;
@property (nonatomic, strong) NSMutableDictionary *weatherData;
@property (nonatomic, strong) NSMutableArray *weatherTags;
@property (nonatomic, strong) NSMutableArray *weatherViews;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) LALWundergroundDownloader *weatherDownloader;
@end
