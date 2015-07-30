//
//  BIDGestureToUnlockViewController.m
//  zhongrongbao
//
//  Created by mal on 14-9-15.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDGestureToUnlockViewController.h"
#import "BIDLockViewForLogin.h"
#import "BIDCommonMethods.h"
#import "BIDLoginViewController.h"
#import "BIDManagerInNavViewController.h"

/**
 *退出登录
 */
static NSString *strQuitURL = @"User/logQuit.shtml";

@interface BIDGestureToUnlockViewController ()<BIDLockViewForLoginDelegate>
{
    BIDLockViewForLogin *_lockViewForLogin;
}

@end

@implementation BIDGestureToUnlockViewController
@synthesize bToHomePage;
@synthesize navController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"gestureBg.png"]]];
    self.navigationController.navigationBarHidden = YES;
    _lockViewForLogin = [[BIDLockViewForLogin alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_hintLabel.frame)+35, CGRectGetWidth(self.view.frame), 300)];
    _lockViewForLogin.delegate = self;
    [self.view addSubview:_lockViewForLogin];
    //
    CGRect btnFrame = _forgetGesturePasswordBtn.frame;
    btnFrame.origin.y = [UIScreen mainScreen].bounds.size.height - 20 - CGRectGetHeight(btnFrame);
    _forgetGesturePasswordBtn.frame = btnFrame;
    //
    btnFrame = _changeAccountBtn.frame;
    btnFrame.origin.y = [UIScreen mainScreen].bounds.size.height - 20 - CGRectGetHeight(btnFrame);
    _changeAccountBtn.frame = btnFrame;
    //
    NSString *configPath = [BIDCommonMethods getConfigPath];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:configPath];
    _welcomeLabel.text = [[NSString alloc] initWithFormat:@"Hi,%@", [dictionary objectForKey:@"username"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/**
 *忘记手势密码，则直接跳转到登录界面
 */
- (IBAction)forgetGesturePasswordBtnHandler:(id)sender
{
    //需要清除2个配置文件里的手势密码关键字对应的值"config.plist","loginInfoFileName.plist"
    NSString *configPath = [BIDCommonMethods getConfigPath];
    NSDictionary *dictionary = @{@"username":@"", @"password":@"", @"gesturePassword":@"", @"gesturePasswordState":@1};
    [dictionary writeToFile:configPath atomically:YES];
    //清除loginInfoFileName对应的配置文件里的手势密码的值2015-4-21
    NSArray *urls = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if(urls.count>0)
    {
        NSString *documentPath = urls[0];
        NSString *strLoginInfoPath = [[NSString alloc] initWithFormat:@"%@", [documentPath stringByAppendingPathComponent:loginInfoFileName]];
        if([[NSFileManager defaultManager] fileExistsAtPath:strLoginInfoPath])
        {
            NSMutableArray *arr = [[NSMutableArray alloc] initWithContentsOfFile:strLoginInfoPath];
            NSString *strUserId = [BIDAppDelegate getUserId];
            for(int i=0; i<arr.count; i++)
            {
                NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:arr[i]];
                if([[dictionary objectForKey:@"uid"] isEqualToString:strUserId])
                {
                    [dictionary setValue:@"" forKey:@"gesturePwd"];
                    [arr replaceObjectAtIndex:i withObject:dictionary];
                    [arr writeToFile:strLoginInfoPath atomically:YES];
                    break;
                }
            }
        }
    }
    //清除cookie
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookieArr = [storage cookies];
    for(id obj in cookieArr)
    {
        [storage deleteCookie:obj];
    }
    //
    
    BIDLoginViewController *loginVC;
    if([UIScreen mainScreen].bounds.size.height>=568.0f)
    {
        loginVC = [[BIDLoginViewController alloc] initWithNibName:@"BIDLoginViewController" bundle:nil];
    }
    else
    {
        loginVC = [[BIDLoginViewController alloc] initWithNibName:@"BIDLoginViewController320x480" bundle:nil];
    }
    loginVC.bRequestException = YES;
    if(bToHomePage)
    {
        //刚开始进入应用时
        [self.navigationController setViewControllers:@[loginVC]];
    }
    else
    {
        if(self.navController.view.frame.origin.x>0)
        {
            CGRect navFrame = self.navController.view.frame;
            navFrame.origin.x = 0;
            self.navController.view.frame = navFrame;
        }
        //中途切出去，再次进入应用时
        [self dismissViewControllerAnimated:YES completion:^{}];
        //
        [self.navController setViewControllers:@[loginVC]];
    }
}
/**
 *切换账户
 */
- (IBAction)changeAccountBtnHandler:(id)sender
{
    NSString *configPath = [BIDCommonMethods getConfigPath];
    NSDictionary *dictionary = @{@"username":@"", @"password":@"", @"gesturePassword":@"", @"gesturePasswordState":@1};
    [dictionary writeToFile:configPath atomically:YES];

    //清除cookie
//    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    NSArray *cookieArr = [storage cookies];
//    for(id obj in cookieArr)
//    {
//        [storage deleteCookie:obj];
//    }
    //
    BIDLoginViewController *loginVC;
    if([UIScreen mainScreen].bounds.size.height>=568.0f)
    {
        loginVC = [[BIDLoginViewController alloc] initWithNibName:@"BIDLoginViewController" bundle:nil];
    }
    else
    {
        loginVC = [[BIDLoginViewController alloc] initWithNibName:@"BIDLoginViewController320x480" bundle:nil];
    }
    loginVC.bRequestException = YES;
    if(bToHomePage)
    {
        [self.navigationController setViewControllers:@[loginVC]];
    }
    else
    {
        if(self.navController.view.frame.origin.x>0)
        {
            CGRect navFrame = self.navController.view.frame;
            navFrame.origin.x = 0;
            self.navController.view.frame = navFrame;
        }
        //
        [self dismissViewControllerAnimated:YES completion:^{}];
        //
        [self.navController setViewControllers:@[loginVC]];
    }
}

#pragma mark BIDLockViewForLoginDelegate
- (void)gestureUnlockSuccess
{
    if(bToHomePage)
    {
        //进入首页
        //BIDManagerInNavViewController *managerVC = [[BIDManagerInNavViewController alloc] init];
        //[self.navigationController pushViewController:managerVC animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:^{}];
    }
}

- (void)gestureUnlockFailed:(int)failedTimes
{
    if(failedTimes<5)
    {
        int count = 5 - failedTimes;
        _hintLabel.text =  [[NSString alloc] initWithFormat:@"密码错误,还有%d次机会", count];
        [_hintLabel setTextColor:[UIColor redColor]];
    }
    else
    {
        //回到登录界面
        [self forgetGesturePasswordBtnHandler:nil];
    }
}

@end
