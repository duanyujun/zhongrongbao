//
//  BIDLoginViewController.h
//  mashangban
//
//  Created by mal on 14-7-23.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDBaseViewController.h"
@class BIDTextFieldWithImg;

extern NSString *REFRESH_PORTRAIT_EVENT;
@interface BIDLoginViewController : BIDBaseViewController
{
    /**
     *用户名编辑框
     */
    IBOutlet UITextField *_usernameTF;
    /**
     *密码编辑框
     */
    IBOutlet UITextField *_passwordTF;
    /**
     *登录按钮
     */
    IBOutlet UIButton *_loginBtn;
    /**
     *忘记密码
     */
    IBOutlet UIButton *_forgetPwdBtn;
    /**
     *注册
     */
    IBOutlet UIButton *_registerBtn;
    /**
     *用户名编辑框和密码编辑框所在的view
     */
    IBOutlet UIView *_containerView;
}

@property (assign, nonatomic) BOOL bRequestException;
/**
 *
 */

- (void)textFieldEditDone:(UITextField*)textField;

- (void)getUserInfo;
- (void)initLayout;
- (IBAction)loginBtnHandler:(id)sender;

@end
