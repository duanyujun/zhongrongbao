//
//  BIDRootManagerViewController.m
//  zhongrongbao
//
//  Created by mal on 14-8-20.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDRootManagerViewController.h"
#import "BIDFunctionListViewController.h"
#import "BIDAppDelegate.h"
#import "BIDLoginAndRegisterViewController.h"
#import "BIDLoginViewController.h"
#import "BIDRegisterViewController.h"
#import "BIDRechargeAndWithdrawalViewController.h"
#import "BIDManagerInNavViewController.h"
#import "BIDGestureToUnlockViewController.h"
#import "BIDHomePageViewController.h"
#import "BIDCustomSpinnerView.h"
#import "BIDGuideViewController.h"
#import "APService.h"
/**
 *动态获取服务器地址(www.zrbao.com/test.zrbao.net)
 */
static NSString *strGetTrueServerAddrURL = @"http://www.zrbao.com/zrbaoSecurity";
/**
 *登录url
 */
static NSString *strLoginURL = @"User/login.shtml";

@interface BIDRootManagerViewController ()<BIDFunctionListViewControllerDelegate>
{
    BIDCustomSpinnerView *_spinnerView;
}
@end

@implementation BIDRootManagerViewController
@synthesize functionListVC;
@synthesize navController;
@synthesize bFunctionListShow;

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
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f]];
    _spinnerView = [[BIDCustomSpinnerView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    [_spinnerView initLayout];
    //动态获得服务器地址
    BOOL bGet = YES;
    NSMutableDictionary *responseDictionary = [[NSMutableDictionary alloc] init];
    //方便测试时使用，可在设置中修改服务器地址
    NSDictionary *preDefaults = @{@"SERVER_ADDR":@"test.zrbao.net"};
    [[NSUserDefaults standardUserDefaults] registerDefaults:preDefaults];
    NSUserDefaults *userDefualt = [NSUserDefaults standardUserDefaults];
    strGetTrueServerAddrURL = [[NSString alloc] initWithFormat:@"http://%@/zrbaoSecurity", [userDefualt objectForKey:@"SERVER_ADDR"]];
    //
    int rev = [BIDDataCommunication getDataFromNet:strGetTrueServerAddrURL toDictionary:responseDictionary];
    if(rev==1)
    {
        if([[responseDictionary objectForKey:@"json"] isEqualToString:@"success"])
        {
            bGet = YES;
            NSDictionary *sub1 = [responseDictionary objectForKey:@"data"];
            NSString *strServerAddr = [sub1 objectForKey:@"securityHttp"];
            [BIDAppDelegate setServerAddr:strServerAddr];
            [BIDAppDelegate SERVER_ADDR:[sub1 objectForKey:@"dataFunServer"]];
        }
        else
        {
            bGet = NO;
        }
    }
    else
    {
        bGet = NO;
    }
    if(bGet)
    {
        //添加侧边栏功能列表
        functionListVC = [[BIDFunctionListViewController alloc] initWithNibName:@"BIDFunctionListViewController" bundle:nil];
        functionListVC.delegate = self;
        [functionListVC setTotalIncome:@"总收益:0元"];
        [functionListVC setTotalAsset:@"总资产:0元"];
        [self.view addSubview:functionListVC.view];
        [self.view sendSubviewToBack:functionListVC.view];
        [self addChildViewController:functionListVC];
        [functionListVC didMoveToParentViewController:self];
        //创建导航视图
        [self initRootViewController];
        [self.view addSubview:navController.view];
        [self addChildViewController:navController];
        [navController didMoveToParentViewController:self];
    }
    else
    {
        [BIDCommonMethods showAlertView:@"服务器地址获取失败,请稍候重试" buttonTitle:@"关闭" delegate:nil tag:0];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    static BOOL bShow = NO;
    if([BIDAppDelegate isShowGuide] && !bShow)
    {
        BIDGuideViewController *guideVC = [[BIDGuideViewController alloc] initWithNibName:@"BIDGuideViewController" bundle:nil];
        [self.navController pushViewController:guideVC animated:NO];
        bShow = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initRootViewController
{
    //直接进入首页
//    BIDManagerInNavViewController *managerVC = [[BIDManagerInNavViewController alloc] init];
//    navController = [[UINavigationController alloc] initWithRootViewController:managerVC];
//    //为导航栏设置背景图片
//    [self.navController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBarBg.png"] forBarMetrics:UIBarMetricsDefault];
//    [self.navController.navigationBar setTintColor:[UIColor whiteColor]];
//    self.navController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:20.0f], NSForegroundColorAttributeName:[UIColor whiteColor]};
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //异步实现用户名、密码的判断
    //dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *urls = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        if(urls.count>0)
        {
            NSString *documentPath = urls[0];
            NSString *configPath = [documentPath stringByAppendingPathComponent:@"config.plist"];
            if([[NSFileManager defaultManager] fileExistsAtPath:configPath])
            {
                //文件已经存在,则读取文件信息
                NSDictionary *infoDictionary = [[NSDictionary alloc] initWithContentsOfFile:configPath];
                //读取用户名和密码
                NSString *strUsername = [infoDictionary objectForKey:@"username"];
                NSString *strPassword = [infoDictionary objectForKey:@"password"];
                NSString *strGesturePassword = [infoDictionary objectForKey:@"gesturePassword"];
                NSNumber *gesturePasswordState = [infoDictionary objectForKey:@"gesturePasswordState"];
                if(strUsername.length>0 && strPassword.length>0)
                {
                    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strLoginURL];
                    NSMutableDictionary *responseDictionary = [[NSMutableDictionary alloc] init];
                    NSString *strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"loginId\":\"%@\", \"pwd\":\"%@\", \"logType\":\"IPHONE\"}", strUsername, strPassword];
                    int value = [BIDDataCommunication uploadDataByPostToURL:strURL postValue:strPost toDictionary:responseDictionary];
                    //dispatch_async(dispatch_get_main_queue(), ^{
                        if(value==1)
                        {
                            if([[responseDictionary objectForKey:@"json"] isEqualToString:@"success"])
                            {
                                //登录成功
                                BIDManagerInNavViewController *managerVC = [[BIDManagerInNavViewController alloc] init];
                                navController = [[UINavigationController alloc] initWithRootViewController:managerVC];
                                //设置登录状态
                                [BIDAppDelegate setLoginFlag];
                                NSDictionary *subDictionary = [responseDictionary objectForKey:@"data"];
                                //保存用户id
                                [BIDAppDelegate setUserId:[subDictionary objectForKey:@"UID"]];
                                //
                                [BIDAppDelegate setStaticImgServer:[subDictionary objectForKey:@"IMG_STATIC_SERVER"]];
                                //为jpush设置用户别名
                                [APService setAlias:[subDictionary objectForKey:@"UID"] callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:self];
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
                                    int times = 0;
                                    int rev = 0;
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
                                        //如果头像请求失败，则重新请求，最多请求5次
                                        times++;
                                        rev = [BIDDataCommunication getDataFromNet:strCompleteURL data:imgData];
                                        if(rev==1 && imgData.length>0)
                                        {
                                            [imgData writeToURL:imgPath atomically:YES];
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [functionListVC setPortrait];
                                            });
                                        }
                                        else
                                        {
                                            //没有从后台成功获取头像图片，则删除本地已存在的同名的头像文件
                                            [fileManager removeItemAtURL:imgPath error:nil];
                                        }
                                    }while(rev==0 && times<5);
                                });
                                //手势密码开启并且设置过手势密码
                                if(![BIDAppDelegate isShowGuide] && [gesturePasswordState intValue]==1 && strGesturePassword.length>0)
                                {
                                    //进入手势解锁界面
                                    BIDGestureToUnlockViewController *gestureToUnlockVC = [[BIDGestureToUnlockViewController alloc] initWithNibName:@"BIDGestureToUnlockViewController" bundle:nil];
                                    gestureToUnlockVC.bToHomePage = YES;
                                    //navController = [[UINavigationController alloc] initWithRootViewController:gestureToUnlockVC];
                                    //[navController setViewControllers:@[gestureToUnlockVC]];
                                    [navController pushViewController:gestureToUnlockVC animated:NO];
                                }
                            }
                            else
                            {
                                /**2015-3-2*/
                                [BIDAppDelegate setUserId:@""];
                                /**2015-3-2*/
                                BIDManagerInNavViewController *managerVC = [[BIDManagerInNavViewController alloc] init];
                                navController = [[UINavigationController alloc] initWithRootViewController:managerVC];
                            }
                        }
                        else
                        {
                            /**2015-3-2*/
                            [BIDAppDelegate setUserId:@""];
                            /**2015-3-2*/
                            BIDManagerInNavViewController *managerVC = [[BIDManagerInNavViewController alloc] init];
                            navController = [[UINavigationController alloc] initWithRootViewController:managerVC];
                        }
      //              });
                }
                else
                {
                    /**2015-3-2*/
                    [BIDAppDelegate setUserId:@""];
                    /**2015-3-2*/
                    BIDManagerInNavViewController *managerVC = [[BIDManagerInNavViewController alloc] init];
                    navController = [[UINavigationController alloc] initWithRootViewController:managerVC];
                }
            }
            else
            {
                /**2015-3-2*/
                [BIDAppDelegate setUserId:@""];
                /**2015-3-2*/
                BIDManagerInNavViewController *managerVC = [[BIDManagerInNavViewController alloc] init];
                navController = [[UINavigationController alloc] initWithRootViewController:managerVC];
            }
        }
    //});
    //为导航栏设置背景图片
    [self.navController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBarBg.png"] forBarMetrics:UIBarMetricsDefault];
    [self.navController.navigationBar setTintColor:[UIColor whiteColor]];
    self.navController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:20.0f], NSForegroundColorAttributeName:[UIColor whiteColor]};
}

-(void)tagsAliasCallback:(int)iResCode tags:(NSSet*)tags alias:(NSString*)alias
{
    NSLog(@"%d", iResCode);
}

#pragma mark BIDFunctionListViewControllerDelegate
- (void)showTargetVCByIndex:(int)index
{
    [self mainViewControllerReset];
    switch(index)
    {
        case 0:
        {
            //显示登录页
            BIDLoginViewController *vc;
            if([UIScreen mainScreen].bounds.size.height>=568.0f)
            {
                vc = [[BIDLoginViewController alloc] initWithNibName:@"BIDLoginViewController2" bundle:nil];
            }
            else
            {
                vc = [[BIDLoginViewController alloc] initWithNibName:@"BIDLoginViewController" bundle:nil];
            }
            //[self.navController setViewControllers:@[vc] animated:YES];
            [self.navController pushViewController:vc animated:YES];
        }
            break;
        case 1:
        {
            //显示注册页
            BIDRegisterViewController *vc = [[BIDRegisterViewController alloc] initWithNibName:@"BIDRegisterViewController" bundle:nil];
            //[self.navController setViewControllers:@[vc] animated:YES];
            [self.navController pushViewController:vc animated:YES];
        }
            break;
        case 2:
        {
            //显示登录页
            BIDLoginViewController *vc;
            if([UIScreen mainScreen].bounds.size.height>=568.0f)
            {
                vc = [[BIDLoginViewController alloc] initWithNibName:@"BIDLoginViewController" bundle:nil];
            }
            else
            {
                vc = [[BIDLoginViewController alloc] initWithNibName:@"BIDLoginViewController320x480" bundle:nil];
            }
            vc.bRequestException = YES;
            [self.navController setViewControllers:@[vc] animated:YES];
        }
            break;
    }
}

/**
 *主视图恢复原位
 */
- (void)mainViewControllerReset
{
    NSArray *arr = self.navController.viewControllers;
    BIDManagerInNavViewController *vc = (BIDManagerInNavViewController*)arr[0];
    [vc removeMaskView];
    [UIView animateWithDuration:0.3f animations:^{
        self.navController.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    } completion:^(BOOL finished){}];
}

- (BOOL)isTheViewControllerExist:(Class)class1
{
    NSArray *vcArr = [self.navController viewControllers];
    for(UIViewController *vc in vcArr)
    {
        if([vc isKindOfClass:[class1 class]])
        {
            [self.navController popToViewController:vc animated:NO];
            return YES;
        }
    }
    return NO;
}

- (void)jumpToLoginViewController
{
    //显示登录页
    BIDLoginViewController *vc;
    if(IPHONE4OR4S)
    {
        vc = [[BIDLoginViewController alloc] initWithNibName:@"BIDLoginViewController" bundle:nil];
    }
    else
    {
        vc = [[BIDLoginViewController alloc] initWithNibName:@"BIDLoginViewController2" bundle:nil];
    }
    [self.navController setViewControllers:@[vc] animated:YES];
    [UIView animateWithDuration:0.3f animations:^{
        self.navController.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    } completion:^(BOOL finished){}];
}

@end
