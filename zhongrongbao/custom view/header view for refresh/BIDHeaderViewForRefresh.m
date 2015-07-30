//
//  BIDHeaderViewForRefresh.m
//  shandongshangbao
//
//  Created by mal on 14/12/22.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDHeaderViewForRefresh.h"

@implementation BIDHeaderViewForRefresh

- (void)awakeFromNib
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGRect frame = self.frame;
    frame.size.width = screenSize.width;
    self.frame = frame;
    //
    _spinnerView.frame = CGRectMake((CGRectGetWidth(frame)-20)/2, 8, 20, 20);
    _hintLabel.frame = CGRectMake((CGRectGetWidth(frame)-304)/2, 36, 304, 21);
}

- (void)readyRefresh
{
    _hintLabel.text = @"下拉刷新";
}

- (void)canRefresh
{
    _hintLabel.text = @"释放开始刷新";
}

- (void)isRefreshing
{
    [_spinnerView startAnimating];
    _hintLabel.text = @"刷新中";
}

- (void)completeRefresh
{
    [_spinnerView stopAnimating];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
