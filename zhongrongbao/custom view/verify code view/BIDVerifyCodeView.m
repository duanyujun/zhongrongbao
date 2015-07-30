//
//  BIDVerifyCodeView.m
//  zhongrongbao
//
//  Created by mal on 14-10-3.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDVerifyCodeView.h"

@implementation BIDVerifyCodeView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)showTheView
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    CGPoint pt = CGPointMake(keyWindow.center.x, keyWindow.center.y);
    pt.y -= 40;
    self.center = pt;
    self.layer.cornerRadius = 5;
    [keyWindow addSubview:self];
    [UIView animateWithDuration:2.0f animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished){
        if(finished)
        {
            [self removeFromSuperview];
        }
    }];
}

- (void)dismissTheView
{
    [self removeFromSuperview];
}

@end
