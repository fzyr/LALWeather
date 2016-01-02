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
#import "Climacons.h"
#import "LALAddLocationTableViewController.h"
#import "LALPageControl.h"
#import "LALConfigureLocationsTableViewController.h"
#import <SMPageControl.h>

#define kMIN_TIME_SINCE_UPDATE          3600
#define kLOCAL_WEATHERVIEW_TAG          100
#define kMAX_WEATHERVIEW_NUM            5
typedef void(^GetWeatherDataCompletion)(NSError *error, LALWeatherData *weatherData, NSInteger tag);

@interface LALMainViewController2 : UIViewController<CLLocationManagerDelegate, UIScrollViewDelegate, LALAddLoationTableViewControllerDelegate,LALConfigureLocationsTableViewControllerDelegate>

@property (nonatomic, strong) LALPagingScrollView *pagingScrollView;
@property (nonatomic, strong) NSMutableDictionary *weatherData;
@property (nonatomic, strong) NSMutableArray *weatherTags;
@property (nonatomic, assign) NSInteger currentShownIndex;



@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) LALWundergroundDownloader *weatherDownloader;
@property (nonatomic, strong) UIButton *addLocationButton;
@property (nonatomic, strong) UIButton *configureLocationsButton;
@property (nonatomic, strong) SMPageControl *pageControl;
@property (nonatomic, assign) BOOL isLaunch;

@end
