//
//  LALAddLocationTableViewController.h
//  LALWeather
//
//  Created by LAL on 15/12/26.
//  Copyright © 2015年 LAL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLPlacemark;
@protocol LALAddLoationTableViewControllerDelegate <NSObject>

- (void)addLocationDidSuccessWithPlacemark:(CLPlacemark *)placemark;
- (void)dismissAddLocationTableViewController;
@end

@interface LALAddLocationTableViewController : UITableViewController
@property (nonatomic, weak) id<LALAddLoationTableViewControllerDelegate>delegate;
@end
