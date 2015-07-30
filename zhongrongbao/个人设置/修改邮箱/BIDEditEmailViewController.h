//
//  BIDEditEmailViewController.h
//  zhongrongbao
//
//  Created by mal on 14-10-5.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDBaseViewController.h"
#import "BIDCustomTextField.h"

@interface BIDEditEmailViewController : BIDBaseViewController
{
    /**
     *新的邮箱
     */
    IBOutlet BIDCustomTextField *_emailTF;
    /**
     *验证码
     */
    IBOutlet BIDCustomTextField *_verifyCodeTF;
    IBOutlet UIButton *_verifyCodeBtn;
}

/**
 *原绑定邮箱
 */
@property (copy, nonatomic) NSString *oldEmail;

- (IBAction)verifyCodeBtnHandler:(id)sender;
- (IBAction)confirmBtnHandler:(id)sender;

@end
