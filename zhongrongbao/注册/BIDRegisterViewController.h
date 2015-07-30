//
//  BIDRegisterViewController.h
//  zhongrongbao
//
//  Created by mal on 14-8-18.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDBaseViewController.h"
#import "BIDCustomTextField.h"

@interface BIDRegisterViewController : BIDBaseViewController
{
    /**
     *手机号输入框
     */
    IBOutlet UITextField *_mobilePhoneNumberTF;
    /**
     *验证码输入框
     */
    IBOutlet UITextField *_verificationCodeTF;
    /**
     *密码输入框
     */
    IBOutlet UITextField *_passwordTF;
    /**
     *获取验证码按钮
     */
    IBOutlet UIButton *_verificationCodeBtn;
    /**
     *推荐人
     */
    IBOutlet UITextField *_referrerTF;
    /**
     *注册按钮
     */
    IBOutlet UIButton *_registerBtn;
}

- (IBAction)verificationCodeBtnHandler:(id)sender;
- (IBAction)registerBtnHandler:(id)sender;

@end
