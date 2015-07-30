//
//  BIDBaseViewController.h
//  mashangban
//
//  Created by mal on 14-7-23.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BIDCustomSpinnerView.h"
#import "BIDAppDelegate.h"
#import "UIView+FindFirstResponder.h"
#import "BIDCommonMethods.h"

@interface BIDBaseViewController : UIViewController

/**
 *加载过程指示器
 */
@property (strong, nonatomic)BIDCustomSpinnerView *spinnerView;

@property (strong, nonatomic)UIToolbar *toolBar;

@property (assign, nonatomic)CGFloat keyboardHeight;
@property (assign, nonatomic)CGFloat distanceToMove;

@property (strong, nonatomic) UIImage *stretchImgForNormal;
@property (strong, nonatomic) UIImage *stretchImgForPress;

- (void)backBtnHandler;

@end
