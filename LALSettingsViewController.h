//
//  LALSettingsViewController.h
//  LALWeather
//
//  Created by LAL on 15/12/22.
//  Copyright © 2015年 LAL. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LALSettingViewControllerDelegate <NSObject>
-(void)doSomething;


@end

@interface LALSettingsViewController : UIViewController
@property (nonatomic, weak) id<LALSettingViewControllerDelegate> delegate;
@end
