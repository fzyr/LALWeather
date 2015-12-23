//
//  LALMainViewController2.m
//  LALWeather
//
//  Created by LAL on 15/12/23.
//  Copyright © 2015年 LAL. All rights reserved.
//

#import "LALMainViewController2.h"

#define kMIN_TIME_SINCE_UPDATE          3600
#define kLOCAL_WEATHERVIEW_TAG          100


@implementation LALMainViewController2

-(void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:75/255.0 green:126/255.0 blue:227/255.0 alpha:1];
    [self initializeModel];
    [self initializePagingScrollView];
    [self initializeLocalWeatherView];
    [self initializeLocationButton];
    [self initializeWeatherDownloader];
    [self initializeLocationManager];

}

-(void)initializeModel{
    self.weatherData = [NSMutableDictionary dictionaryWithDictionary:[LALStateManager weatherData]];
    if(!self.weatherData){
        self.weatherData = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    
    self.weatherTags = [NSMutableArray arrayWithArray:[LALStateManager weatherTags]];
    if(!self.weatherTags){
        self.weatherTags = [NSMutableArray arrayWithCapacity:5];
    }


}

-(void)initializePagingScrollView{
    self.pagingScrollView = [[LALPagingScrollView alloc] initWithFrame:self.view.bounds];
    self.pagingScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.pagingScrollView];
}

-(void)initializeLocalWeatherView{
    LALWeatherView *weatherView = [[LALWeatherView alloc] initWithFrame:self.pagingScrollView.bounds];
    weatherView.local = YES;
    weatherView.tag = kLOCAL_WEATHERVIEW_TAG;
    [self.weatherTags addObject:[NSNumber numberWithInteger:kLOCAL_WEATHERVIEW_TAG ]];
    [LALStateManager setWeatherTags:self.weatherTags];
    [self.pagingScrollView addWeatherView:weatherView];
    [self.weatherViews addObject:weatherView];
};

-(void)initalizeNonlocalWeatherView{

}

-(void)initializeLocationButton{
    UIButton *updateLocationButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    updateLocationButton.frame = CGRectMake(self.view.bounds.size.width-60, self.view.bounds.size.height - 60, 40, 40);
    [updateLocationButton addTarget:self action:@selector(updateLocationButtonDidPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:updateLocationButton];
}

-(void)initializeWeatherDownloader{
    self.weatherDownloader = [LALWundergroundDownloader sharedDownloader];
}

-(void)initializeLocationManager{
    if(!_locationManager){
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        _locationManager.distanceFilter = 3000;
        _locationManager.delegate = self;
        _geocoder = [[CLGeocoder alloc] init];
        [_locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];

};

-(void)updateLocationButtonDidPressed:(id)sender{
    NSLog(@"button did pressed");

}


#pragma mark - CLLocationMangerDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    //1. 获取本地weatherView

    LALWeatherView *localWeatherView = (LALWeatherView *)[self.pagingScrollView viewWithTag:kLOCAL_WEATHERVIEW_TAG];
    NSLog(@"localWeaterhView: %@",localWeatherView);
    LALWeatherData *localWeatherData = [self.weatherData objectForKey:@0];
    //2. 如果没有weatherData或者weatherData创建超过一个小时，则重新获取
    if(!localWeatherView.hasData || [[NSDate date] timeIntervalSinceDate: localWeatherData.timeStamp] > kMIN_TIME_SINCE_UPDATE){
        [self.weatherDownloader dataForLocation:[locations lastObject] withTag:kLOCAL_WEATHERVIEW_TAG completion:^(LALWeatherData *data, NSError *error) {
            if(!error){
                [self downloadDidSucccessForWeatherViewWithTag:kLOCAL_WEATHERVIEW_TAG andWeatherData:data];
            }
            else{
                [self downloadDidFailForWeatherViewWithTag:kLOCAL_WEATHERVIEW_TAG];
            }
        }];
    }else{
        [localWeatherView updateWeatherViewWithData:localWeatherData];
    }
}

    

-(void)downloadDidSucccessForWeatherViewWithTag:(NSUInteger)tag andWeatherData:(LALWeatherData *)weatherData{
    //1. 找到weatherView
    LALWeatherView *weatherView = [self.pagingScrollView viewWithTag:tag];
    //2. 设置weatherData 对应tag
    [self.weatherData setObject:weatherData forKey:[NSNumber numberWithInteger:tag]];
    [weatherView updateWeatherViewWithData:weatherData];
    weatherView.hasData = YES;
    [LALStateManager setWeatherData:self.weatherData];
}



//
-(void)downloadDidFailForWeatherViewWithTag:(NSUInteger)tag{
    LALWeatherView *weatherView = [self.pagingScrollView viewWithTag:tag];
    weatherView.conditionDescriptionLabel.text = @"no weather data available";
}



@end
