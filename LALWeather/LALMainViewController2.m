//
//  LALMainViewController2.m
//  LALWeather
//
//  Created by LAL on 15/12/23.
//  Copyright © 2015年 LAL. All rights reserved.
//

#import "LALMainViewController2.h"



@implementation LALMainViewController2

-(void)viewDidLoad{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithRed:75/255.0 green:126/255.0 blue:227/255.0 alpha:1];
    [self setModalPresentationStyle:UIModalPresentationCustom];
    [self initializeModel];
    [self initializeWeatherDownloader];
    
    [self initializePagingScrollView];
    [self initializeLocalWeatherView];
    [self initializeNonlocalWeatherView];
    [self initializePageControl];
    

    [self initializeLocationManager];
    [self initializeAddLocationButton];

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear");
    self.pageControl.numberOfPages = self.weatherTags.count;
    self.pageControl.currentPage = self.currentTag;

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
    self.pagingScrollView.delegate = self;
    [self.view addSubview:self.pagingScrollView];
}

-(void)initializeLocalWeatherView{
    LALWeatherView *weatherView = [[LALWeatherView alloc] initWithFrame:self.pagingScrollView.bounds];
    weatherView.local = YES;
    weatherView.tag = kLOCAL_WEATHERVIEW_TAG;
    self.currentTag = 0;
    if(![self.weatherTags containsObject:[NSNumber numberWithInteger:kLOCAL_WEATHERVIEW_TAG ]]){
        [self.weatherTags addObject:[NSNumber numberWithInteger:kLOCAL_WEATHERVIEW_TAG]];
        [LALStateManager setWeatherTags:self.weatherTags];
    }
    [LALStateManager setWeatherTags:self.weatherTags];
    [self.pagingScrollView addWeatherView:weatherView isLaunch:YES];
    [self.weatherViews addObject:weatherView];
};

-(void)initializeNonlocalWeatherView{
    for(int i = 0; i < self.weatherTags.count; ++i){
        NSInteger tag =[(NSNumber *)[self.weatherTags objectAtIndex:i] integerValue];
        if(tag !=kLOCAL_WEATHERVIEW_TAG){
            LALWeatherView *nonLocalWeatherView = [[LALWeatherView alloc] initWithFrame:self.pagingScrollView.bounds];
            [nonLocalWeatherView.activityIndicator startAnimating];
            nonLocalWeatherView.local = NO;
            nonLocalWeatherView.tag = tag;
            nonLocalWeatherView.hasData = NO;
            [self.pagingScrollView addWeatherView:nonLocalWeatherView isLaunch:YES];
            
            LALWeatherData *nonLocalWeatherData = [self.weatherData objectForKey:[NSNumber numberWithInteger:tag]];
    
            if([[NSDate date] timeIntervalSinceDate: nonLocalWeatherData.timeStamp] > kMIN_TIME_SINCE_UPDATE){
                NSLog(@"> kMIN_Time_Since_update");
                NSLog(@"placemark.locality: %@",nonLocalWeatherData.placemark.locality);
                [self.weatherDownloader dataForPlacemark:nonLocalWeatherData.placemark withTag:tag completion:^(LALWeatherData *data, NSError *error) {
                    NSLog(@"into weatherDownloader");
                    if(!error){
                        NSLog(@"before success");
                        [self downloadDidSucccessForWeatherViewWithTag:tag andWeatherData:data];
                        NSLog(@"download success with tag: %d",tag);
                    }
                    else{
                        NSLog(@"before fail");
                        [self downloadDidFailForWeatherViewWithTag:tag];
                        NSLog(@"download failure with tag: %d",tag);
                    }
                    
                }];
                NSLog(@"after weatherDwonloder");
            }else{
                [self updateWeatherView:nonLocalWeatherView WithData:nonLocalWeatherData];
                NSLog(@" else");
            }
        }
    }
}


-(void)initializeAddLocationButton{
    self.addLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:@"add_BTN_512"];
    [self.addLocationButton setBackgroundImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.addLocationButton setTintColor:[UIColor whiteColor]];
    [self.addLocationButton setFrame:CGRectMake(0, 0, 30, 30)];
    [self.addLocationButton setCenter:CGPointMake(self.pagingScrollView.center.x * 1.8, self.pagingScrollView.center.y * 1.8)];
    [self.addLocationButton addTarget:self action:@selector(addLocationButtonDidPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addLocationButton];

}

-(void)addLocationButtonDidPressed:(id)sender{
    LALAddLocationTableViewController *addLocationTVC = [[LALAddLocationTableViewController alloc] init];
    addLocationTVC.delegate = self;
    [self presentViewController:addLocationTVC animated:YES completion:nil];
    
}

-(void)initializePageControl{
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
    [self.pageControl setCenter:CGPointMake(self.pagingScrollView.center.x, self.pagingScrollView.center.y * 1.8)];
    self.pageControl.numberOfPages = [self.weatherTags count];
    self.pageControl.currentPage = 0;
    [self.view addSubview:self.pageControl];
    [self.pageControl addTarget:self action:@selector(pageControlButtonDidPressed:) forControlEvents:UIControlEventTouchUpInside];
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


}

-(void)pageControlButtonDidPressed:(id)sender{
    CGFloat x = self.pageControl.currentPage * self.pagingScrollView.bounds.size.width;
    [self.pagingScrollView scrollRectToVisible:CGRectMake(x, 0, self.pagingScrollView.bounds.size.width, self.pagingScrollView.bounds.size.height) animated:YES];
}

#pragma mark - CLLocationMangerDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    //1. 获取本地weatherView
    
    LALWeatherView *localWeatherView = (LALWeatherView *)[self.pagingScrollView viewWithTag:kLOCAL_WEATHERVIEW_TAG];
    [localWeatherView.activityIndicator startAnimating];
    LALWeatherData *localWeatherData = [self.weatherData objectForKey:@kLOCAL_WEATHERVIEW_TAG];

    //2. 如果没有weatherData或者weatherData创建超过一个小时，则重新获取
    if(!localWeatherData || [[NSDate date] timeIntervalSinceDate: localWeatherData.timeStamp] > kMIN_TIME_SINCE_UPDATE){
        [self.weatherDownloader dataForLocation:[locations lastObject] withTag:kLOCAL_WEATHERVIEW_TAG completion:^(LALWeatherData *data, NSError *error) {
            if(!error){
                [self downloadDidSucccessForWeatherViewWithTag:kLOCAL_WEATHERVIEW_TAG andWeatherData:data];
            }
            else{
                [self downloadDidFailForWeatherViewWithTag:kLOCAL_WEATHERVIEW_TAG];
            }
        }];
    }else{
        [self updateWeatherView:localWeatherView WithData:localWeatherData];
    }
}

    

-(void)downloadDidSucccessForWeatherViewWithTag:(NSUInteger)tag andWeatherData:(LALWeatherData *)weatherData{
    //1. 找到weatherView
    LALWeatherView *weatherView = [self.pagingScrollView viewWithTag:tag];
    //2. 设置weatherData 对应tag
    [self.weatherData setObject:weatherData forKey:[NSNumber numberWithInteger:tag]];
    [self updateWeatherView:weatherView WithData:weatherData];
    weatherView.hasData = YES;
    [LALStateManager setWeatherData:self.weatherData];
    [weatherView.activityIndicator stopAnimating];
}



//
-(void)downloadDidFailForWeatherViewWithTag:(NSUInteger)tag{
    LALWeatherView *weatherView = [self.pagingScrollView viewWithTag:tag];
    [self updateWithNoAvailableDataForWeatherView:weatherView];
    [weatherView.activityIndicator stopAnimating];
}

#pragma mark - update weatherView with weatherData

-(void)updateWeatherView:(LALWeatherView *)weatherView WithData:(LALWeatherData *)weatherData{
    if(!weatherData){
        return;
    }
    weatherView.hasData = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        weatherView.updatedLabel.text = [weatherData.dateFormatter stringFromDate:weatherData.timeStamp];
        weatherView.conditionIconLabel.text = weatherData.currentSnapshot.iconText;
        weatherView.conditionDescriptionLabel.text = weatherData.currentSnapshot.weatherDescription;
        
        // show the location
        NSString *city = weatherData.placemark.locality;
        NSString *state = weatherData.placemark.administrativeArea;
        NSString *country = weatherData.placemark.country;
        
        weatherView.locationLabel.text = [NSString stringWithFormat:@"%@",city];

        
        NSString *temperatureString = [weatherData.currentSnapshot.currentTemperature stringValue];
        NSString *temperatureFinalString = [NSString stringWithFormat:@"%@℃",temperatureString];
        NSMutableAttributedString *abs = [[NSMutableAttributedString alloc] initWithString:temperatureFinalString];
        NSRange range = [temperatureFinalString rangeOfString:@"℃"];

        [abs addAttributes:@{NSFontAttributeName: [UIFont fontWithName:LIGHT_FONT size:20], NSBaselineOffsetAttributeName: @18} range:range];
        weatherView.currentTemperatureLabel.attributedText = abs;
        
        
        weatherView.hiloTemperatureLabel.text = [NSString stringWithFormat:@"%@  %@",[weatherData.currentSnapshot.lowTemperature stringValue], [weatherData.currentSnapshot.hightTemperature stringValue]];
        // show the forecast
        LALWeatherDataSnapshot *forecastDayOneSnapshot = [weatherData.forecastSnapshots objectAtIndex:0];
        
        LALWeatherDataSnapshot *forecastDayTwoSnapshot = [weatherData.forecastSnapshots objectAtIndex:1];
        
        LALWeatherDataSnapshot *forecastDayThreeSnapshot = [weatherData.forecastSnapshots objectAtIndex:2];
        
        // set forecast label
        weatherView.forecastDayOneLabel.text = [forecastDayOneSnapshot.weekday substringToIndex:3];
        weatherView.forecastDayTwoLabel.text = [forecastDayTwoSnapshot.weekday substringToIndex:3];
        weatherView.forecastDayThreeLabel.text = [forecastDayThreeSnapshot.weekday substringToIndex:3];
        
        // set forecast icon
        weatherView.forecastIconOneLabel.text = forecastDayOneSnapshot.iconText;
        weatherView.forecastIconTwoLabel.text = forecastDayTwoSnapshot.iconText;
        weatherView.forecastIconThreeLabel.text = forecastDayThreeSnapshot.iconText;
//        if(weatherView.tag != kLOCAL_WEATHERVIEW_TAG && !self.isLaunch){
//            [self.pagingScrollView scrollRectToVisible:CGRectMake(self.view.bounds.size.width * weatherView.tag , 0, self.view.bounds.size.width, self.view.bounds.size.height) animated: YES];
//            if(self.isLaunch){
//                self.isLaunch = NO;}
//        }
        [weatherView.activityIndicator stopAnimating];
    });
}

-(void)updateWithNoAvailableDataForWeatherView:(LALWeatherView *)weatherView {
    dispatch_async(dispatch_get_main_queue(), ^{
        for(UIView *subview in weatherView.container.subviews){
            if([subview isKindOfClass:[UILabel class]]){
                UILabel *label = (UILabel *)subview;
                if(![label.font.fontName isEqualToString: CLIMACONS_FONT] ){
                    label.text = @"- -";
                }
            }
        }
        LALWeatherData * weatherData = [self.weatherData objectForKey:[NSNumber numberWithInteger:weatherView.tag]];
        weatherView.locationLabel.text = weatherData.placemark.locality;
        [weatherView.activityIndicator stopAnimating];
    });
}

#pragma mark- UIScrollViewDelegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat x = self.pagingScrollView.contentOffset.x;
    CGFloat w = self.pagingScrollView.bounds.size.width;
    NSInteger currentPage = x/w;
    self.pageControl.currentPage = currentPage;
}



#pragma mark - LALAddLocationTableViewControllerDelegate

-(void)addLocationDidSuccessWithPlacemark:(CLPlacemark *)placemark{
    
// search for self.weatherData, if exist, then scroll to that weatherView
    NSMutableArray *allKeys = [[self.weatherData allKeys] mutableCopy];
    
    for(NSString *key in allKeys){
        LALWeatherData *weatherData = [self.weatherData objectForKey:key];
        if([weatherData.placemark.locality isEqualToString:placemark.locality]){
            NSInteger tag = [key integerValue];
            CGPoint offset = CGPointMake(0, 0);
            if(tag != kLOCAL_WEATHERVIEW_TAG){
                 offset = CGPointMake(self.pagingScrollView.bounds.size.width * tag, 0);
            }
            [self.pagingScrollView setContentOffset:offset];
            self.currentTag = tag;
            return;
        }
    }
    
    NSInteger nonLocalWeatherViewTag = [self.weatherTags count];
    LALWeatherView *nonLocalweatherView = [[LALWeatherView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width * nonLocalWeatherViewTag, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    nonLocalweatherView.local = NO;
    nonLocalweatherView.tag = nonLocalWeatherViewTag;
    self.currentTag = nonLocalWeatherViewTag;
    if(nonLocalweatherView){
        [self.weatherTags addObject:[NSNumber numberWithInteger:nonLocalWeatherViewTag]];
        [LALStateManager setWeatherTags:self.weatherTags];
    }

    [self.pagingScrollView addWeatherView:nonLocalweatherView isLaunch:NO];
    self.pageControl.currentPage = self.weatherTags.count;
    [self.weatherDownloader dataForPlacemark:placemark withTag: nonLocalWeatherViewTag completion:^(LALWeatherData *data, NSError *error) {
        if(!error){
            [self downloadDidSucccessForWeatherViewWithTag:nonLocalWeatherViewTag andWeatherData:data];
        }
        else{
            [self downloadDidFailForWeatherViewWithTag:nonLocalWeatherViewTag];
        }
    }];
}

-(void)dismissAddLocationTableViewController{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
