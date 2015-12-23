//
//  LALMainViewController.m
//  LALWeather
//
//  Created by LAL on 15/12/18.
//  Copyright © 2015年 LAL. All rights reserved.
//


#import "LALMainViewController.h"
#import "LALWundergroundDownloader.h"
#import "LALWeatherView.h"
#import "LALPagingScrollView.h"
#import "LALStateManager.h"
#import "Climacons.h"
#import "UIImage+ImageEffects.h"
/*Constants */

#define kMIN_TIME_SINCE_UPDATE          3600
#define kMAX_NUM_WEATHER_VIEWS          5
#define kLOCAL_WEATHER_VIEW_TAG         0
#define kDEFAULT_BACKGROUND_GRADIENT    @"gradient5"


@interface LALMainViewController()<CLLocationManagerDelegate,UIScrollViewDelegate>
@property (strong, nonatomic) CLLocationManager             *locationManager;
@property (strong, nonatomic) NSMutableDictionary           *weatherData;
@property (strong, nonatomic) NSMutableArray                *weatherTags;
@property (strong, nonatomic) NSDateFormatter               *dateFormatter;
@property (assign, nonatomic) BOOL                          isScrolling;
@property (strong, nonatomic) LALSettingsViewController     *settingViewController;
@property (strong, nonatomic) LALAddLocationViewController  *addLocationViewController;

//subviews

@property (strong, nonatomic) UIView                        *darkenedBackgroundView;
@property (strong, nonatomic) UILabel                       *solLogoLabel;
@property (strong, nonatomic) UILabel                       *solTitleLabel;
// contains blurred screenshots of this controller's view when transitioning to another controller
@property (strong, nonatomic) UIImageView                   *blurredOverlayView;
@property (strong, nonatomic) UIButton                      *settingButton;
@property (strong, nonatomic) UIButton                      *addLocationButton;
@property (strong, nonatomic) UIPageControl                 *pageControl;
@property (strong, nonatomic) LALPagingScrollView           *pagingScrollView;



@end

@implementation LALMainViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        //initialize the weather data dictionary with saved data, if it exists
        NSDictionary *savedWeatherData = [LALStateManager weatherData];
        if(savedWeatherData){
            self.weatherData = [NSMutableDictionary dictionaryWithDictionary:savedWeatherData];
        }else{
            self.weatherData = [NSMutableDictionary dictionaryWithCapacity:5];
        }
        //initialize the weather tags array with saved data, if it exists
        NSArray *savedWeatherTags = [LALStateManager weatherTags];
        if(savedWeatherData){
            self.weatherTags = [NSMutableArray arrayWithArray:savedWeatherTags];
        }else{
            self.weatherTags = [NSMutableArray arrayWithCapacity:5];
        }
        
        // Configure Date Formatter
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"EEE MMM d, h:mm a"];
        
        // Initialize and configure the location manager and start updating the user's current location
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        self.locationManager.distanceFilter = 3000;
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
        
        //Initialize other properties
        
        [self initializeViewControllers];
        [self initializSubviews];
        [self initializeAddLocationButton];
        [self initializeSettingButton];

        [self.view bringSubviewToFront:self.blurredOverlayView];
        
        
        
        
        
    
    }
    return self;
}


-(void)initializeViewControllers{
    
    self.addLocationViewController = [[LALAddLocationViewController alloc] init];
    self.addLocationViewController.delegate = self;
    
    self.settingViewController = [[LALSettingsViewController alloc] init];
    self.settingViewController.delegate = self;
}

-(void)initializSubviews{
    
    // Initialize the darkended background view
    self.darkenedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.darkenedBackgroundView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
    [self.view addSubview:self.darkenedBackgroundView];
    
    // Initialize the Sol logo label
    self.solLogoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 160)];
    self.solLogoLabel.center = CGPointMake(self.view.center.x, 0.5 * self.view.center.y);
    self.solLogoLabel.font = [UIFont fontWithName:CLIMACONS_FONT size:200];
    self.solLogoLabel.backgroundColor = [UIColor clearColor];
    self.solLogoLabel.textColor = [UIColor whiteColor];
    self.solLogoLabel.textAlignment = NSTextAlignmentCenter;
    self.solLogoLabel.text = [NSString stringWithFormat:@"%c", ClimaconSun];
    [self.view addSubview:self.solLogoLabel];

    // Initialize the Sol title label
    self.solTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64)];
    self.solTitleLabel.center = self.view.center;
    self.solTitleLabel.font = [UIFont fontWithName:ULTRALIGHT_FONT size:200];
    self.solTitleLabel.backgroundColor = [UIColor clearColor];
    self.solTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.solTitleLabel.text = @"LAL";
    [self.view addSubview:self.solTitleLabel];
    
    // Initialize the paging scroll view
    self.pagingScrollView = [[LALPagingScrollView alloc] initWithFrame:self.view.bounds];
    self.pagingScrollView.delegate = self;
    self.pagingScrollView.bounces = NO;
    [self.view addSubview:self.pagingScrollView];
    
    // Initialize the page control
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-32, self.view.bounds.size.width, 32)];
    [self.pageControl setHidesForSinglePage:YES];
    [self.view addSubview:self.pageControl];
    
    // Initialize the blurred overlay view
    self.blurredOverlayView = [[UIImageView alloc] initWithImage:[[UIImage alloc] init]];
    self.blurredOverlayView.alpha = 0.0;
    self.blurredOverlayView.frame = self.view.bounds;
    [self.view addSubview:self.blurredOverlayView];
    
}

-(void)initializeAddLocationButton{

    self.addLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UILabel *plusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    plusLabel.font = [UIFont fontWithName:ULTRALIGHT_FONT size:40];
    plusLabel.textColor = [UIColor whiteColor];
    plusLabel.textAlignment = NSTextAlignmentCenter;
    plusLabel.text = @"+";
    [self.addLocationButton addSubview:plusLabel];
    self.addLocationButton.frame = CGRectMake(self.view.bounds.size.width - 44, self.view.bounds.size.height - 54, 44, 44);
    [self.addLocationButton setShowsTouchWhenHighlighted:YES];
    [self.addLocationButton addTarget:self action:@selector(addLocationButtonDidPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addLocationButton];
}

-(void)initializeSettingButton{
    self.settingButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    self.settingButton.tintColor = [UIColor whiteColor];
    self.settingButton.frame = CGRectMake(4, self.view.bounds.size.height - 48, 44, 44);
    [self.settingButton setShowsTouchWhenHighlighted:YES];
    [self.settingButton addTarget:self action:@selector(settingButtonDidPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.settingButton];
}


-(void)initializeLocalWeatherView{
    LALWeatherView *localWeatherView = [[LALWeatherView alloc] initWithFrame:self.view.bounds];
    localWeatherView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kDEFAULT_BACKGROUND_GRADIENT]];
    localWeatherView.local = YES;
    localWeatherView.delegate = self;
    localWeatherView.tag = kLOCAL_WEATHER_VIEW_TAG;
    [self.pagingScrollView addSubview:localWeatherView];
    self.pageControl.numberOfPages += 1;
    LALWeatherData *localWeatherData = [self.weatherData objectForKey:[NSNumber numberWithInteger:kLOCAL_WEATHER_VIEW_TAG]];
    if(localWeatherData){
        [localWeatherView updateWeatherViewWithData:localWeatherData];
    }
    [self.pagingScrollView addWeatherView:localWeatherView];
}

-(void)initializeNonlocalWeatherViews{
    for (NSNumber *tagNumber in self.weatherTags){
    // Initialize NonlocalWeatherViews
        LALWeatherData *weatherData = [self.weatherData objectForKey:tagNumber];
        if(weatherData){
            LALWeatherView *weatherView = [[LALWeatherView alloc] initWithFrame:self.view.bounds];
            weatherView.delegate = self;
            weatherView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"gradient5.png"]];
            weatherView.tag = tagNumber.integerValue;
            weatherView.local = NO;
            self.pageControl.numberOfPages += 1;
            [self.pagingScrollView addWeatherView:weatherView];
            [weatherView updateWeatherViewWithData:weatherData];
        }
    }
}

#pragma  mark Using a LALMainViewController

-(void)showBlurredOverLayView:(BOOL)show{

    [UIView animateWithDuration:0.25 animations:^{
        self.blurredOverlayView.alpha = (show)? 1.0: 0.0;
    }];
}

-(void)setBlurredOverlayImage{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        //  Take a screen shot of this controller's view
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [self.view.layer renderInContext:context];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        //  Blur the screen shot
        UIImage *blurredImage = [image applyBlurWithRadius:20 tintColor:[UIColor colorWithWhite:0.15 alpha:0.5] saturationDeltaFactor:1.5 maskImage:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.blurredOverlayView.image = blurredImage;
        });
    });
}

#pragma mark Updating Weather Data

-(void)updateWeatherData{
    for (LALWeatherView *weatherView in self.pagingScrollView.subviews){
        if(NO == weatherView.local){
            
            //  Only update non local weather data
            LALWeatherData *weatherData = [self.weatherData objectForKey:[NSNumber numberWithInteger:weatherView.tag]];
            
            //  Only update if the minimum time for updates has passed
            if([[NSDate date] timeIntervalSinceDate:weatherData.timeStamp] >= kMIN_TIME_SINCE_UPDATE || !weatherView.hasData){
                
                //  If the weather view is already showing data, we need to move the activity indicator
                if(weatherView.hasData)
                    weatherView.activityIndicator.center = CGPointMake(weatherView.center.x, 1.8 * weatherView.center.y);
            }
            [weatherView.activityIndicator startAnimating];
            [[LALWundergroundDownloader sharedDownloader] dataForPlacemark:weatherData.placemark withTag:weatherView.tag completion:^(LALWeatherData *data, NSError *error) {
                if(error){
                    [self downloadDidFailForWeatherViewWithTag:weatherView.tag];
                }else{
                    [self downloadDidFinishWithData:data withTag:weatherView.tag];
                }
            }];
        }
    }
}


-(void)downloadDidFailForWeatherViewWithTag: (NSInteger)tag{
    for(LALWeatherView *weatherView in self.pagingScrollView.subviews){
        if(weatherView.tag == tag){
        //  If the weather view doesn't have any data, show a failure message
            if(!weatherView.hasData){
                weatherView.conditionIconLabel.text = @"☹";
                weatherView.conditionDescriptionLabel.text = @"Update Failed";
                weatherView.locationLabel.text = @"Check your network connection";
            }
            [weatherView.activityIndicator stopAnimating];
        }
    }
}

-(void)downloadDidFinishWithData:(LALWeatherData *)data withTag:(NSInteger)tag{
    for (LALWeatherView *weatherView in self.pagingScrollView.subviews) {
        if(weatherView.tag == tag){
            [self.weatherData setObject:data forKey:[NSNumber numberWithInteger:tag]];
        // Update the weather view with the downloaded data
            [weatherView updateWeatherViewWithData:data];
            [weatherView.activityIndicator stopAnimating];
        }
    }
}

#pragma mark CLLocationManagerDelegate Method

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    //  Only add the local weather view if location services authorized
    if(status == kCLAuthorizationStatusAuthorizedWhenInUse){
        [self initializeLocalWeatherView];
        [self initializeNonlocalWeatherViews];
        [self setBlurredOverlayImage];
        [self updateWeatherData];
    }else if (status != kCLAuthorizationStatusNotDetermined){
        [self initializeNonlocalWeatherViews];
        [self setBlurredOverlayImage];
        [self updateWeatherData];
    }else if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted){
        // If location services are disabled and no saved weather data is found show the add locatio view controller
        if([self.pagingScrollView.subviews count] == 0){
            [self presentViewController:self.addLocationViewController animated:YES completion:nil];
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    //  Download new weather data for the local weather view
    for(LALWeatherView *weatherView in self.pagingScrollView.subviews){
        if(weatherView.local == YES){
            LALWeatherData *weatherData = [self.weatherData objectForKey:[NSNumber numberWithInteger:weatherView.tag]];
            
            // Only update the weather data if the time sinc elast update has exceeded the minimum time
            if([[NSDate date] timeIntervalSinceDate:weatherData.timeStamp] >= kMIN_TIME_SINCE_UPDATE || !weatherView.hasData){
                
                // If the weather view has data, move the acitivity indicator to  not overall with any labels
                if(weatherView.hasData){
                    weatherView.activityIndicator.center = CGPointMake(weatherView.center.x, 1.8 * weatherView.center.y);
                    [weatherView.activityIndicator startAnimating];
                    // Initiate download request
                    
                    [[LALWundergroundDownloader sharedDownloader] dataForLocation:[locations lastObject] withTag:weatherView.tag completion:^(LALWeatherData *data, NSError *error) {
                        if(data){
                            [self downloadDidFinishWithData:data withTag:weatherView.tag];
                        }else{
                            [self downloadDidFailForWeatherViewWithTag:weatherView.tag];
                        }
                    }];
                }
            }
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    // If the local weather view has no data and a location could not be determined show a failure message
    for(LALWeatherView *weatherView in self.pagingScrollView.subviews){
        if(weatherView.local == YES && !weatherView.hasData){
            weatherView.conditionIconLabel.text = @"☹";
            weatherView.conditionDescriptionLabel.text = @"Update Failed";
            weatherView.locationLabel.text = @"Check your network connection";
        }
    }
}


#pragma mark AddLocationButton Methods

-(void)addLocationButtonDidPressed:(id)sender{
    // Only show the blurred overlay view if weather views have been added
    if([self.pagingScrollView.subviews count] > 0){
        [self showBlurredOverLayView:YES];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            self.solLogoLabel.alpha = 0.0;
            self.solTitleLabel.alpha = 0.0;
        }];
    }
    [self presentViewController:self.addLocationViewController animated:YES completion:nil];
}

#pragma mark LALAddlocationViewControllerDelegate Methods

-(void)didAddLocationWithPlacemark:(CLPlacemark *)placemark{
    // Get cached weather data for the added placemark if it exists
    LALWeatherData *weatherData = [self.weatherData objectForKey:[NSNumber numberWithInteger:placemark.locality.hash]];




}




-(void)settingButtonDidPressed:(id)sender{

}









@end