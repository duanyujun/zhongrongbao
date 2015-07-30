//
//  BIDAppDelegate.h
//  zhongrongbao
//
//  Created by mal on 14-8-12.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"
typedef enum SHARE_PLATFORM_TYPE
{
    PLATFORM_WEIXIN, PLATFORM_QQ
}SHARE_PLATFORM_TYPE;
extern NSString *err_msg;
/**
 *储存登录信息的文件
 */
extern NSString *loginInfoFileName;
@class Reachability;
@class BIDFunctionListView;
@class BIDRootManagerViewController;

@interface BIDAppDelegate : UIResponder <UIApplicationDelegate, WXApiDelegate>
{
    Reachability *_hostReach;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) BIDFunctionListView *functionListView;

@property (strong, nonatomic) BIDRootManagerViewController *rootManagerVC;
+ (NSString*)SERVER_ADDR;
+ (void)SERVER_ADDR:(NSString*)strServerAddr;
+ (NSString*)getServerAddr;
+ (void)setServerAddr:(NSString*)strServerAddr;
//动态图片地址
+ (NSString*)getImgServerAddr;
+ (void)setImgServerAddr:(NSString*)strImgServerAddr;
//静态图片地址
+ (NSString*)getStaticImgServer;
+ (void)setStaticImgServer:(NSString*)serverImg;
//
+ (NSString*)getRefererAddr;
+ (void)setRefererAddr:(NSString*)strRefererAddr;
+ (NSString*)getUserId;
+ (void)setUserId:(NSString*)userId1;
+ (BOOL)isNetWorkConnecting;
+ (void)setPlatformType:(SHARE_PLATFORM_TYPE)type;
//
+ (BOOL)isHaveLogin;
+ (void)setNoLoginFlag;
+ (void)setLoginFlag;

+ (BOOL)isShowGuide;

+ (NSDictionary*)getAPNSInfo;
+ (void)clearAPNSInfo;
+ (UIWindow*)getKeyWindow;

@end
