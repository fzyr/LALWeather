//
//  LALWeatherView.m
//  LALWeather
//
//  Created by LAL on 15/12/19.
//  Copyright © 2015年 LAL. All rights reserved.
//

#import "LALWeatherView.h"
#import "Climacons.h"


@interface LALWeatherView()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIView *ribbon;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UILabel *updatedLabel;
@property (nonatomic, strong) UILabel *conditionIconLabel;
@property (nonatomic, strong) UILabel *conditionDescriptionLabel;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) UILabel *currentTemperatureLabel;
@property (nonatomic, strong) UILabel *hiloTemperatureLabel;
@property (nonatomic, strong) UILabel *forecastDayOneLabel;
@property (nonatomic, strong) UILabel *forecastDayTwoLabel;
@property (nonatomic, strong) UILabel *forecastDayThreeLabel;
@property (nonatomic, strong) UILabel *forecastIconOneLabel;
@property (nonatomic, strong) UILabel *forecastIconTwoLabel;
@property (nonatomic, strong) UILabel *forecastIconThreeLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end


@implementation LALWeatherView

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if(self){
        
        self.container = [[UIView alloc] initWithFrame:self.bounds];
        [self.container setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.container];

        
        self.ribbon = [[UIView alloc] initWithFrame:CGRectMake(0,1.30*self.center.y, self.bounds.size.width, 80)];
        self.ribbon.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
        [self.container addSubview:self.ribbon];
        
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
        self.panGestureRecognizer.minimumNumberOfTouches = 1;
        self.panGestureRecognizer.delegate = self;
        

        
        [self initializeUpdatedLabel];
        [self initializeConditionIconLabel];
        [self initializeConditionDescriptionLabel];
        [self initializeLocationLabel];
        [self initializeCurrentTemperatureLabel];
        [self initializeHiLoTemperatureLabel];
        [self initializeForecastDayLabels];
        [self initializeForecastIconLabels];
        [self initializeMottionEffects];
        
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityIndicator.backgroundColor = [UIColor clearColor];
        self.activityIndicator.center = self.center;
        [self.container addSubview:self.activityIndicator];
    }
    return self;
}



#pragma mark - helper method

-(void)initializeUpdatedLabel{
//Q: why use static const---------------------------------------
    static const NSInteger fontSize = 16;
    self.updatedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -1.5 *fontSize,self.bounds.size.width, 1.5 * fontSize)];
    [self.updatedLabel setNumberOfLines:0];
    [self.updatedLabel setAdjustsFontSizeToFitWidth:YES];
    [self.updatedLabel setFont:[UIFont fontWithName:LIGHT_FONT size:fontSize]];
    [self.updatedLabel setTextColor:[UIColor whiteColor]];
    [self.updatedLabel setTextAlignment:NSTextAlignmentCenter];
    [self.container addSubview:self.updatedLabel];
}

-(void)initializeConditionIconLabel{
    
    const NSInteger fontSize = 180;
    self.conditionIconLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, fontSize)];
    [self.conditionIconLabel setCenter:CGPointMake(self.container.center.x, 0.5 * self.center.y)];
    [self.conditionIconLabel setFont:[UIFont fontWithName:CLIMACONS_FONT size:fontSize]];
    [self.conditionIconLabel setBackgroundColor:[UIColor clearColor]];
    [self.conditionIconLabel setTextAlignment:NSTextAlignmentCenter];
    [self.conditionIconLabel setTextColor:[UIColor whiteColor]];
    [self.container addSubview:self.conditionIconLabel];
}

-(void)initializeConditionDescriptionLabel{
    
    const NSInteger fontSize = 48;
    self.conditionDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0.75*self.bounds.size.width, 1.5 * fontSize)];
    [self.conditionDescriptionLabel setCenter:CGPointMake(self.container.center.x, self.container.center.y)];
    [self.conditionDescriptionLabel setBackgroundColor:[UIColor clearColor]];
    [self.conditionDescriptionLabel setTextColor:[UIColor whiteColor]];
    [self.conditionDescriptionLabel setTextAlignment:NSTextAlignmentCenter];
    [self.conditionDescriptionLabel setFont:[UIFont fontWithName:ULTRALIGHT_FONT size:fontSize]];
    [self.conditionDescriptionLabel setNumberOfLines:0];
    [self.conditionDescriptionLabel setAdjustsFontSizeToFitWidth:YES];
    [self.container addSubview:self.conditionDescriptionLabel];
}

-(void)initializeLocationLabel{
    
    const NSInteger fontSize = 18;
    self.locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 1.5 * fontSize)];
    [self.locationLabel setCenter:CGPointMake(self.container.center.x, 1.18 * self.container.center.y)];
    [self.locationLabel setBackgroundColor:[UIColor clearColor]];
    [self.locationLabel setTextColor:[UIColor whiteColor]];
    [self.locationLabel setTextAlignment:NSTextAlignmentCenter];
    [self.locationLabel setFont:[UIFont fontWithName:LIGHT_FONT size:fontSize]];
    [self.locationLabel setNumberOfLines:0];
    [self.locationLabel setAdjustsFontSizeToFitWidth:NO];
    [self.container addSubview:self.locationLabel];
    
}

-(void)initializeCurrentTemperatureLabel{
    
    const NSInteger fontSize = 52;
    self.currentTemperatureLabel= [[UILabel alloc] initWithFrame:CGRectMake(0, 1.305 * self.center.y, 0.4 *self.bounds.size.width, fontSize)];
    [self.currentTemperatureLabel setBackgroundColor:[UIColor clearColor]];
    [self.currentTemperatureLabel setTextColor:[UIColor whiteColor]];
    [self.currentTemperatureLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self.currentTemperatureLabel setFont:[UIFont fontWithName:LIGHT_FONT size:fontSize]];

    
    
    [self.currentTemperatureLabel setNumberOfLines:0];
    [self.currentTemperatureLabel setAdjustsFontSizeToFitWidth:YES];
    [self.container addSubview:self.currentTemperatureLabel];

}

-(void)initializeHiLoTemperatureLabel{
    
    const NSInteger fontSize = 18;
    self.hiloTemperatureLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0.375 *self.bounds.size.width, fontSize)];
    [self.hiloTemperatureLabel setCenter:CGPointMake(self.currentTemperatureLabel.center.x - 4, self.currentTemperatureLabel.center.y + 0.5 * self.currentTemperatureLabel.bounds.size.height + 12)];
    [self.hiloTemperatureLabel setBackgroundColor:[UIColor clearColor]];
    [self.hiloTemperatureLabel setTextColor:[UIColor whiteColor]];
    [self.hiloTemperatureLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self.hiloTemperatureLabel setFont:[UIFont fontWithName:LIGHT_FONT size:fontSize]];
    
    [self.hiloTemperatureLabel setNumberOfLines:0];
    [self.hiloTemperatureLabel setAdjustsFontSizeToFitWidth:YES];
    [self.container addSubview:self.hiloTemperatureLabel];

}

-(void)initializeForecastDayLabels{
    
    const NSInteger fontSize = 18;
    
    self.forecastDayOneLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.forecastDayTwoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.forecastDayThreeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    NSArray *forecastDayLabels = @[self.forecastDayOneLabel, self.forecastDayTwoLabel, self.forecastDayThreeLabel];
    
    for(int i = 0; i < [forecastDayLabels count]; ++i){
        UILabel *forecastDayLabel = [forecastDayLabels objectAtIndex:i];
        [forecastDayLabel setFrame:CGRectMake(0.425 * self.bounds.size.width + (64 * i), 1.33 * self.center.y, 2 * fontSize, fontSize)];
        [forecastDayLabel setFont:[UIFont fontWithName:LIGHT_FONT size:fontSize]];
        [forecastDayLabel setBackgroundColor:[UIColor clearColor]];
        [forecastDayLabel setTextColor:[UIColor whiteColor]];
        [forecastDayLabel setTextAlignment: NSTextAlignmentCenter];
        [self.container addSubview:forecastDayLabel];
    }
}


-(void)initializeForecastIconLabels{
    
    const NSInteger fontSize = 40;
    self.forecastIconOneLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.forecastIconTwoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.forecastIconThreeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    NSArray *forecastIconLabels = @[self.forecastIconOneLabel, self.forecastIconTwoLabel, self.forecastIconThreeLabel];
    
    for(int i = 0; i < [forecastIconLabels count]; ++i){
        UILabel *forecastIconLabel = [forecastIconLabels objectAtIndex:i];
        [forecastIconLabel setFrame:CGRectMake(0.425 * self.bounds.size.width + (64 * i), 1.42 * self.center.y, fontSize, fontSize)];
        [forecastIconLabel setFont:[UIFont fontWithName: CLIMACONS_FONT size:40]];
        [forecastIconLabel setBackgroundColor:[UIColor clearColor]];
        [forecastIconLabel setTextColor:[UIColor whiteColor]];
        [forecastIconLabel setTextAlignment: NSTextAlignmentCenter];
        [self.container addSubview:forecastIconLabel];
    }
}

-(void)initializeMottionEffects{
    UIInterpolatingMotionEffect *motionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    
    [motionEffect setMinimumRelativeValue: @(-50)];
    [motionEffect setMaximumRelativeValue: @(50)];
    [self.conditionIconLabel addMotionEffect:motionEffect];
    
    UIInterpolatingMotionEffect *motionEffect1 = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    
    [motionEffect setMinimumRelativeValue: @(-50)];
    [motionEffect setMaximumRelativeValue: @(50)];
    [self.conditionIconLabel addMotionEffect:motionEffect1];
    
    UIInterpolatingMotionEffect *motionEffect2 = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"layer.shadowOffset" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    [motionEffect2 setMinimumRelativeValue:[NSValue valueWithCGPoint:CGPointMake(5, 5)]];
    [motionEffect2 setMaximumRelativeValue:[NSValue valueWithCGPoint:CGPointMake(10, 10)]];
    
    [self.conditionIconLabel addMotionEffect:motionEffect2];
    self.conditionIconLabel.layer.shadowOpacity = 0.5;
}








/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
