//
//  LALConfigureLocationsTableViewController.h
//  LALWeather
//
//  Created by LAL on 15/12/28.
//  Copyright © 2015年 LAL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LALWeatherData.h"
@class LALConfigureLocationsTableViewController;
@protocol LALConfigureLocationsTableViewControllerDelegate

-(void)selectWeatherDataWithTag:(NSInteger)tag;
-(void)dismissConfigureLocationsTableViewController:(LALConfigureLocationsTableViewController *)configureLocationsTableViewController withWeatherData: (NSArray *)weatherData;
@end


@interface LALConfigureLocationsTableViewController : UITableViewController
@property (nonatomic, weak) id<LALConfigureLocationsTableViewControllerDelegate>delegate;
@property (nonatomic, strong) NSMutableArray *nonlocalWeatherData;
@end
