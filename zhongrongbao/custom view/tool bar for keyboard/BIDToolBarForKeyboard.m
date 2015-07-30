//
//  BIDToolBarForKeyboard.m
//  zhongrongbao
//
//  Created by mal on 15/7/5.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import "BIDToolBarForKeyboard.h"

@implementation BIDToolBarForKeyboard
@synthesize myDelegate;

+ (id)getToolBarInstance
{
    static BIDToolBarForKeyboard *toolBar;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        toolBar = [[BIDToolBarForKeyboard alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, 30)];
        UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"关闭键盘" style:UIBarButtonItemStyleBordered target:self action:@selector(closeKeyboardHandler)];
        item1.tintColor = [UIColor whiteColor];
        UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [toolBar setItems:[[NSArray alloc] initWithObjects:item2, item1, nil]];
        toolBar.barStyle = UIBarStyleBlack;
        toolBar.translucent = YES;
    });
    return toolBar;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)closeKeyboardHandler
{
    [myDelegate closeKeyboard];
}

@end
