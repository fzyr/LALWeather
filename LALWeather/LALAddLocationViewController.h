//
//  LALAddLocationViewController.h
//  LALWeather
//
//  Created by LAL on 15/12/22.
//  Copyright © 2015年 LAL. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CLPlacemark;
@protocol LALAddLocationViewControllerDelegate <NSObject>

-(void)didAddLocationWithPlacemark:(CLPlacemark *)placemark;
-(void)dismissAddLocationViewController;

@end

@interface LALAddLocationViewController : UIViewController
@property (nonatomic, weak) id<LALAddLocationViewControllerDelegate>delegate;
@end
