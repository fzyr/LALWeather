//
//  LALWeatherView.h
//  LALWeather
//
//  Created by LAL on 15/12/19.
//  Copyright © 2015年 LAL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LALWeatherData.h"

@protocol LALWeatherViewDelegate <NSObject>



@end


@interface LALWeatherView : UIView
@property (nonatomic, weak) id<LALWeatherViewDelegate>delegate;
@property (nonatomic, assign) BOOL hasData;
@property (nonatomic, assign) BOOL local;
@property (nonatomic, readonly) UIView *container;
@property (nonatomic, readonly) UIView *ribbon;
@property (nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, readonly) UILabel *updatedLabel;
@property (nonatomic, readonly) UILabel *conditionIconLabel;
@property (nonatomic, readonly) UILabel *conditionDescriptionLabel;
@property (nonatomic, readonly) UILabel *locationLabel;
@property (nonatomic, readonly) UILabel *currentTemperatureLabel;
@property (nonatomic, readonly) UILabel *hiloTemperatureLabel;
@property (nonatomic, readonly) UILabel *forecastDayOneLabel;
@property (nonatomic, readonly) UILabel *forecastDayTwoLabel;
@property (nonatomic, readonly) UILabel *forecastDayThreeLabel;
@property (nonatomic, readonly) UILabel *forecastIconOneLabel;
@property (nonatomic, readonly) UILabel *forecastIconTwoLabel;
@property (nonatomic, readonly) UILabel *forecastIconThreeLabel;



@property (nonatomic, readonly) UIActivityIndicatorView *activityIndicator;

@end
