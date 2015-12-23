//
//  LALPagingScrollView.m
//  LALWeather
//
//  Created by LAL on 15/12/19.
//  Copyright © 2015年 LAL. All rights reserved.
//

#import "LALPagingScrollView.h"


@implementation LALPagingScrollView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.pagingEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
    }
    NSLog(@"pagingscrollview: %d",self.subviews.count);
    return self;
}


-(void)addWeatherView:(LALWeatherView *)weatherView{
    if(!weatherView) return;
    NSLog(@"pagingscrollview before add: %d, %@",self.subviews.count, self.subviews);
    NSInteger numberOfSubviews = self.subviews.count;
    [weatherView setFrame:CGRectMake(self.bounds.size.width * numberOfSubviews, 0, self.bounds.size.width, self.bounds.size.height)];
    [self setContentSize: CGSizeMake(self.bounds.size.width * (numberOfSubviews + 1), self.bounds.size.height)];

    [self addSubview:weatherView];
    NSLog(@"pagingscrollview after add: %d, %@",self.subviews.count, self.subviews);
}



-(void)insertSubview:(UIView *)weatherView atIndex:(NSInteger)index{
//1. insert weatherView to superView (view Hierachy);
    [super insertSubview:weatherView atIndex:index];
//2. rearrange the frame
    [weatherView setFrame:CGRectMake(self.bounds.size.width * index, 0, self.bounds.size.width, self.bounds.size.height)];
    NSInteger numerOfSubviews = self.subviews.count;
    for (NSInteger i = index + 1; i < numerOfSubviews; ++i){
        UIView *subview = [self.subviews objectAtIndex:i];
        [subview setFrame:CGRectMake(self.bounds.size.width * index, 0, self.bounds.size.width, self.bounds.size.height)];
    }
    [self setContentSize: CGSizeMake(self.bounds.size.width * numerOfSubviews, self.bounds.size.height)];
    [self setContentOffset: CGPointMake(self.bounds.size.width * index, 0)];
}

-(void)removeSubview:(UIView *)weatherView{
    NSInteger index = [self.subviews indexOfObject:weatherView];
    if(index != NSNotFound){
        NSUInteger numberOfSubviews = [self.subviews count];
        for (NSInteger i = index + 1; i < numberOfSubviews; ++i){
            UIView *subview = [self.subviews objectAtIndex:i];
            [subview setFrame:CGRectMake(self.bounds.size.width * (i-1), 0, self.bounds.size.width, self.bounds.size.height)];
        }
        [weatherView removeFromSuperview];
        [self setContentSize: CGSizeMake(self.bounds.size.width * (numberOfSubviews-1), self.bounds.size.height)];
        [self setContentOffset:CGPointMake(self.bounds.size.width * index, self.bounds.size.height)];
    }
}



@end
