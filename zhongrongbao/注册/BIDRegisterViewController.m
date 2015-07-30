//
//  BIDRegisterViewController.m
//  zhongrongbao
//
//  Created by mal on 14-8-18.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDRegisterViewController.h"
#import "BIDDataCommunication.h"
#import "BIDVerifyCodeView.h"
#import "BIDHomePageViewController.h"
#import "BIDLockViewController.h"

/**
 *获取手机验证码
 */
static NSString *strGetPhoneCodeURL = @"sms/phoneCode.shtml";
/**
 *验证手机号是否已注册过
 */
static NSString *strVerifyPhoneNumberURL = @"User/phone.shtml";
/**
 *验证推荐人
 */
static NSString *strVerifyReferrerURL = @"User/recommend.shtml";
/**
 *注册
 */
static NSString *strRegisterURL = @"User/phoneReg.shtml";
/**
 *登录
 */
static NSString *strLoginURL = @"User/login.shtml";

@interface BIDRegisterViewController ()<UIAlertViewDelegate>
{
    NSTimer *_timer;
    int _totalSecond;
}

@end

@implementation BIDRegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"免费注册";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _totalSecond = 60;
    self.navigationController.navigationBarHidden = NO;
    //设置按钮背景图片
    [BIDCommonMethods setImgForBtn:_verificationCodeBtn imgForNormal:@"redBtnBgNormal.png" imgForPress:@"redBtnBgPress.png" inset:UIEdgeInsetsMake(10, 10, 11, 11)];
    [BIDCommonMethods setImgForBtn:_verificationCodeBtn imgName:@"redBtnBgPress.png" state:UIControlStateDisabled inset:UIEdgeInsetsMake(10, 10, 11, 11)];
    [BIDCommonMethods setImgForBtn:_registerBtn imgForNormal:@"redBtnBgNormal.png" imgForPress:@"redBtnBgPress.png" inset:UIEdgeInsetsMake(10, 10, 11, 11)];
    //
    _mobilePhoneNumberTF.inputAccessoryView = self.toolBar;
    _verificationCodeTF.inputAccessoryView = self.toolBar;
    _passwordTF.inputAccessoryView = self.toolBar;
    _referrerTF.inputAccessoryView = self.toolBar;
    //
    UIColor *color = [UIColor colorWithRed:216.0f/255.0f green:217.0f/255.0f blue:217.0f/255.0f alpha:1.0f];
    _mobilePhoneNumberTF.layer.borderWidth = 1;
    _mobilePhoneNumberTF.layer.borderColor = color.CGColor;
    _verificationCodeTF.layer.borderWidth = 1;
    _verificationCodeTF.layer.borderColor = color.CGColor;
    _passwordTF.layer.borderWidth = 1;
    _passwordTF.layer.borderColor = color.CGColor;
    _referrerTF.layer.borderWidth = 1;
    _referrerTF.layer.borderColor = color.CGColor;
}

- (void)didReceiveMemoryWarning
{
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
        [_verificationCodeBtn setEnabled:YES];
        [_verificationCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [_verificationCodeBtn.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    }
    else
    {
        [_verificationCodeBtn setEnabled:NO];
        NSString *str = [[NSString alloc] initWithFormat:@"%d秒后可重新发送", _totalSecond];
        [_verificationCodeBtn setTitle:str forState:UIControlStateDisabled];
        [_verificationCodeBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
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
 *获取验证码
 */
- (IBAction)verificationCodeBtnHandler:(id)sender
{
    NSString *strPhoneNumber = _mobilePhoneNumberTF.text;
    if(strPhoneNumber.length==0)
    {
        [BIDCommonMethods showAlertView:@"手机号不能为空" buttonTitle:@"关闭" delegate:nil tag:0];
    }
    else
    {
        //验证手机号是否已注册过
        __block NSString *strURL = @"";
        NSString *strPost = @"";
        strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strVerifyPhoneNumberURL];
        strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"phone\":\"%@\"}", strPhoneNumber];
        [self.spinnerView showTheView];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSMutableDictionary *responseDictionary = [[NSMutableDictionary alloc] init];
            int rev = [BIDDataCommunication uploadDataByPostToURL:strURL postValue:strPost toDictionary:responseDictionary];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.spinnerView dismissTheView];
                if(rev==1)
                {
                    if([[responseDictionary objectForKey:@"json"] isEqualToString:@"success"])
                    {
                        strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strGetPhoneCodeURL];
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
                    else
                    {
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
}
/**
 *注册
 */
- (IBAction)registerBtnHandler:(id)sender
{
    NSString *strPhoneNumber = _mobilePhoneNumberTF.text;
    NSString *strPhoneCode = _verificationCodeTF.text;
    NSString *strPassword = _passwordTF.text;
    NSString *strRecommendUid = _referrerTF.text;
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strRegisterURL];
    NSString *strPost;
    if(strRecommendUid.length>0)
    {
        strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"phone\":\"%@\", \"phoneCode\":\"%@\", \"pwd\":\"%@\", \"logType\":\"IPHONE\", \"recommendUid\":\"%@\"}", strPhoneNumber, strPhoneCode, strPassword, strRecommendUid];
    }
    else
    {
        strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"phone\":\"%@\", \"phoneCode\":\"%@\", \"pwd\":\"%@\", \"logType\":\"IPHONE\"}", strPhoneNumber, strPhoneCode, strPassword];
    }
    [self.spinnerView showTheView];
    self.spinnerView.content = @"";
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        if(strRecommendUid.length>0 && ![self isReferrerExist])
//        {
//            //推荐人不存在
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.spinnerView dismissTheView];
//                [BIDCommonMethods showAlertView:@"推荐人不存在" buttonTitle:@"关闭" delegate:nil tag:0];
//            });
//        }
//        else
        {
            NSMutableDictionary *responseDictionary = [[NSMutableDictionary alloc] init];
            int rev = [BIDDataCommunication uploadDataByPostToURL:strURL postValue:strPost toDictionary:responseDictionary];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.spinnerView dismissTheView];
                if(rev==1)
                {
                    if([[responseDictionary objectForKey:@"json"] isEqualToString:@"success"])
                    {
                        if(_timer)
                        {
                            [_timer invalidate];
                        }
                        [BIDCommonMethods showAlertView:[responseDictionary objectForKey:@"message"] buttonTitle:@"关闭" delegate:self tag:0];
                    }
                    else
                    {
                        [BIDCommonMethods showAlertView:[responseDictionary objectForKey:@"message"] buttonTitle:@"关闭" delegate:nil tag:0];
                    }
                }
                else
                {
                    [BIDCommonMethods showAlertView:@"注册失败" buttonTitle:@"关闭" delegate:nil tag:0];
                }
            });
        }
    });
}

//验证推荐人是否存在
- (BOOL)isReferrerExist
{
    BOOL bExist = NO;
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strVerifyReferrerURL];
    NSString *strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"recommendUid\":\"%@\"}", _referrerTF.text];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    int rev = [BIDDataCommunication uploadDataByPostToURL:strURL postValue:strPost toDictionary:dictionary];
    if(rev==1)
    {
        if([[dictionary objectForKey:@"json"] isEqualToString:@"success"])
        {
            bExist = YES;
        }
        else
        {
            bExist = NO;
        }
    }
    else
    {
        bExist = NO;
    }
    return bExist;
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //[self.navigationController popViewControllerAnimated:YES];
    //清除cookie
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookieArr = [storage cookies];
    for(id obj in cookieArr)
    {
        [storage deleteCookie:obj];
    }
    //
    //使用刚注册的用户名、密码进行登录
    NSString *strUsername = _mobilePhoneNumberTF.text;
    NSString *strPassword = _passwordTF.text;
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strLoginURL];
    [self.spinnerView showTheView];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *responseDictionary = [[NSMutableDictionary alloc] init];
        NSString *strPostValue = [[NSString alloc] initWithFormat:@"jsonDataSet={\"loginId\":\"%@\", \"pwd\":\"%@\", \"logType\":\"IPHONE\"}", strUsername, strPassword];
        int value = [BIDDataCommunication uploadDataByPostToURL:strURL postValue:strPostValue toDictionary:responseDictionary];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinnerView dismissTheView];
            if(value==1)
            {
                if([[responseDictionary objectForKey:@"json"] isEqualToString:@"success"])
                {
                    //设置登录状态
                    [BIDAppDelegate setLoginFlag];
                    //登录成功,先保存用户名和密码
                    NSDictionary *infoDictionary = @{@"username":strUsername, @"password":strPassword};
                    
                    NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
                    if(urls.count>0)
                    {
                        NSURL *documentURL = urls[0];
                        NSURL *configPath = [documentURL URLByAppendingPathComponent:@"config.plist"];
                        [infoDictionary writeToURL:configPath atomically:YES];
                    }
                    //保存用户id
                    NSDictionary *subDictionary = [responseDictionary objectForKey:@"data"];
                    [BIDAppDelegate setUserId:[subDictionary objectForKey:@"UID"]];
                    //
                    //是否是第一次登录
                    BOOL bFirstLogin = YES;
                    //手势开关
                    int onoff = 1;
                    //手势密码
                    NSString *strGesturePwd = @"";
                    //检索该用户是否登录过
                    NSArray *docsArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *strDocPath = docsArr[0];
                    NSString *strLoginInfoPath = [[NSString alloc] initWithFormat:@"%@", [strDocPath stringByAppendingPathComponent:loginInfoFileName]];
                    if(![[NSFileManager defaultManager] fileExistsAtPath:strLoginInfoPath])
                    {
                        //文件不存在
                        bFirstLogin = YES;
                        NSDictionary *dictionary = @{@"uid":[subDictionary objectForKey:@"UID"], @"username":strUsername, @"gesturePwd":@"", @"flag":@1};
                        NSArray *arr = @[dictionary];
                        [arr writeToFile:strLoginInfoPath atomically:YES];
                    }
                    else
                    {
                        //文件存在,则判断该用户是否是第一次登录
                        NSMutableArray *arr = [[NSMutableArray alloc] initWithContentsOfFile:strLoginInfoPath];
                        for(NSDictionary *dictionary in arr)
                        {
                            if([[dictionary objectForKey:@"uid"] isEqualToString:[subDictionary objectForKey:@"UID"]] || [strUsername isEqualToString:[subDictionary objectForKey:@"username"]])
                            {
                                bFirstLogin = NO;
                                strGesturePwd = [dictionary objectForKey:@"gesturePwd"];
                                NSNumber *value = [dictionary objectForKey:@"flag"];
                                onoff = [value intValue];
                                break;
                            }
                        }
                        if(bFirstLogin)
                        {
                            //是第一次登录
                            NSDictionary *dictionary = @{@"uid":[subDictionary objectForKey:@"UID"], @"username":strUsername, @"gesturePwd":@"", @"flag":@1};
                            [arr addObject:dictionary];
                            [arr writeToFile:strLoginInfoPath atomically:YES];
                        }
                    }
                    //下载头像图片
//                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                        NSMutableData *imgData = [[NSMutableData alloc] init];
//                        [BIDDataCommunication getDataFromNet:[subDictionary objectForKey:@"HEADER_IMG"] data:imgData];
//                        if(imgData)
//                        {
//                            NSFileManager *fileManager = [[NSFileManager alloc] init];
//                            NSArray *urls = [fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];
//                            if(urls.count>0)
//                            {
//                                NSURL *imgPath = [urls[0] URLByAppendingPathComponent:@"portraitImg" isDirectory:YES];
//                                BOOL bSuccess = [fileManager createDirectoryAtURL:imgPath withIntermediateDirectories:YES attributes:nil error:nil];
//                                imgPath = [imgPath URLByAppendingPathComponent:@"portrait.png" isDirectory:NO];
//                                bSuccess = [imgData writeToURL:imgPath atomically:YES];
//                            }
//                        }
//                    });
                    //进入首页
                    //BIDHomePageViewController *vc = [[BIDHomePageViewController alloc] initWithNibName:@"BIDHomePageViewController" bundle:nil];
                    BIDLockViewController *vc = [[BIDLockViewController alloc] initWithNibName:@"BIDLockViewController" bundle:nil];
                    vc.bLogin = YES;
                    [self.navigationController setViewControllers:@[vc]];
                }
                else
                {
                    //登录失败
                    [BIDCommonMethods showAlertView:[responseDictionary objectForKey:@"message"] buttonTitle:@"关闭" delegate:nil tag:0];
                }
            }
            else
            {
                //服务器地址错误或网络无连接
                if(![BIDAppDelegate isNetWorkConnecting])
                {
                    [BIDCommonMethods showAlertView:@"当前网络不可用，请检查网络连接" buttonTitle:@"关闭" delegate:nil tag:0];
                }
                else
                {
                    [BIDCommonMethods showAlertView:@"服务器地址错误，请联系管理员" buttonTitle:@"关闭" delegate:nil tag:0];
                }
            }
        });
    });
}

@end
