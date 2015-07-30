//
//  BIDSetPasswordViewController.h
//  shangwuting
//
//  Created by mal on 14-1-2.
//  Copyright (c) 2014年 mal. All rights reserved.
//

#import "BIDBaseViewController.h"

@interface BIDSetPasswordViewController : BIDBaseViewController<UITextFieldDelegate, UIAlertViewDelegate>

@property (strong, nonatomic)IBOutlet UITextField *oldPasswordTF;
@property (strong, nonatomic)IBOutlet UITextField *firstPasswordTF;
@property (strong, nonatomic)IBOutlet UITextField *secondPasswordTF;
@property (strong, nonatomic)IBOutlet UIButton *confirmBtn;

@property (strong, nonatomic)IBOutlet UILabel *label1;
@property (strong, nonatomic)IBOutlet UILabel *label2;
@property (strong, nonatomic)IBOutlet UILabel *label3;
//密码规则
@property (strong, nonatomic)IBOutlet UILabel *label4;

@property (assign, nonatomic)BOOL bOldPasswordWrong;
@property (assign, nonatomic)BOOL bFirstPasswordWrong;
@property (assign, nonatomic)BOOL bSecondPasswordWrong;

- (IBAction)confirmBtnHandler:(id)sender;

@end
