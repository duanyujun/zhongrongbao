//
//  BIDEditMobilePhoneNumberViewController.m
//  zhongrongbao
//
//  Created by mal on 14-10-2.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDEditMobilePhoneNumberViewController.h"
#import "BIDVerifyCodeView.h"
#import "BIDLoginViewController.h"
/**
 *修改手机号码
 */
static NSString *strEditMobilePhoneNumberURL = @"UserAccount/phoneChangeMes.shtml";
/**
 *获取手机验证码
 */
static NSString *strGetPhoneCodeURL = @"sms/phoneCode.shtml";
/**
 *验证手机号是否已经存在
 */
static NSString *strVerifyPhoneNumberURL = @"User/phone.shtml";

@interface BIDEditMobilePhoneNumberViewController ()<UIAlertViewDelegate>
{
    NSTimer *_timer;
    int _totalSecond;
}

@end

@implementation BIDEditMobilePhoneNumberViewController
@synthesize oldBindingMobilePhoneNumber;
@synthesize bindingMobilePhoneNumber;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _totalSecond = 60;
    self.title = @"绑定手机";
    [BIDCommonMethods setImgForBtn:_verifyCodeBtn imgForNormal:@"grayBtnBgPress.png" imgForPress:@"grayBtnBgNormal.png" inset:UIEdgeInsetsMake(10, 10, 11, 11)];
    [BIDCommonMethods setImgForBtn:_verifyCodeBtn imgName:@"grayBtnBgPress.png" state:UIControlStateDisabled inset:UIEdgeInsetsMake(10, 10, 11, 11)];
    _verifyCodeTF.inputAccessoryView = self.toolBar;
    //发送手机验证码
    [self sendVerifyCode];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _newMobilePhoneNumberLabel.text = self.bindingMobilePhoneNumber;
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
    }
    else
    {
        [_verifyCodeBtn setEnabled:NO];
        NSString *str = [[NSString alloc] initWithFormat:@"%d秒后可重新获取", _totalSecond];
        [_verifyCodeBtn setTitle:str forState:UIControlStateDisabled];
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

/**
 *发送手机验证码
 */
- (void)sendVerifyCode
{
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strGetPhoneCodeURL];
    NSString *strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"phone\":\"%@\"}", bindingMobilePhoneNumber];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        int rev = [BIDDataCommunication uploadDataByPostToURL:strURL postValue:strPost toDictionary:dictionary];
        dispatch_async(dispatch_get_main_queue(), ^{
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

- (IBAction)getVerifyCodeBtnHandler:(id)sender
{
    [self sendVerifyCode];
}

/**
 *绑定新的手机号
 */
- (IBAction)bindingNewMobilePhoneNumberBtnHandler:(id)sender
{
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strEditMobilePhoneNumberURL];
    NSString *strVerifyCode = _verifyCodeTF.text;
    NSString *strMobilePhoneNumber = bindingMobilePhoneNumber;
    NSString *strPost = @"";
    if(oldBindingMobilePhoneNumber.length>0)
    {
        strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"phone\":\"%@\", \"changePhone\":\"%@\", \"phoneCode\":\"%@\"}", oldBindingMobilePhoneNumber, strMobilePhoneNumber, strVerifyCode];
    }
    else
    {
        strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"changePhone\":\"%@\", \"phoneCode\":\"%@\"}", strMobilePhoneNumber, strVerifyCode];
    }
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
                    //修改成功，根据之前的登录用户名类型来判断是否需要更改配置文件
                    NSString *configPath = [BIDCommonMethods getConfigPath];
                    NSMutableDictionary *configInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:configPath];
                    //if([[configInfo objectForKey:@"type"] isEqualToString:@"phone"])
                    {
                        [configInfo setObject:strMobilePhoneNumber forKey:@"username"];
                        [configInfo writeToFile:configPath atomically:YES];
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
