//
//  BIDBaseViewControllerII.h
//  zhongrongbao
//
//  Created by mal on 15/6/27.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BIDAppDelegate.h"
#import "UIView+FindFirstResponder.h"
#import "BIDCommonMethods.h"

@interface BIDBaseViewControllerII : UIViewController
@property (strong, nonatomic) UIToolbar *toolBar;
/**
 *网络状态
 */
@property (assign, nonatomic) BOOL bNetworkConnecting;
@property (assign, nonatomic) CGFloat keyboardHeight;
@property (assign, nonatomic) CGFloat distanceToMove;
/**
 *网络请求数组
 */
@property (strong, nonatomic) NSMutableArray *networkConnectionArr;

- (void)keyboardWillShow:(NSNotification*)notification;
- (void)keyboardWillHide:(NSNotification*)notification;

- (void)showSpinnerView;
- (void)hideSpinnerView;
@end
