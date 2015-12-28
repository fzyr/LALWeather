//
//  LALPageControl.m
//  LALWeather
//
//  Created by LAL on 15/12/27.
//  Copyright © 2015年 LAL. All rights reserved.
//

#import "LALPageControl.h"

@implementation LALPageControl

-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        NSLog(@"%@",NSStringFromSelector(_cmd));
        self.numberOfPages = 1;
        self.pageIndicatorTintColor = [UIColor clearColor];
    }
    return self;
}

-(void)setNumberOfPages:(NSInteger)numberOfPages{
    [super setNumberOfPages:numberOfPages];
    [self __updateDots];
}

-(void)__updateDots{
    
    for (int i = 0; i < self.subviews.count; ++i){
        UIView *view = [self.subviews objectAtIndex:i];
        //        NSLog(@"%d, view %@",i,view);
        if(i == 0){
            UIImageView *imageView = [self __imageViewForSubView:view];
            imageView.image = [UIImage imageNamed:@"location_icon"];
        }
        NSLog(@"%d, view %@",i,view);
    }
}

-(UIImageView *)__imageViewForSubView:(UIView *)view{
    UIImageView *imageView = nil;
    if([view isKindOfClass:[UIView class]]){
        for(UIView *subview in view.subviews){
            if([subview isKindOfClass:[UIImageView class]]){
                imageView = (UIImageView *)subview;
                break;
            }
        }
        if(imageView == nil){
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, view.bounds.size.width*2, view.bounds.size.height*2)];
            [view addSubview:imageView];
        }
    }else{
        imageView = (UIImageView *)view;
    }
    return imageView;
}


@end
