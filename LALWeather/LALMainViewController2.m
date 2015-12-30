//
//  LALMainViewController2.m
//  LALWeather
//
//  Created by LAL on 15/12/23.
//  Copyright © 2015年 LAL. All rights reserved.
//

#import "LALMainViewController2.h"



@implementation LALMainViewController2

#pragma mark - LALMainViewController2's life cycle event
-(void)viewDidLoad{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithRed:75/255.0 green:126/255.0 blue:227/255.0 alpha:1];
    [self setModalPresentationStyle:UIModalPresentationCustom];
    [self __initializeModel];
    [self __initializeWeatherDownloader];
    
    [self __initializePagingScrollView];
    [self __initializeLocalWeatherView];
    [self __initializeNonlocalWeatherView];
    [self __initializePageControl];

    [self __initializeLocationManager];
    
    [self __initializeAddLocationButton];
    [self __initializeConfigureLocationsButton];
 

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
// update localWeatherView with weatherData;
    [self.locationManager startUpdatingLocation];
// update nonlocalWeatherView with weatherData;
    for(NSInteger tag = 1; tag < self.weatherTags.count; ++tag){
        LALWeatherView *weatherView = [self.pagingScrollView viewWithTag:tag];
        [weatherView.activityIndicator startAnimating];
        
        [self __getWeatherDataForWeatherViewWithTag:tag andLocation:nil andPlacemark:nil completion:^(NSError *error, LALWeatherData *weatherData, NSInteger tag) {
            if(!error){
                [self __downloadDidSucccessForWeatherViewWithTag:tag andWeatherData:weatherData];
            }else{
                [self __downloadDidFailForWeatherViewWithTag:tag];
            }
        }];
    }
// update self.pageControl
    self.pageControl.numberOfPages = self.weatherTags.count;
    self.pageControl.currentPage = self.currentShownIndex;
// update self.addLocationButton
    if(self.weatherTags.count >= kMAX_WEATHERVIEW_NUM){
        [self.addLocationButton setHidden:YES];
    }else{
        [self.addLocationButton setHidden:NO];
    }
// update self.configureLocationsButton
    if(self.weatherTags.count <= 1 ){
        [self.configureLocationsButton setHidden:YES];
    }else{
        [self.configureLocationsButton setHidden:NO];
    }
}

-(void)pageControlButtonDidPressed:(id)sender{
    CGFloat x = self.pageControl.currentPage * self.pagingScrollView.bounds.size.width;
    [self.pagingScrollView scrollRectToVisible:CGRectMake(x, 0, self.pagingScrollView.bounds.size.width, self.pagingScrollView.bounds.size.height) animated:YES];
}

-(void)addLocationButtonDidPressed:(id)sender{
    LALAddLocationTableViewController *addLocationTVC = [[LALAddLocationTableViewController alloc] init];
    addLocationTVC.delegate = self;
    [self presentViewController:addLocationTVC animated:YES completion:nil];
    
}

-(void)configureLocationsButtonDidPressed:(id)sender{
    
    LALConfigureLocationsTableViewController *configureLocationTVC = [[LALConfigureLocationsTableViewController alloc] init];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:configureLocationTVC];
    configureLocationTVC.weatherData = [self __weatherDataArrayFromWeatherDataDictionary:self.weatherData];
    configureLocationTVC.delegate = self;
    [self presentViewController:nav animated:YES completion:nil];
    
}

-(void)setCurrentShownIndex:(NSInteger)currentShownIndex{
    if(_currentShownIndex == currentShownIndex) return;
    if(currentShownIndex == [self.weatherTags count] + 1){
        self.pageControl.numberOfPages = currentShownIndex;
    }
    _currentShownIndex = currentShownIndex;
    [self.pagingScrollView scrollRectToVisible:CGRectMake(self.pagingScrollView.bounds.size.width * _currentShownIndex, 0, self.pagingScrollView.bounds.size.width, self.pagingScrollView.bounds.size.height) animated:YES];
    self.pageControl.currentPage = _currentShownIndex;
    
}

#pragma mark - helper method
-(void)__initializeModel{
    self.weatherData = [NSMutableDictionary dictionaryWithDictionary:[LALStateManager weatherData]];
    if(!self.weatherData){
        self.weatherData = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    
    self.weatherTags = [NSMutableArray arrayWithArray:[LALStateManager weatherTags]];
    if(!self.weatherTags){
        self.weatherTags = [NSMutableArray arrayWithCapacity:5];
    }
}

-(void)__initializeWeatherDownloader{
    self.weatherDownloader = [LALWundergroundDownloader sharedDownloader];
}

-(void)__initializePagingScrollView{
    self.pagingScrollView = [[LALPagingScrollView alloc] initWithFrame:self.view.bounds];
    self.pagingScrollView.backgroundColor = [UIColor clearColor];
    self.pagingScrollView.delegate = self;
    [self.view addSubview:self.pagingScrollView];
}

-(void)__initializeLocalWeatherView{
    LALWeatherView *weatherView = [[LALWeatherView alloc] initWithFrame:self.pagingScrollView.bounds];
    weatherView.local = YES;
    weatherView.tag = kLOCAL_WEATHERVIEW_TAG;
    if(![self.weatherTags containsObject:[NSNumber numberWithInteger:kLOCAL_WEATHERVIEW_TAG ]]){
        [self.weatherTags addObject:[NSNumber numberWithInteger:kLOCAL_WEATHERVIEW_TAG]];
        [LALStateManager setWeatherTags:self.weatherTags];
    }
    [self.pagingScrollView addWeatherView:weatherView isLaunch:YES];
};

-(void)__initializeNonlocalWeatherView{
    for(int i = 0; i < self.weatherTags.count; ++i){
        NSInteger tag =[(NSNumber *)[self.weatherTags objectAtIndex:i] integerValue];
        if(tag !=kLOCAL_WEATHERVIEW_TAG){
            LALWeatherView *nonLocalWeatherView = [[LALWeatherView alloc] initWithFrame:self.pagingScrollView.bounds];
            [nonLocalWeatherView.activityIndicator startAnimating];
            nonLocalWeatherView.local = NO;
            nonLocalWeatherView.tag = tag;
            nonLocalWeatherView.hasData = NO;
            [self.pagingScrollView addWeatherView:nonLocalWeatherView isLaunch:YES];
        }
    }
}




-(void)__initializeAddLocationButton{
    self.addLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.addLocationButton setHidden:NO];
    UIImage *image = [UIImage imageNamed:@"plus_BTN_100"];
    [self.addLocationButton setBackgroundImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.addLocationButton setTintColor:[UIColor whiteColor]];
     [self.addLocationButton setFrame:CGRectMake(0, 0, 30, 30)];
    [self.addLocationButton setCenter:CGPointMake(self.pagingScrollView.center.x * 1.8, self.pagingScrollView.center.y * 1.8)];
    [self.addLocationButton addTarget:self action:@selector(addLocationButtonDidPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addLocationButton];
    if(self.weatherTags.count >= kMAX_WEATHERVIEW_NUM){
        [self.addLocationButton setHidden:YES];
    }
}

-(void)__initializeConfigureLocationsButton{
    self.configureLocationsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:@"configure_BTN_512"];
    [self.configureLocationsButton setBackgroundImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.configureLocationsButton setTintColor:[UIColor whiteColor]];
    [self.configureLocationsButton setFrame:CGRectMake(0, 0, 30, 30)];
    [self.configureLocationsButton setCenter:CGPointMake(self.pagingScrollView.center.x * 0.2, self.pagingScrollView.center.y * 1.8)];
    [self.configureLocationsButton addTarget:self action:@selector(configureLocationsButtonDidPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.configureLocationsButton];
    if(self.weatherTags.count <= 1 ){
        [self.configureLocationsButton setHidden:YES];
    }
    
}






-(void)__initializePageControl{
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
    [self.pageControl setCenter:CGPointMake(self.pagingScrollView.center.x, self.pagingScrollView.center.y * 1.8)];
    self.pageControl.numberOfPages = [self.weatherTags count];
    self.pageControl.currentPage = 0;
    [self.view addSubview:self.pageControl];
    [self.pageControl addTarget:self action:@selector(pageControlButtonDidPressed:) forControlEvents:UIControlEventTouchUpInside];
}



-(void)__initializeLocationManager{
    if(!_locationManager){
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        _locationManager.distanceFilter = 3000;
        _locationManager.delegate = self;
        _geocoder = [[CLGeocoder alloc] init];
        [_locationManager requestWhenInUseAuthorization];
    }
};




//get weatherData for weatherView

-(void)__getWeatherDataForWeatherViewWithTag: (NSInteger)tag andLocation:(CLLocation *)location andPlacemark:(CLPlacemark *)placemark completion:(GetWeatherDataCompletion)completion{
    NSError *error = nil;
    LALWeatherData *weatherData = [self.weatherData objectForKey:[NSNumber numberWithInteger:tag]];
    LALWeatherView *weatherView = [self.pagingScrollView viewWithTag:tag];
    
    if(tag == kLOCAL_WEATHERVIEW_TAG && !location){
        completion(nil,nil,tag);
    }else if (tag == kLOCAL_WEATHERVIEW_TAG){
        if(!weatherData || [[NSDate date] timeIntervalSinceDate: weatherData.timeStamp] > kMIN_TIME_SINCE_UPDATE){
            [self.weatherDownloader dataForLocation:location withTag:tag completion:^(LALWeatherData *data, NSError *error) {
                if(!error){
                    completion(nil,data,tag);
                }else{
                    completion(error,data,tag);
                }
            }];
        }else{
            completion(nil,weatherData,tag);
            
        }
    }else{
        if(!weatherData || [[NSDate date] timeIntervalSinceDate: weatherData.timeStamp] > kMIN_TIME_SINCE_UPDATE){
            [self.weatherDownloader dataForPlacemark:placemark withTag:tag completion:^(LALWeatherData *data, NSError *error) {
                if(!error){
                    completion(nil,data,tag);
                }else{
                    completion(error,data,tag);
                }
            }];
        }else{
            completion(nil,weatherData,tag);
        }
    }
}

-(void)__downloadDidSucccessForWeatherViewWithTag:(NSUInteger)tag andWeatherData:(LALWeatherData *)weatherData{
    //1. 找到weatherView
    LALWeatherView *weatherView = [self.pagingScrollView viewWithTag:tag];
    //2. 设置weatherData 对应tag
    [self.weatherData setObject:weatherData forKey:[NSNumber numberWithInteger:tag]];
    [self __updateWeatherView:weatherView WithData:weatherData];
    weatherView.hasData = YES;
    [LALStateManager setWeatherData:self.weatherData];
    [weatherView.activityIndicator stopAnimating];
}

-(void)__downloadDidFailForWeatherViewWithTag:(NSUInteger)tag{
    LALWeatherView *weatherView = [self.pagingScrollView viewWithTag:tag];
    [self __updateWithNoAvailableDataForWeatherView:weatherView];
    [weatherView.activityIndicator stopAnimating];
}

//update weatherView with weatherData

-(void)__updateWeatherView:(LALWeatherView *)weatherView WithData:(LALWeatherData *)weatherData{
    if(!weatherData){
        return;
    }
    weatherView.hasData = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        weatherView.updatedLabel.text = [weatherData.dateFormatter stringFromDate:weatherData.timeStamp];
        weatherView.conditionIconLabel.text = weatherData.currentSnapshot.iconText;
        weatherView.conditionDescriptionLabel.text = weatherData.currentSnapshot.weatherDescription;
        
        // show the location,去掉“市”，同一地名显示（有些locality有市，有些没有）
        NSString *tempCity = weatherData.placemark.locality;
        NSString *city = [tempCity stringByReplacingOccurrencesOfString:@"市" withString:@""];
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

-(void)__updateWithNoAvailableDataForWeatherView:(LALWeatherView *)weatherView {
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

#pragma mark - CLLocationMangerDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    LALWeatherView *weatherView = [self.pagingScrollView viewWithTag:kLOCAL_WEATHERVIEW_TAG];
    [weatherView.activityIndicator startAnimating];
    [self __getWeatherDataForWeatherViewWithTag:kLOCAL_WEATHERVIEW_TAG andLocation:[locations lastObject] andPlacemark: nil completion:^(NSError *error, LALWeatherData *weatherData, NSInteger tag) {
        if(!error){
            [self __downloadDidSucccessForWeatherViewWithTag:tag andWeatherData:weatherData];
            [self.locationManager stopUpdatingLocation];
        }else{
            [self __downloadDidFailForWeatherViewWithTag:tag];
            [self.locationManager stopUpdatingLocation];
        }
    }];
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
            self.currentShownIndex = tag;
            return;
        }
    }
// else
    //inialize a new nonlocalWeatherView
    NSInteger nonLocalWeatherViewTag = [self.weatherTags count];
    LALWeatherView *nonLocalweatherView = [[LALWeatherView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width * nonLocalWeatherViewTag, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    nonLocalweatherView.local = NO;
    nonLocalweatherView.tag = nonLocalWeatherViewTag;
    self.currentShownIndex = nonLocalWeatherViewTag;
    if(nonLocalweatherView){
        [self.weatherTags addObject:[NSNumber numberWithInteger:nonLocalWeatherViewTag]];
        [LALStateManager setWeatherTags:self.weatherTags];
    }
    [self.pagingScrollView addWeatherView:nonLocalweatherView isLaunch:NO];
    
    // update this nonlocalWeatherView with weatherData
    dispatch_async(dispatch_get_main_queue(), ^{
        [nonLocalweatherView.activityIndicator startAnimating];
    });

    [self __getWeatherDataForWeatherViewWithTag:nonLocalWeatherViewTag andLocation:nil andPlacemark:placemark completion:^(NSError *error, LALWeatherData *weatherData, NSInteger tag) {
        if(!error){
            [self __downloadDidSucccessForWeatherViewWithTag:nonLocalWeatherViewTag andWeatherData:weatherData];
        }else{
            [self __downloadDidFailForWeatherViewWithTag:nonLocalWeatherViewTag];
        }
    }];
}

-(void)dismissAddLocationTableViewController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - LALConfigureLocationsTableViewControllerDelegate

-(void)selectWeatherDataWithTag:(NSInteger)tag{
    self.currentShownIndex = tag;
}

-(void)dismissConfigureLocationsTableViewController:(LALConfigureLocationsTableViewController *)configureLocationsTableViewController withWeatherData:(NSArray *)weatherData{
    
    self.weatherData = [self __weatherDataDicionaryFromWeatherDataArray:weatherData];
    [LALStateManager setWeatherData:self.weatherData];
    self.weatherTags = [self __weatherTagsFromWeatherData:weatherData];
    [LALStateManager setWeatherTags:self.weatherTags];


    for(int i = self.weatherTags.count; i < [self.pagingScrollView subviews].count; ++i){
        LALWeatherView *weatherView = self.pagingScrollView.subviews[i];
        [self.pagingScrollView removeSubview:weatherView];
    }    
    [self dismissViewControllerAnimated:YES completion:nil];
}



-(NSMutableArray *)__weatherDataArrayFromWeatherDataDictionary:(NSDictionary *)weatherData{
    
    NSArray *allKeys = [weatherData allKeys];
    NSMutableArray *tempWeatherData = [[NSMutableArray alloc] initWithCapacity:5];
    NSArray *sortedAllKeys = [allKeys sortedArrayUsingSelector:@selector(compare:)];
    for(NSString *key in sortedAllKeys){
        if([key integerValue] == kLOCAL_WEATHERVIEW_TAG){
            [tempWeatherData insertObject:[self.weatherData objectForKey:key] atIndex:0];
        }else{
            [tempWeatherData addObject:[self.weatherData objectForKey:key]];
        }
    }
    return tempWeatherData;
}

-(NSMutableDictionary *)__weatherDataDicionaryFromWeatherDataArray:(NSArray *)weatherData{
    NSMutableDictionary *tempWeatherData = [[NSMutableDictionary alloc] initWithCapacity:5];
    for(NSInteger i = 0; i < weatherData.count; ++i){
        if(i == 0){
            [tempWeatherData setObject:weatherData[i] forKey: [NSNumber numberWithInteger:kLOCAL_WEATHERVIEW_TAG]];
        }else{
            [tempWeatherData setObject:weatherData[i]  forKey:[NSNumber numberWithInteger:i]];
        }
    }
    return tempWeatherData;
}

-(NSMutableArray *)__weatherTagsFromWeatherData:(NSArray *)weatherData{
    NSMutableArray *tempWeatherTags = [NSMutableArray arrayWithCapacity:5];
    for(int i = 0; i < weatherData.count; ++i){
        if(i == 0){
            [tempWeatherTags insertObject: [NSNumber numberWithInteger:kLOCAL_WEATHERVIEW_TAG ] atIndex:0];
        }else{
            [tempWeatherTags addObject:[NSNumber numberWithInteger:i]];
        }
    }
    return tempWeatherTags;
}




@end
