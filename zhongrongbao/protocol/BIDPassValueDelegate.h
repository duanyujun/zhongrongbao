//
//  BIDPassValueDelegate.h
//  党务通
//
//  Created by mal on 13-11-19.
//  Copyright (c) 2013年 mal. All rights reserved.
//
//传递答案索引
#import <Foundation/Foundation.h>

@protocol BIDPassValueDelegate <NSObject>

@optional
- (void)passFileName:(NSString*)fileName;

@optional
- (void)passDate:(NSString*)strDate mode:(int)mode;

@optional
- (void)passValueOpenDoc;

@optional
- (void)passValue:(int)param1;
@optional
- (void)passValue:(NSString*)str1 param:(NSString*)str2;
@optional
- (void)passValue1:(NSString*)strContent index:(int)index;

@optional
//0代表关闭键盘  1代表上一项 2代表下一项
- (void)keyboardToolBarMsg:(int)param;

@optional
//侧边栏传值用到
- (void)passValue:(NSString*)param1 param2:(NSString*)param2 type:(int)type;

@optional
//获取人员列表中用到
- (void)passValue:(NSString*)param1 param2:(NSString*)param2 param3:(int)param3 param4:(int)param4;

@end
