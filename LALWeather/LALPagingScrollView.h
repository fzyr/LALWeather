//
//  LALPagingScrollView.h
//  LALWeather
//
//  Created by LAL on 15/12/19.
//  Copyright © 2015年 LAL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LALWeatherView.h"
@interface LALPagingScrollView : UIScrollView

-(void)addWeatherView:(LALWeatherView *)weatherView;

-(void)insertSubview:(UIView *)weatherView atIndex:(NSInteger)index;

-(void)removeSubview:(UIView *)weatherView;


@end
