//
//  BIDResetPasswordViewController.m
//  zhongrongbao
//
//  Created by mal on 15/7/4.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import "BIDResetPasswordViewController.h"
#import "BIDCustomTextField.h"
#import "BIDVerifyCodeView.h"

/**
 *获取手机验证码
 */
static NSString *strGetPhoneCodeURL = @"sms/phoneCode.shtml";
/**
 *验证手机号是否存在
 */
static NSString *strVerifyPhoneNumberURL = @"User/CheckPhone.shtml";

@interface BIDResetPasswordViewController ()
{
    NSTimer *_timer;
    int _totalSecond;
}
@end

@implementation BIDResetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"重设密码";
    _totalSecond = 60;
    self.navigationController.navigationBarHidden = NO;
    //
    _pwdTF.inputAccessoryView = self.toolBar;
    _pwdAgainTF.inputAccessoryView = self.toolBar;
    _verifyCodeTF.inputAccessoryView = self.toolBar;
    _mobilePhoneTF.inputAccessoryView = self.toolBar;
    
    [BIDCommonMethods setImgForBtn:_verifyCodeBtn imgForNormal:@"redBtnBgNormal.png" imgForPress:@"redBtnBgPress.png" inset:UIEdgeInsetsMake(10, 10, 11, 11)];
    [BIDCommonMethods setImgForBtn:_verifyCodeBtn imgName:@"redBtnBgPress.png" state:UIControlStateDisabled inset:UIEdgeInsetsMake(10, 10, 11, 11)];
    [BIDCommonMethods setImgForBtn:_setBtn imgForNormal:@"redBtnBgNormal.png" imgForPress:@"redBtnBgPress.png" inset:UIEdgeInsetsMake(10, 10, 11, 11)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//获取手机验证码
- (IBAction)verifyCodeBtnHandler:(id)sender
{
    NSString *strPhoneNumber = _mobilePhoneTF.text;
    if(strPhoneNumber.length==0)
    {
        [BIDCommonMethods showAlertView:@"手机号不能为空" buttonTitle:@"关闭" delegate:nil tag:0];
    }
    else if(![BIDCommonMethods isMobilePhoneNumberHaveCorrectFormat:strPhoneNumber])
    {
        [BIDCommonMethods showAlertView:@"手机号格式不正确" buttonTitle:@"关闭" delegate:nil tag:0];
    }
    else
    {
        __block NSString *strURL = @"";
        NSString *strPost = @"";
        strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strVerifyPhoneNumberURL];
        strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"phone\":\"%@\"}", strPhoneNumber];
        [self.spinnerView showTheView];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSMutableDictionary *responseDic = [[NSMutableDictionary alloc] init];
            int rev = [BIDDataCommunication uploadDataByPostToURL:strURL postValue:strPost toDictionary:responseDic];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.spinnerView dismissTheView];
                if(rev==1)
                {
                    if([[responseDic objectForKey:@"json"] isEqualToString:@"success"])
                    {
                        //手机号存在，可以发送验证码
                        [self sendVerifyCode:strPhoneNumber];
                    }
                    else
                    {
                        [BIDCommonMethods showAlertView:[responseDic objectForKey:@"message"] buttonTitle:@"关闭" delegate:nil tag:0];
                    }
                }
                else
                {
                    [BIDCommonMethods showAlertView:@"请求失败" buttonTitle:@"关闭" delegate:nil tag:0];
                }
            });
        });
    }
}
//发送验证码
- (void)sendVerifyCode:(NSString*)strPhoneNumber
{
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strGetPhoneCodeURL];
    NSString *strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"phone\":\"%@\"}", strPhoneNumber];
    [self.spinnerView showTheView];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *responseDictionary  = [[NSMutableDictionary alloc] init];
        int rev = [BIDDataCommunication uploadDataByPostToURL:strURL postValue:strPost toDictionary:responseDictionary];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinnerView dismissTheView];
            if(rev==1)
            {
                if([[responseDictionary objectForKey:@"json"] isEqualToString:@"success"])
                {
                    //显示倒计时
                    _timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(timerSelect:) userInfo:nil repeats:YES];
                    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
                    //获取验证码成功
                    BIDVerifyCodeView *verifyCodeView = (BIDVerifyCodeView*)[[[NSBundle mainBundle] loadNibNamed:@"BIDVerifyCodeView" owner:self options:nil] lastObject];
                    [verifyCodeView showTheView];
                }
                else
                {
                    //获取验证码失败
                    [BIDCommonMethods showAlertView:[responseDictionary objectForKey:@"message"] buttonTitle:@"关闭" delegate:nil tag:0];
                }
            }
            else
            {
                [BIDCommonMethods showAlertView:@"请求失败" buttonTitle:@"关闭" delegate:nil tag:0];
            }
        });
    });
}
//设置新的密码
- (IBAction)setBtnHandler:(id)sender
{
    if(_verifyCodeTF.text.length==0)
    {
        [BIDCommonMethods showAlertView:@"请先获取验证码" buttonTitle:@"关闭" delegate:nil tag:0];
        return;
    }
    if(_pwdTF.text.length==0)
    {
        [BIDCommonMethods showAlertView:@"新密码不能为空" buttonTitle:@"关闭" delegate:nil tag:0];
        return;
    }
    if(_pwdAgainTF.text.length==0)
    {
        [BIDCommonMethods showAlertView:@"请再次输入新密码" buttonTitle:@"关闭" delegate:nil tag:0];
        return;
    }
    if([_pwdTF.text isEqualToString:_pwdAgainTF.text])
    {
        [BIDCommonMethods showAlertView:@"两次输入的密码不一致" buttonTitle:@"关闭" delegate:nil tag:0];
        return;
    }
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
        //[_verifyCodeBtn.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    }
    else
    {
        [_verifyCodeBtn setEnabled:NO];
        NSString *str = [[NSString alloc] initWithFormat:@"%d秒后可重新发送", _totalSecond];
        [_verifyCodeBtn setTitle:str forState:UIControlStateDisabled];
        //[_verificationCodeBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
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

@end
