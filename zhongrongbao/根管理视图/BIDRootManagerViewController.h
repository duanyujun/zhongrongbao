//
//  BIDRootManagerViewController.h
//  zhongrongbao
//
//  Created by mal on 14-8-20.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BIDFunctionListViewController;

@interface BIDRootManagerViewController : UIViewController

@property (strong, nonatomic) BIDFunctionListViewController *functionListVC;
@property (strong, nonatomic) UINavigationController *navController;
@property (assign, nonatomic) BOOL bFunctionListShow;

- (void)jumpToLoginViewController;
- (void)mainViewControllerReset;

@end
