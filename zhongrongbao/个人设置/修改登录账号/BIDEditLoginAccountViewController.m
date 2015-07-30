//
//  BIDEditLoginAccountViewController.m
//  zhongrongbao
//
//  Created by mal on 14-10-5.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDEditLoginAccountViewController.h"
#import "BIDLoginViewController.h"

/**
 *修改用户登录名
 */
static NSString *strEditLoginAccountURL = @"UserAccount/userIDChange.shtml";

@interface BIDEditLoginAccountViewController ()<UIAlertViewDelegate>

@end

@implementation BIDEditLoginAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"修改登录账号";
    _loginAccountTF.layer.borderColor = [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0f].CGColor;
    _loginAccountTF.layer.borderWidth = 1.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)confirmBtnHandler:(id)sender
{
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strEditLoginAccountURL];
    NSString *strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"userId\":\"%@\"}", _loginAccountTF.text];
    self.spinnerView.content = @"正在提交..";
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
                    NSString *configPath = [BIDCommonMethods getConfigPath];
                    NSMutableDictionary *configInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:configPath];
                    [configInfo setObject:_loginAccountTF.text forKey:@"username"];
                    [configInfo writeToFile:configPath atomically:YES];
                    [BIDCommonMethods showAlertView:[dictionary objectForKey:@"message"] buttonTitle:@"关闭" delegate:self tag:0];
                }
                else
                {
                    [BIDCommonMethods showAlertView:[dictionary objectForKey:@"message"] buttonTitle:@"关闭" delegate:nil tag:0];
                }
            }
            else if(rev==2)
            {
                [BIDCommonMethods showAlertView:err_msg buttonTitle:@"关闭" delegate:self tag:2];
            }
            else
            {
                [BIDCommonMethods showAlertView:@"请求失败" buttonTitle:@"关闭" delegate:nil tag:0];
            }
        });
    });
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(alertView.tag==2)
    {
        //登录
        BIDLoginViewController *vc;
        if(IPHONE4OR4S)
        {
            vc = [[BIDLoginViewController alloc] initWithNibName:@"BIDLoginViewController" bundle:nil];
        }
        else
        {
            vc = [[BIDLoginViewController alloc] initWithNibName:@"BIDLoginViewController2" bundle:nil];
        }
        vc.bRequestException = YES;
        [self.navigationController setViewControllers:@[vc] animated:YES];
    }
}

@end
