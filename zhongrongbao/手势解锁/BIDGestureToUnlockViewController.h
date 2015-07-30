//
//  BIDGestureToUnlockViewController.h
//  zhongrongbao
//
//  Created by mal on 14-9-15.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIDGestureToUnlockViewController : UIViewController
{
    /**
     *忘记手势密码
     */
    IBOutlet UIButton *_forgetGesturePasswordBtn;
    /**
     *切换账户
     */
    IBOutlet UIButton *_changeAccountBtn;
    /**
     *
     */
    IBOutlet UILabel *_welcomeLabel;
    /**
     *提示语
     */
    IBOutlet UILabel *_hintLabel;
}

/**
 *解锁成功后是跳转到首页还是当前页
 */
@property (assign, nonatomic) BOOL bToHomePage;
/**
 *导航视图
 */
@property (assign, nonatomic) UINavigationController *navController;

- (IBAction)forgetGesturePasswordBtnHandler:(id)sender;
- (IBAction)changeAccountBtnHandler:(id)sender;

@end
