//
//  LALMainViewController.h
//  LALWeather
//
//  Created by LAL on 15/12/18.
//  Copyright © 2015年 LAL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LALWeatherView.h"
#import "LALAddLocationViewController.h"
#import "LALSettingsViewController.h"
@interface LALMainViewController : UIViewController<LALAddLocationViewControllerDelegate, LALSettingViewControllerDelegate,LALWeatherViewDelegate>

@property (nonatomic, readonly) CLLocationManager *locationManager ;
- (void)updateWeatherData;

@end
