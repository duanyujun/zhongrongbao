//
//  BIDLoginViewController.m
//  mashangban
//
//  Created by mal on 14-7-23.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDLoginViewController.h"
#import "BIDRegisterViewController.h"
#import "BIDResetPasswordViewController.h"
#import "BIDSendData.h"
#import "BIDDataCommunication.h"
#import "BIDCommonMethods.h"
#import "BIDHomePageViewController.h"
#import "BIDManagerInNavViewController.h"
#import "BIDLockViewController.h"
#import <sqlite3.h>
#import "APService.h"

static NSString *strLoginURL = @"User/login.shtml";

@interface BIDLoginViewController ()

@end

@implementation BIDLoginViewController
@synthesize bRequestException;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"登录";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self initLayout];
    //self.navigationItem.leftBarButtonItem = nil;
    //设置navigationItem的titleView
    UILabel *navLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    [navLabel setText:@"登录"];
    [navLabel setTextColor:[UIColor whiteColor]];
    [navLabel setTextAlignment:NSTextAlignmentCenter];
    [navLabel setFont:[UIFont systemFontOfSize:22.0f]];
    self.navigationItem.titleView = navLabel;
    //
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 45)];
    label1.textColor = [UIColor colorWithRed:178.0f/255.0f green:178.0f/255.0f blue:178.0f/255.0f alpha:1.0f];
    label1.font = [UIFont systemFontOfSize:15.0f];
    label1.text = @"手机号";
    //_usernameTF.leftView = label1;
    //_usernameTF.leftViewMode = UITextFieldViewModeAlways;
    _usernameTF.inputAccessoryView = self.toolBar;
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 45)];
    label2.textColor = [UIColor colorWithRed:178.0f/255.0f green:178.0f/255.0f blue:178.0f/255.0f alpha:1.0f];
    label2.font = [UIFont systemFontOfSize:15.0f];
    label2.text = @"密码";
    //_passwordTF.leftView = label2;
    //_passwordTF.leftViewMode = UITextFieldViewModeAlways;
    _passwordTF.inputAccessoryView = self.toolBar;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.navigationItem.hidesBackButton = YES;
//    if(bRequestException)
//    {
//        self.navigationItem.leftBarButtonItem = nil;
//    }
}

- (void)initLayout
{
    //设置view的背景色
    [self.view setBackgroundColor:[UIColor colorWithRed:43.0f/255.0f green:62.0f/255.0f blue:78.0f/255.0f alpha:1.0f]];
    //设置按钮背景色
    UIImage *normalImg = [UIImage imageNamed:@"redBtnBgNormal.png"];
    UIImage *stretchNormalImg = [normalImg resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 11, 11)];
    [_loginBtn setBackgroundImage:stretchNormalImg forState:UIControlStateNormal];
    UIImage *pressImg = [UIImage imageNamed:@"redBtnBgPress.png"];
    UIImage *stretchPressImg = [pressImg resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 11, 11)];
    [_loginBtn setBackgroundImage:stretchPressImg forState:UIControlStateHighlighted];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//获取用户名和密码
- (void)getUserInfo
{
    //NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSArray *urls = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if(urls.count>0)
    {
        NSString *documentPath = urls[0];
        NSString *configPath = [documentPath stringByAppendingPathComponent:@"config.plist"];
        if([[NSFileManager defaultManager] fileExistsAtPath:configPath])
        {
            //文件已经存在,则读取文件信息
            NSDictionary *infoDictionary = [[NSDictionary alloc] initWithContentsOfFile:configPath];
            NSString *strUsername = [infoDictionary objectForKey:@"username"];
            NSString *strPassword = [infoDictionary objectForKey:@"password"];
            _usernameTF.text = strUsername;
            _passwordTF.text = strPassword;
        }
        else
        {
        }
    }
}

- (void)textFieldEditDone:(UITextField *)textField
{
    [textField resignFirstResponder];
}

-(void)tagsAliasCallback:(int)iResCode tags:(NSSet*)tags alias:(NSString*)alias
{
    NSLog(@"%d", iResCode);
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.keyboardHeight = keyboardSize.height;
    
    //NSValue *durationValue = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIView *firstResponderView = [keyWindow findFirstResponder];
    
    if(CGRectGetMinY(_containerView.frame) + firstResponderView.frame.origin.y + firstResponderView.frame.size.height > (self.view.frame.size.height-(self.keyboardHeight-self.distanceToMove)))
    {
        //NSTimeInterval timeInterval;
        //[durationValue getValue:&timeInterval];
        [UIView beginAnimations:@"animation" context:nil];
        [UIView setAnimationDuration:0.25f];
        CGRect frame = self.view.frame;
        
        int moveLen = CGRectGetMinY(_containerView.frame) + firstResponderView.frame.origin.y + firstResponderView.frame.size.height - (self.view.frame.size.height-(self.keyboardHeight-self.distanceToMove));
        self.distanceToMove += moveLen;
        frame.origin.y -= moveLen;
        self.view.frame = frame;
        [UIView commitAnimations];
    }
}

//登录
- (IBAction)loginBtnHandler:(id)sender
{
    //
    NSString *strUsername = _usernameTF.text;
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
                    //保存用户id
                    NSDictionary *subDictionary = [responseDictionary objectForKey:@"data"];
                    [BIDAppDelegate setUserId:[subDictionary objectForKey:@"UID"]];
                    //获取静态图片下载地址
                    [BIDAppDelegate setStaticImgServer:[subDictionary objectForKey:@"IMG_STATIC_SERVER"]];
                    //为jpush设置用户别名
                    [APService setAlias:[subDictionary objectForKey:@"UID"] callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:self];
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
                    //登录成功,保存用户名、密码、手势密码、手势开关状态
                    NSNumber *flagValue = [NSNumber numberWithInt:onoff];
                    /**2015-3-2*/
                    //userID,保存推送消息的时候会用到
                    NSString *strUserID = [subDictionary objectForKey:@"UID"];
                    NSDictionary *infoDictionary = @{@"username":strUsername, @"password":strPassword, @"gesturePassword":strGesturePwd, @"gesturePasswordState":flagValue, @"uid":strUserID};
                    /**2015-3-2*/
                    
                    NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
                    if(urls.count>0)
                    {
                        NSURL *documentURL = urls[0];
                        NSURL *configPath = [documentURL URLByAppendingPathComponent:@"config.plist"];
                        [infoDictionary writeToURL:configPath atomically:YES];
                    }
                    
                    //下载头像图片
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        NSMutableData *imgData = [[NSMutableData alloc] init];
                        NSString *strBasePath = [subDictionary objectForKey:@"BATH_PATH"];
                        NSString *strDynamicSizePath = [subDictionary objectForKey:@"IMG_SIZE_SERVER"];
                        NSString *strPicName = [subDictionary objectForKey:@"HEADER_IMG"];
                        NSString *strCompleteURL = [[NSString alloc] initWithFormat:@"%@%@?240-240", strDynamicSizePath, strPicName];
                        //设置服务器图片地址
                        [BIDAppDelegate setRefererAddr:strBasePath];
                        [BIDAppDelegate setImgServerAddr:strDynamicSizePath];
                        //
                        int rev = 0;
                        int times = 0;
                        NSURL *imgPath;
                        NSFileManager *fileManager = [[NSFileManager alloc] init];
                        NSArray *urls = [fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];
                        if(urls.count>0)
                        {
                            imgPath = [urls[0] URLByAppendingPathComponent:@"portraitImg" isDirectory:YES];
                            [fileManager createDirectoryAtURL:imgPath withIntermediateDirectories:YES attributes:nil error:nil];
                            imgPath = [imgPath URLByAppendingPathComponent:@"portrait.png" isDirectory:NO];
                        }
                        do
                        {
                            times++;
                            rev = [BIDDataCommunication getDataFromNet:strCompleteURL data:imgData];
                            if(rev==1 && imgData.length>0)
                            {
                                [imgData writeToURL:imgPath atomically:YES];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_PORTRAIT_EVENT object:self];
                                });
                            }
                            else
                            {
                                //头像下载失败，则移除本地已存在的同名文件
                                [fileManager removeItemAtURL:imgPath error:nil];
                            }
                        }while(rev==0 && times<5);
                    });
                    if(bFirstLogin)
                    {
                        //第一次登录需要提示设置手势密码
                        BIDLockViewController *lockVC = [[BIDLockViewController alloc] initWithNibName:@"BIDLockViewController" bundle:nil];
                        lockVC.bLogin = YES;
                        [self.navigationController setViewControllers:@[lockVC]];
                    }
                    else
                    {
                        //不是第一次登录则直接进入首页
                        BIDManagerInNavViewController *managerVC = [[BIDManagerInNavViewController alloc] init];
                        [self.navigationController setViewControllers:@[managerVC]];
                    }
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
                    [BIDCommonMethods showAlertView:@"请求失败，请联系管理员" buttonTitle:@"关闭" delegate:nil tag:0];
                }
            }
        });
    });
}

//注册
- (IBAction)registerBtnHandler:(id)sender
{
    BIDRegisterViewController *vc = [[BIDRegisterViewController alloc] initWithNibName:@"BIDRegisterViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

//忘记密码
- (IBAction)resetPasswordBtnHandler:(id)sender
{
    BIDResetPasswordViewController *vc = [[BIDResetPasswordViewController alloc] initWithNibName:@"BIDResetPasswordViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
