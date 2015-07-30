//
//  BIDEditMobilePhoneNumberFirstStepViewController.m
//  zhongrongbao
//
//  Created by mal on 15/6/28.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import "BIDEditMobilePhoneNumberFirstStepViewController.h"
#import "BIDEditMobilePhoneNumberViewController.h"

/**
 *验证手机号是否已经存在
 */
static NSString *strVerifyPhoneNumberURL = @"User/phone.shtml";

@interface BIDEditMobilePhoneNumberFirstStepViewController ()

@end

@implementation BIDEditMobilePhoneNumberFirstStepViewController
@synthesize oldBindingMobilePhoneNumber;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"绑定手机";
    _mobilePhoneNumberTF.inputAccessoryView = self.toolBar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)nextStep:(id)sender
{
    //
    NSString *strMobilePhoneNumber = _mobilePhoneNumberTF.text;
    if(strMobilePhoneNumber.length>0)
    {
        if([BIDCommonMethods isMobilePhoneNumberHaveCorrectFormat:strMobilePhoneNumber])
        {
            //验证手机号是否已注册过
            __block NSString *strURL = @"";
            __block NSString *strPost = @"";
            strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strVerifyPhoneNumberURL];
            strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"phone\":\"%@\"}", strMobilePhoneNumber];
            [self.spinnerView showTheView];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
                int rev = [BIDDataCommunication uploadDataByPostToURL:strURL postValue:strPost toDictionary:dictionary];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.spinnerView dismissTheView];
                    if(rev==1)
                    {
                        if([[dictionary objectForKey:@"json"] isEqualToString:@"success"])
                        {
                            //手机号验证通过，进入下一个界面
                            BIDEditMobilePhoneNumberViewController *vc = [[BIDEditMobilePhoneNumberViewController alloc] initWithNibName:@"BIDEditMobilePhoneNumberViewController" bundle:nil];
                            vc.oldBindingMobilePhoneNumber = self.oldBindingMobilePhoneNumber;
                            vc.bindingMobilePhoneNumber = _mobilePhoneNumberTF.text;
                            [self.navigationController pushViewController:vc animated:YES];
                        }
                        else
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.spinnerView dismissTheView];
                                [BIDCommonMethods showAlertView:[dictionary objectForKey:@"message"] buttonTitle:@"关闭" delegate:nil tag:0];
                            });
                        }
                    }
                    else
                    {
                        [BIDCommonMethods showAlertView:@"请求失败" buttonTitle:@"关闭" delegate:nil tag:0];
                    }
                });
            });
        }
        else
        {
            [BIDCommonMethods showAlertView:@"手机号格式不正确" buttonTitle:@"关闭" delegate:nil tag:0];
        }
    }
    else
    {
        [BIDCommonMethods showAlertView:@"手机号不能为空" buttonTitle:@"关闭" delegate:nil tag:0];
    }
}

@end
