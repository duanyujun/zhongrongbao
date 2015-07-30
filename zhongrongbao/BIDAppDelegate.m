//
//  BIDAppDelegate.m
//  zhongrongbao
//
//  Created by mal on 14-8-12.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDAppDelegate.h"
#import "Reachability.h"
#import "BIDDataCommunication.h"
#import "BIDLoginViewController.h"
#import "BIDLoginAndRegisterViewController.h"
#import "BIDResponseView.h"
#import "BIDRechargeAndWithdrawalViewController.h"
#import "BIDRootManagerViewController.h"
#import "BIDGestureToUnlockViewController.h"
#import "BIDGuideViewController.h"

#import <TencentOpenAPI/TencentOAuth.h>
#import "TencentOpenAPI/QQApiInterface.h"
#import "BIDShareView.h"

#import "BIDTenderDetailInfoViewController.h"
#import "BIDMsgDetailViewController.h"
#import "BIDWebPageJumpViewController.h"

#import "APService.h"

NSString *err_msg = @"登录异常，请重新登录";
NSString *loginInfoFileName = @"loginInfo.plist";
//version2.0
static NSString *SERVER_ADDR;
//
static NSString *serverAddr = @"http://zrbao.com";
static NSString *strQuitURL = @"User/logQuit.shtml";
static NSString *imgServerAddr = @"";
static NSString *imgForStaticServerAddr = @"";
static NSString *refererAddr = @"";
static NSString *userId;
static BOOL bHaveLogin = NO;
static BOOL bNetCanConnect;
static BOOL bShowGuide;
static UIWindow *myWindow;
//static BOOL bFirst = YES;
static SHARE_PLATFORM_TYPE platformType;
/**
 *应用未启动时收到推送消息的内容
 */
static NSMutableDictionary *apnsInfo;

@interface BIDAppDelegate()<TencentSessionDelegate, QQApiInterfaceDelegate, UIAlertViewDelegate>
{
    BIDGuideViewController *_guideVC;
    TencentOAuth *_oAuth;
    /**
     *应用在前台时收到推送消息，用来临时保存，供其他函数使用
     */
    NSDictionary *_substituteUserInfo;
    /**
     *用来储存推送过来的消息内容，随看随删
     */
    NSMutableArray *_apnsArr;
}

@end

@implementation BIDAppDelegate
@synthesize functionListView;
@synthesize rootManagerVC;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //清空角标数量
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    _apnsArr = [[NSMutableArray alloc] init];
    apnsInfo = [[NSMutableDictionary alloc] init];
    if(launchOptions)
    {
        NSDictionary *launchDictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        /**
         *保存推送消息时用到,uid是存到config.plist里的，如果不存储uid,在通过点击收到的推送消息的通知栏来启动应用时，这时候
         *会因为还没有登录，因此uid为空，这样就保存不了对应该uid的推送消息了
         */
        /**
         *2015-3-2
         */
        NSString *strConfigPath = [BIDCommonMethods getConfigPath];
        NSDictionary *configDictionary = [[NSDictionary alloc] initWithContentsOfFile:strConfigPath];
        userId = [configDictionary objectForKey:@"uid"];
        /**
         *2015-3-2
         */
        //
        [BIDCommonMethods storeMsg:[launchDictionary objectForKey:@"aps"]];
        [apnsInfo setDictionary:[launchDictionary objectForKey:@"aps"]];
    }
    //注册推送
//    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound];
    //JPush
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                   UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)
                                       categories:nil];
    // Required
    [APService setupWithOption:launchOptions];
    //JPush
    
    
    bNetCanConnect = YES;
    //判断网络是否可用
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    NSString *hostName = @"www.apple.com";
    _hostReach = [Reachability reachabilityWithHostName:hostName];
    [_hostReach startNotifier];
    //判断是否需要显示引导页
    //NSString *strCurrentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:CFBridgingRelease(kCFBundleVersionKey)];
    NSString *strCurrentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *strVersion = [defaults objectForKey:@"version"];
    if(!strVersion || ![strVersion isEqualToString:strCurrentVersion])
    {
        [defaults setValue:strCurrentVersion forKey:@"version"];
        [defaults synchronize];
        bShowGuide = YES;
    }
    else
    {
        bShowGuide = NO;
    }
    //
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    rootManagerVC = [[BIDRootManagerViewController alloc] init];
    self.window.rootViewController = rootManagerVC;
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    myWindow = self.window;
    //
    //注册微信wx921fbe0bfb98bee4
    [WXApi registerApp:@"wx921fbe0bfb98bee4"];
    //注册qq开发者id
    _oAuth = [[TencentOAuth alloc] initWithAppId:@"1103516075" andDelegate:self];
    return YES;
}
+ (UIWindow*)getKeyWindow
{
    return myWindow;
}

+ (BOOL)isNetWorkConnecting
{
    return bNetCanConnect;
}

+ (BOOL)isHaveLogin
{
    return bHaveLogin;
}

+ (void)setNoLoginFlag
{
    bHaveLogin = NO;
}
+ (void)setLoginFlag
{
    bHaveLogin = YES;
}
/**
 *version 2.0
 */
+ (NSString*)SERVER_ADDR
{
    return SERVER_ADDR;
}
+ (void)SERVER_ADDR:(NSString *)strServerAddr
{
    SERVER_ADDR = strServerAddr;
}
+ (NSString*)getServerAddr
{
    return serverAddr;
}

+ (void)setServerAddr:(NSString *)strServerAddr
{
    serverAddr = strServerAddr;
}

+ (NSString*)getImgServerAddr
{
    return imgServerAddr;
}

+ (void)setImgServerAddr:(NSString *)strImgServerAddr
{
    imgServerAddr = strImgServerAddr;
}
//静态图片地址
+ (NSString*)getStaticImgServer
{
    return imgForStaticServerAddr;
}
+ (void)setStaticImgServer:(NSString*)imgServer
{
    imgForStaticServerAddr = imgServer;
}

+ (NSString*)getRefererAddr
{
    return refererAddr;
}

+ (void)setRefererAddr:(NSString *)strRefererAddr
{
    refererAddr = strRefererAddr;
}

+ (NSString*)getUserId
{
    return userId;
}

+ (void)setUserId:(NSString *)userId1
{
    userId = userId1;
}

+ (BOOL)isShowGuide
{
    return bShowGuide;
}
+ (void)setPlatformType:(SHARE_PLATFORM_TYPE)type
{
    platformType = type;
}
+ (NSDictionary*)getAPNSInfo
{
    return apnsInfo;
}
+ (void)clearAPNSInfo
{
    apnsInfo = nil;
}

- (void)reachabilityChanged:(NSNotification *)note
{
    Reachability *curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    if(netStatus == NotReachable)
    {
        bNetCanConnect = NO;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前网络不可用" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        bNetCanConnect = YES;
    }
}

#pragma mark WXApiDelegate
- (void)onResp:(BaseResp *)resp
{
    BIDResponseView *responseView = (BIDResponseView*)[[[NSBundle mainBundle] loadNibNamed:@"BIDResponseView" owner:self options:nil] lastObject];
    //分享成功
    if(resp.errCode == 0)
    {
        responseView.response = @"分享成功";
        responseView.imgName = @"success.png";
    }
    else
    {
        //分享失败
        responseView.response = @"分享失败";
        responseView.imgName = @"failure.png";
    }
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    __block CGRect responseViewFrame = responseView.frame;
    responseViewFrame.origin.x = screenSize.width/2 - CGRectGetWidth(responseViewFrame)/2;
    responseViewFrame.origin.y = screenSize.height/2 - CGRectGetHeight(responseViewFrame)/2;
    responseView.frame = responseViewFrame;
    responseView.alpha = 0;
    [keyWindow addSubview:responseView];
    [UIView animateWithDuration:1.5f animations:^{
        responseView.alpha = 1.0f;
    } completion:^(BOOL finished){
        responseView.alpha = 0.0f;
        [responseView removeFromSuperview];
    }];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL isSuc = YES;
    switch(platformType)
    {
        case PLATFORM_WEIXIN:
        {
            isSuc = [WXApi handleOpenURL:url delegate:self];
        }
            break;
        case PLATFORM_QQ:
        {
            [QQApiInterface handleOpenURL:url delegate:(id<QQApiInterfaceDelegate>)[BIDShareView class]];
            
            
            if(YES == [TencentOAuth CanHandleOpenURL:url])
            {
                return [TencentOAuth HandleOpenURL:url];
            }
        }
            break;
    }
    return  isSuc;
}

//推送相关
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [APService registerDeviceToken:deviceToken];
}

/**
 自定义消息结构
 *{
 "notification" : {
 "ios" : {
 "alert" : "hello, JPush!",
 "sound" : "happy",
 "badge" : 1,
 "extras" : {
 "news_id" : 134,
 "my_key" : "a value"
 }
 }
 }
 }
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //清空角标数量
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    //存储推送的消息
    [BIDCommonMethods storeMsg:[userInfo objectForKey:@"aps"]];
    
    if (application.applicationState == UIApplicationStateActive)
    {
        //_substituteUserInfo = [[NSDictionary alloc] initWithDictionary:[userInfo objectForKey:@"aps"]];
        [_apnsArr addObject:[userInfo objectForKey:@"aps"]];
        NSString *strMsg = @"您有一条新的消息";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"消息通知" message:strMsg delegate:self cancelButtonTitle:@"忽略" otherButtonTitles:@"查看", nil];
        [alertView show];
    }
    else
    {
        //根据参数来跳转界面
        [self jumpToDesViewWithDictionary:[userInfo objectForKey:@"aps"]];
    }
    [APService handleRemoteNotification:userInfo];
}

//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
//{
//    userInfo = [[[userInfo objectForKey:@"notification"] objectForKey:@"ios"] objectForKey:@"extras"];
//    //清空角标数量
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
//    [[UIApplication sharedApplication] cancelAllLocalNotifications];
//    //存储推送来的消息
//    [BIDCommonMethods storeMsg:userInfo];
//    if(application.applicationState == UIApplicationStateActive)
//    {
//        _substituteUserInfo = [[NSDictionary alloc] initWithDictionary:userInfo];
//        NSString *strMsg = [userInfo objectForKey:@"title"];
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"消息通知" message:strMsg delegate:self cancelButtonTitle:@"忽略" otherButtonTitles:@"查看", nil];
//        [alertView show];
//    }
//    else if(application.applicationState == UIApplicationStateInactive)
//    {
//        //根据参数来跳转界面
//        [self jumpToDesViewWithDictionary:userInfo];
//    }
////    else if(application.applicationState == UIApplicationStateBackground)
////    {
////        //存储推送来的消息
////        [BIDCommonMethods storeMsg:userInfo];
////    }
//    [APService handleRemoteNotification:userInfo];
//    completionHandler(UIBackgroundFetchResultNewData);
//}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"%@", error);
}
//

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSString *strConfigPath = [BIDCommonMethods getConfigPath];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:strConfigPath];
    NSString *strGesturePassword = [dictionary objectForKey:@"gesturePassword"];
    NSNumber *value = [dictionary objectForKey:@"gesturePasswordState"];
    if(strGesturePassword.length>0 && [value intValue]==1)
    {
        //进入手势解锁界面
        BIDGestureToUnlockViewController *gestureToUnlockVC = [[BIDGestureToUnlockViewController alloc] initWithNibName:@"BIDGestureToUnlockViewController" bundle:nil];
        gestureToUnlockVC.bToHomePage = NO;
        gestureToUnlockVC.navController = rootManagerVC.navController;
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        UIViewController *vc = keyWindow.rootViewController;
        [vc presentViewController:gestureToUnlockVC animated:YES completion:^{}];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //清空角标数量
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    //退出session
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strQuitURL];
    [BIDDataCommunication getDataFromNet:strURL toDictionary:nil];
}

/**
 *根据推送消息类型来跳转界面
 */
- (void)jumpToDesViewWithDictionary:(NSDictionary*)userInfo
{
    //NSString *strKeyType = [userInfo objectForKey:@"keyType"];
    UINavigationController *navController = rootManagerVC.navController;
    if(navController.view.frame.origin.x>0)
    {
        [rootManagerVC mainViewControllerReset];
    }
    NSString *strContent = [userInfo objectForKey:@"alert"];
    NSString *strTitle = @"新消息";
    if([strContent rangeOfString:@":"].location!=NSNotFound)
    {
        NSInteger index = [strContent rangeOfString:@":"].location;
        strTitle = [strContent substringToIndex:index];
        strContent = [strContent substringFromIndex:index+1];
    }
    //消息
    BIDMsgDetailViewController *vc = [[BIDMsgDetailViewController alloc] init];
    vc.msgTitle = strTitle;
    vc.msgContent = strContent;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    vc.msgDate = strDate;
    [navController pushViewController:vc animated:YES];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSUInteger count = _apnsArr.count;
    NSDictionary *dictionary = _apnsArr[count-1];
    [_apnsArr removeObjectAtIndex:count-1];
    if(buttonIndex==1)
    {
        [self jumpToDesViewWithDictionary:dictionary];
    }
}

@end
