//
//  BIDCommonMethods.h
//  党务通
//
//  Created by mal on 13-11-27.
//  Copyright (c) 2013年 mal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BIDCustomSpinnerView.h"
#import "BIDDataCommunication.h"



@interface BIDCommonMethods : NSObject

+ (void)showAlertView:(NSString*)msg buttonTitle:(NSString*)title delegate:(id)delegate tag:(int)iTag;

//文件数据数组dataArr 文件字段数组fieldArr
+ (NSMutableURLRequest*)getHttpRequest:(NSArray*)dataArr fieldArr:(NSArray*)fieldArr paramDictionary:(NSDictionary*)dictionary url:(NSURL*)url;

//判断一个字段名是否和文件字段数组中存在的名字相同
+ (BOOL)isInFieldArr:(NSString*)fieldName arr:(NSArray*)arr;

//设置状态栏是否显示
+ (void)setTheStatusBar:(int)flag;

//设置文字的样式属性

//
+ (UIViewController*)getViewController:(UIView*)srcView;

//为按钮设置图片
+ (void)setImgForBtn:(UIButton*)btn imgForNormal:(NSString*)imgForNormal imgForPress:(NSString*)imgForPress inset:(UIEdgeInsets)inset;
+ (void)setImgForBtn:(UIButton*)btn imgName:(NSString*)imgName state:(UIControlState)state inset:(UIEdgeInsets)inset;

//获得Library下的doc路径
+ (NSURL*)getLibraryPath;
//文件是否在library/downloads/doc下存在
+ (BOOL)isFileExist:(NSString*)fileName;
//文件是否在制定的路径下存在
+ (BOOL)isFileExist:(NSString *)fileName path:(NSURL*)desURL;
//获得配置文件
+ (NSString*)getConfigPath;

/**
 *获得文字的高度
 */
+ (NSUInteger)getHeightWithString:(NSString*)strText font:(UIFont*)font constraintSize:(CGSize)constraintSize;
/**
 *获得文字的宽度
 */
+ (NSUInteger)getWidthWithString:(NSString*)strText font:(UIFont*)font constraintSize:(CGSize)constraintSize;
/**
 *验证手机号是否格式正确
 */
+ (BOOL)isMobilePhoneNumberHaveCorrectFormat:(NSString*)phoneNumber;
/**
 *判断应该以万元为单位显示还是以元为单位显示
 */
+ (BOOL)isShowWithUnitsYuan:(NSString*)strAmount;
/**
 *用户是否注册了汇付天下
 */
+ (int)isHaveRegisterHFTX;
/**
 *过滤html标签
 */
+ (NSString*)filterHTML:(NSString*)srcString;
/**
 *存储推送信息
 */
+ (void)storeMsg:(NSDictionary*)userInfo;
/**
 *获取用户头像，如果没有设置过则返回默认头像图片
 */
+ (UIImage*)getPortrait;

@end
