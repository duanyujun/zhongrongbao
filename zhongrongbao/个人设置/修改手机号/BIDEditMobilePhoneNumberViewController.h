//
//  BIDEditMobilePhoneNumberViewController.h
//  zhongrongbao
//
//  Created by mal on 14-10-2.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDBaseViewController.h"
#import "BIDCustomTextField.h"

@interface BIDEditMobilePhoneNumberViewController : BIDBaseViewController
{
    /**
     *新手机号码
     */
    IBOutlet UILabel *_newMobilePhoneNumberLabel;
    /**
     *验证码
     */
    IBOutlet UITextField *_verifyCodeTF;
    /**
     *获取验证码按钮
     */
    IBOutlet UIButton *_verifyCodeBtn;
    /**
     *按钮
     */
    IBOutlet UIButton *_queryBtn;
}
/**
 *原绑定手机号码
 */
@property (copy, nonatomic) NSString *oldBindingMobilePhoneNumber;
/**
 *新手机号
 */
@property (copy, nonatomic) NSString *bindingMobilePhoneNumber;

/**
 *获取验证码
 */
- (IBAction)getVerifyCodeBtnHandler:(id)sender;
/**
 *绑定新手机号
 */
- (IBAction)bindingNewMobilePhoneNumberBtnHandler:(id)sender;

@end
