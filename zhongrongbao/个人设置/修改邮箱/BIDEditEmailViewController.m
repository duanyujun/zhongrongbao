//
//  BIDEditEmailViewController.m
//  zhongrongbao
//
//  Created by mal on 14-10-5.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDEditEmailViewController.h"
#import "BIDVerifyCodeView.h"
#import "BIDLoginViewController.h"
/**
 *获取验证码
 */
static NSString *strGetVerifyCodeURL = @"UserAccount/sendEmailCodeChange.shtml";
/**
 *绑定邮箱
 */
static NSString *strEditEmailURL = @"UserAccount/emailChangeMes.shtml";
/**
 *验证邮箱是否已经存在
 */
static NSString *strVerifyEmailURL = @"User/email.shtml";

@interface BIDEditEmailViewController ()<UIAlertViewDelegate>
{
    NSTimer *_timer;
    int _totalSecond;
}

@end

@implementation BIDEditEmailViewController
@synthesize oldEmail;

- (void)viewDidLoad {
    [super viewDidLoad];
    _totalSecond = 60;
    self.title = @"修改绑定邮箱";
    UIColor *color = [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0f];
    _emailTF.layer.borderColor = color.CGColor;
    _emailTF.layer.borderWidth = 1.0f;
    _verifyCodeTF.layer.borderColor = color.CGColor;
    _verifyCodeTF.layer.borderWidth = 1.0f;
    
    [BIDCommonMethods setImgForBtn:_verifyCodeBtn imgForNormal:@"redBtnBgNormal.png" imgForPress:@"redBtnBgPress.png" inset:UIEdgeInsetsMake(10, 10, 11, 11)];
    [BIDCommonMethods setImgForBtn:_verifyCodeBtn imgName:@"redBtnBgNormal.png" state:UIControlStateDisabled inset:UIEdgeInsetsMake(10, 10, 11, 11)];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)timerSelect:(NSTimer*)paramTimer
{
    _totalSecond--;
    if(_totalSecond==0)
    {
        _totalSecond = 60;
        [_timer invalidate];
        [_verifyCodeBtn setEnabled:YES];
        [_verifyCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [_verifyCodeBtn.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
        //[_verifyCodeBtn setBackgroundColor:[UIColor colorWithRed:52.0f/255.0f green:152.0f/255.0f blue:219.0f/255.0f alpha:1.0f]];
        [BIDCommonMethods setImgForBtn:_verifyCodeBtn imgForNormal:@"blueBtnBgNormal.png" imgForPress:@"blueBtnBgPress.png" inset:UIEdgeInsetsMake(10, 10, 11, 11)];
    }
    else
    {
        [_verifyCodeBtn setEnabled:NO];
        NSString *str = [[NSString alloc] initWithFormat:@"%d秒后可重新发送", _totalSecond];
        [_verifyCodeBtn setTitle:str forState:UIControlStateDisabled];
        [_verifyCodeBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
        //[_verifyCodeBtn setBackgroundColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [BIDCommonMethods setImgForBtn:_verifyCodeBtn imgForNormal:@"grayBtnBgNormal.png" imgForPress:@"grayBtnBgPress.png" inset:UIEdgeInsetsMake(10, 10, 11, 11)];
    }
}

- (void)backBtnHandler
{
    if(_timer)
    {
        [_timer invalidate];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/**
 *获取验证码
 */
- (IBAction)verifyCodeBtnHandler:(id)sender
{
    if(_emailTF.text.length>0)
    {
        //验证手机号是否已注册过
        __block NSString *strURL = @"";
        __block NSString *strPost = @"";
        strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strVerifyEmailURL];
        strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"email\":\"%@\"}", _emailTF.text];
        self.spinnerView.content = @"";
        [self.spinnerView showTheView];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            int rev = [BIDDataCommunication uploadDataByPostToURL:strURL postValue:strPost toDictionary:dictionary];
            if(rev==1)
            {
                if([[dictionary objectForKey:@"json"] isEqualToString:@"success"])
                {
                    strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strGetVerifyCodeURL];
                    strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"email\":\"%@\"}", _emailTF.text];
                    rev = [BIDDataCommunication uploadDataByPostToURL:strURL postValue:strPost toDictionary:dictionary];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.spinnerView dismissTheView];
                        if(rev==1)
                        {
                            if([[dictionary objectForKey:@"json"] isEqualToString:@"success"])
                            {
                                //显示倒计时
                                _timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(timerSelect:) userInfo:nil repeats:YES];
                                [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
                                //
                                BIDVerifyCodeView *verifyCodeView = (BIDVerifyCodeView*)[[[NSBundle mainBundle] loadNibNamed:@"BIDVerifyCodeView" owner:self options:nil] lastObject];
                                [verifyCodeView showTheView];
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
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.spinnerView dismissTheView];
                        [BIDCommonMethods showAlertView:[dictionary objectForKey:@"message"] buttonTitle:@"关闭" delegate:nil tag:0];
                    });
                }
            }
            else if(rev==0)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.spinnerView dismissTheView];
                    [BIDCommonMethods showAlertView:[dictionary objectForKey:@"请求失败"] buttonTitle:@"关闭" delegate:nil tag:0];
                });
            }
        });
    }
    else
    {
        [BIDCommonMethods showAlertView:@"请输入邮箱地址" buttonTitle:@"关闭" delegate:nil tag:0];
    }
}

- (IBAction)confirmBtnHandler:(id)sender
{
    if(_emailTF.text.length==0 || _verifyCodeTF.text.length==0)
    {
        [BIDCommonMethods showAlertView:@"邮箱或验证码不能为空" buttonTitle:@"关闭" delegate:nil tag:0];
    }
    else
    {
        NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strEditEmailURL];
        NSString *strPost = @"";
        if(oldEmail.length>0)
        {
            strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"email\":\"%@\", \"changeEmail\":\"%@\", \"emailCode\":\"%@\"}", oldEmail, _emailTF.text, _verifyCodeTF.text];
        }
        else
        {
            strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"changeEmail\":\"%@\", \"emailCode\":\"%@\"}", _emailTF.text, _verifyCodeTF.text];

        }
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
                        if(_timer)
                        {
                            [_timer invalidate];
                        }
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
