//
//  BIDMenuView2.h
//  shangwuting
//
//  Created by mal on 13-12-20.
//  Copyright (c) 2013年 mal. All rights reserved.
//

//菜单内容，全部标记，取消标记，取消
#import <UIKit/UIKit.h>

@interface BIDMenuView2 : UIView

@property (strong, nonatomic) UIButton *cancelBtn;

@property (strong, nonatomic) UIView *bgView;

@property (strong, nonatomic) NSMutableArray *btnsArr;
@property (strong, nonatomic) NSArray *titlesArr;

- (id)initWithFrame:(CGRect)frame arr:(NSArray*)arr;
- (id)initWithTitleArr:(NSArray*)arr;

- (void)initView;

- (void)showMenuView;
- (void)dismissMenuView;

- (void)animationStop:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context;

@end
