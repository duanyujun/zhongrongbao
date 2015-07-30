//
//  BIDResetPasswordViewController.h
//  zhongrongbao
//
//  Created by mal on 15/7/4.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import "BIDBaseViewController.h"
@class BIDCustomTextField;

@interface BIDResetPasswordViewController : BIDBaseViewController
{
    IBOutlet BIDCustomTextField *_mobilePhoneTF;
    IBOutlet BIDCustomTextField *_verifyCodeTF;
    /**
     *获取验证码
     */
    IBOutlet UIButton *_verifyCodeBtn;
    IBOutlet UITextField *_pwdTF;
    IBOutlet UITextField *_pwdAgainTF;
    IBOutlet UIButton *_setBtn;
}

@end
