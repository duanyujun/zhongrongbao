//
//  BIDEditLoginAccountViewController.h
//  zhongrongbao
//
//  Created by mal on 14-10-5.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDBaseViewController.h"
#import "BIDCustomTextField.h"

@interface BIDEditLoginAccountViewController : BIDBaseViewController
{
    /**
     *新的登录账号
     */
    IBOutlet BIDCustomTextField *_loginAccountTF;
}

- (IBAction)confirmBtnHandler:(id)sender;

@end
