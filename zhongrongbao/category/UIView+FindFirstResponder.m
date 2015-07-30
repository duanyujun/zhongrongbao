//
//  UIView+FindFirstResponder.m
//  Nav
//
//  Created by mal on 13-10-22.
//  Copyright (c) 2013年 mal. All rights reserved.
//

#import "UIView+FindFirstResponder.h"

@implementation UIView (FindFirstResponder)
- (UIView*)findFirstResponder
{
    if(self.isFirstResponder)
    {
        return self;
    }
    for(UIView *subView in self.subviews)
    {
        UIView *firstResponder = [subView findFirstResponder];
        if(firstResponder != nil)
        {
            return firstResponder;
        }
    }
    return nil;
}
@end