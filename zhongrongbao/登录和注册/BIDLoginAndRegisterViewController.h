//
//  BIDLoginAndRegisterViewController.h
//  zhongrongbao
//
//  Created by mal on 14-8-13.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIDLoginAndRegisterViewController : UIViewController
{
    IBOutlet UIImageView *_imgView;
    IBOutlet UIButton *_loginBtn;
    IBOutlet UIButton *_registerBtn;
}

- (IBAction)loginBtnHandler:(id)sender;
- (IBAction)registerBtnHandler:(id)sender;

@end
