//
//  BIDCommonMethods.m
//  党务通
//
//  Created by mal on 13-11-27.
//  Copyright (c) 2013年 mal. All rights reserved.
//

#import "BIDCommonMethods.h"
#import "BIDDataCommunication.h"
#import "BIDAppDelegate.h"

/**
 *查询客户汇付天下账户信息
 */
static NSString *strQueryUserAccountInfoURL = @"UserPay/PnrCount.shtml";

@implementation BIDCommonMethods

+ (void)showAlertView:(NSString *)msg buttonTitle:(NSString *)title delegate:(id)delegate tag:(int)iTag
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:delegate cancelButtonTitle:title otherButtonTitles:nil, nil];
    alert.tag = iTag;
    [alert show];
}

+ (void)setTheStatusBar:(int)flag
{
    if(flag==1)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    else
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
}

+ (NSMutableURLRequest*)getHttpRequest:(NSArray*)dataArr fieldArr:(NSArray*)fieldArr paramDictionary:(NSDictionary *)dictionary url:(NSURL *)url
{
    NSString *FORM_BOUNDARY = @"AaB03x";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    //设置分界线
    NSString *boundary = [[NSString alloc] initWithFormat:@"--%@", FORM_BOUNDARY];
    //设置结束符
    NSString *endBoundary = [[NSString alloc] initWithFormat:@"%@--", boundary];
    //http body字符串
    NSMutableString *body = [[NSMutableString alloc] init];
    //参数集合
    NSArray *keys = [dictionary allKeys];
    //遍历keys
    for(int i=0; i<[keys count]; i++)
    {
        NSString *key = [keys objectAtIndex:i];
        if(![self isInFieldArr:key arr:fieldArr])
        {
            //添加分界线，换行
            [body appendFormat:@"%@\r\n", boundary];
            //添加字段名称，换行
            [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key];
            //添加字段的值
            [body appendFormat:@"%@\r\n", [dictionary objectForKey:key]];
        }
    }
    //声明data,放入http body
    NSMutableData *myRequestData = [NSMutableData data];
    //将body字符串转化为utf8格式的二进制
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *end = @"";
    if(dataArr.count>0)
    {
        for(int i=0; i<dataArr.count; i++)
        {
            NSMutableString *body1 = [[NSMutableString alloc] init];
            //添加分界线，换行
            [body1 appendFormat:@"%@\r\n", boundary];
            //声明字段，文件名
            [body1 appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", [fieldArr objectAtIndex:i], [dictionary objectForKey:[fieldArr objectAtIndex:i]]];
            //声明上传文件的格式
            [body1 appendFormat:@"Content-Type: image/jpg\r\n\r\n"];

            //将body字符串转化为utf8格式的二进制
            [myRequestData appendData:[body1 dataUsingEncoding:NSUTF8StringEncoding]];
            //加入image的data
            [myRequestData appendData:[dataArr objectAtIndex:i]];
            if(i<dataArr.count-1)
            {
                NSString *str1 = [[NSString alloc] initWithFormat:@"\r\n"];
                [myRequestData appendData:[str1 dataUsingEncoding:NSUTF8StringEncoding]];
            }
        }
        //声明结束符
        end = [[NSString alloc] initWithFormat:@"\r\n%@", endBoundary];
    }
    else
    {
        //声明结束符
        end = [[NSString alloc] initWithFormat:@"%@", endBoundary];
    }

    //加入结束符
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    //设置HTTPHeader中Content-Type的值
    NSString *content = [[NSString alloc] initWithFormat:@"multipart/form-data; boundary=%@", FORM_BOUNDARY];
    //设置HTTPHeader
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    //设置http body
    [request setHTTPBody:myRequestData];
    //http method
    [request setHTTPMethod:@"POST"];
    
    return request;
}

+ (BOOL)isInFieldArr:(NSString *)fieldName arr:(NSArray *)arr
{
    for(int i=0; i<arr.count; i++)
    {
        if([fieldName isEqualToString:[arr objectAtIndex:i]])
        {
            return YES;
        }
        if(i==arr.count-1)
        {
            return NO;
        }
    }
    return NO;
}

+ (UIViewController*)getViewController:(UIView *)srcView
{
    for(UIView *next=[srcView superview]; next; next=next.superview)
    {
        UIResponder *nextResponder = [next nextResponder];
        if([nextResponder isKindOfClass:[UIViewController class]])
        {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

//为按钮设置图片
+ (void)setImgForBtn:(UIButton*)btn imgForNormal:(NSString *)imgForNormal imgForPress:(NSString *)imgForPress inset:(UIEdgeInsets)inset
{
    UIImage *imgNormal = [UIImage imageNamed:imgForNormal];
    UIImage *stretchImgForNormal = [imgNormal resizableImageWithCapInsets:inset resizingMode:UIImageResizingModeStretch];
    UIImage *imgPressed = [UIImage imageNamed:imgForPress];
    UIImage *stretchImgPressed = [imgPressed resizableImageWithCapInsets:inset resizingMode:UIImageResizingModeStretch];
    [btn setBackgroundImage:stretchImgForNormal forState:UIControlStateNormal];
    [btn setBackgroundImage:stretchImgPressed forState:UIControlStateHighlighted];
}
/**
 *为按钮的某个状态设置背景图片
 */
+ (void)setImgForBtn:(UIButton*)btn imgName:(NSString*)imgName state:(UIControlState)state inset:(UIEdgeInsets)inset
{
    UIImage *img = [UIImage imageNamed:imgName];
    UIImage *stretchImg = [img resizableImageWithCapInsets:inset resizingMode:UIImageResizingModeStretch];
    [btn setBackgroundImage:stretchImg forState:state];
}

//
+ (NSURL*)getLibraryPath
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *urls = [fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];
    if(urls.count>0)
    {
        return urls[0];
    }
    return nil;
}

//
+ (BOOL)isFileExist:(NSString *)fileName
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *urls = [fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];
    if(urls.count>0)
    {
        NSError *err;
        NSURL *libraryURL = urls[0];
        NSURL *downloadURL = [libraryURL URLByAppendingPathComponent:@"downloads/doc/" isDirectory:YES];
        if([fileManager createDirectoryAtURL:downloadURL withIntermediateDirectories:YES attributes:nil error:&err])
        {
            NSArray *files = [fileManager contentsOfDirectoryAtURL:downloadURL includingPropertiesForKeys:nil options:0 error:&err];
            for(NSURL *fileURL in files)
            {
                NSString *strFileName = [fileURL lastPathComponent];
                if([fileName isEqualToString:strFileName])
                {
                    return YES;
                }
            }
            return NO;
        }
    }
    return NO;
}

+ (BOOL)isFileExist:(NSString *)fileName path:(NSURL*)desURL
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSError *err = nil;
    if([fileManager createDirectoryAtURL:desURL withIntermediateDirectories:YES attributes:nil error:&err])
    {
        NSArray *files = [fileManager contentsOfDirectoryAtURL:desURL includingPropertiesForKeys:nil options:0 error:&err];
        for(NSURL *fileURL in files)
        {
            NSString *strFileName = [fileURL lastPathComponent];
            if([fileName isEqualToString:strFileName])
            {
                return YES;
            }
        }
        return NO;
    }
    return NO;
}
/**
 *获取配置文件路径
 */
+ (NSString*)getConfigPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"config.plist"];
}

/**
 *获取给定文字的高度
 */
+ (NSUInteger)getHeightWithString:(NSString *)strText font:(UIFont *)font constraintSize:(CGSize)constraintSize
{
    NSDictionary *attributeDictionary = @{NSFontAttributeName:font};
    CGSize size = [strText boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributeDictionary context:nil].size;
    return ceil(size.height);
}
/**
 *获取给定文字的宽度
 */
+ (NSUInteger)getWidthWithString:(NSString *)strText font:(UIFont *)font constraintSize:(CGSize)constraintSize
{
    NSDictionary *attributeDictionary = @{NSFontAttributeName:font};
    CGSize size = [strText boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributeDictionary context:nil].size;
    return ceil(size.width);
}

+ (BOOL)isMobilePhoneNumberHaveCorrectFormat:(NSString *)phoneNumber
{
    BOOL bFlag = YES;
    NSRegularExpression *regExpression = [[NSRegularExpression alloc] initWithPattern:@"^1[0-9]\\d{9}$" options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger matchCount = 0;
    matchCount = [regExpression numberOfMatchesInString:phoneNumber options:NSMatchingReportProgress range:NSMakeRange(0, phoneNumber.length)];
    if(matchCount==0)
    {
        bFlag = NO;
    }
    return bFlag;
}

/**
 *判断应该以万元为单位显示还是以元为单位显示
 */
+ (BOOL)isShowWithUnitsYuan:(NSString*)strAmount
{
    BOOL bFlag = YES;
    if([strAmount rangeOfString:@"."].location!=NSNotFound && [strAmount rangeOfString:@"."].location>=5)
    {
        bFlag = NO;
    }
    else if([strAmount rangeOfString:@"."].location==NSNotFound && strAmount.length>=5)
    {
        bFlag = NO;
    }
    else
    {
        bFlag = YES;
    }
    return bFlag;
}
/**
 *用户是否注册了汇付天下
 */
+ (int)isHaveRegisterHFTX
{
    //BOOL bFlag = NO;
    int state = 0;
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strQueryUserAccountInfoURL];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    int rev = [BIDDataCommunication getDataFromNet:strURL toDictionary:dictionary];
    if(rev==0)
    {
        //请求失败
        state = 0;
    }
    else if(rev==1)
    {
        NSDictionary *subDictionary = [dictionary objectForKey:@"data"];
        if([[subDictionary objectForKey:@"pnrStatus"] isEqualToString:@"N"])
        {
            //未注册
            state = 1;
        }
        else
        {
            //已注册
            state = 2;
        }
    }
    else if(rev==2)
    {
        //账号在其他设备登录或登录超时
        state = 3;
    }
    return state;
}
/**
 *过滤html标签
 */
+ (NSString*)filterHTML:(NSString *)srcString
{
    NSLog(@"%@", srcString);
    NSScanner *scanner = [[NSScanner alloc] initWithString:srcString];
    while(![scanner isAtEnd])
    {
        NSString *strFilter;
        [scanner scanUpToString:@"<" intoString:nil];
        [scanner scanUpToString:@">" intoString:&strFilter];
        srcString = [srcString stringByReplacingOccurrencesOfString:[[NSString alloc] initWithFormat:@"%@>", strFilter] withString:@""];
    }
    srcString = [srcString stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    srcString = [srcString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    srcString = [srcString stringByReplacingOccurrencesOfString:@"\r\n\r\n\r\n" withString:@"\r\n"];
    srcString = [srcString stringByReplacingOccurrencesOfString:@"\r\n\r\n" withString:@"\r\n"];
    return srcString;
}
/**
 *获取用户头像
 */
+ (UIImage*)getPortrait
{
    
    //从library中找到设置过的头像图片
    NSArray *arr = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    if(arr.count>0)
    {
        NSString *portraitPath = [arr[0] stringByAppendingPathComponent:@"portraitImg/portrait.png"];
        if([[NSFileManager defaultManager] fileExistsAtPath:portraitPath])
        {
            //文件是否存在
            UIImage *img = [UIImage imageWithContentsOfFile:portraitPath];
            if(img) return img;
        }
    }
    UIImage *img = [UIImage imageNamed:@"defaultPortrait.png"];
    return img;
}

/**
 *存储推送消息
 */
+ (void)storeMsg:(NSDictionary *)userInfo
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *strRootPath = arr[0];
    NSString *strMsgForUserPath = [strRootPath stringByAppendingPathComponent:@"msg_user.plist"];
    NSString *strTitle = @"新消息";
    NSString *strContent = [userInfo objectForKey:@"alert"];
    if([strContent rangeOfString:@":"].location!=NSNotFound)
    {
        NSInteger index = [strContent rangeOfString:@":"].location;
        strTitle = [strContent substringToIndex:index];
        strContent = [strContent substringFromIndex:index+1];
    }
    if(!strContent||strContent.length==0) strContent = @"";
    NSDictionary *desDictionary = @{@"title":strTitle, @"content":strContent, @"date":strDate};
    //
    //NSMutableArray *arrForSystem = [[NSMutableArray alloc] initWithContentsOfFile:strMsgForUserPath];
    NSMutableDictionary *msgDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:strMsgForUserPath];
    NSString *strKey = [BIDAppDelegate getUserId];
    if(strKey.length>0)
    {
        if(msgDictionary)
        {
            NSMutableArray *msgArr = nil;
            NSArray *arr = msgDictionary[strKey];
            if(arr)
            {
                msgArr = [[NSMutableArray alloc] initWithArray:arr];
            }
            else
            {
                msgArr = [[NSMutableArray alloc] init];
            }
            [msgArr addObject:desDictionary];
            msgDictionary[strKey] = msgArr;
        }
        else
        {
            msgDictionary = [[NSMutableDictionary alloc] init];
            NSArray *arr = @[desDictionary];
            msgDictionary[strKey] = arr;
        }
    }
    //if(!arrForSystem) arrForSystem = [[NSMutableArray alloc] init];
    //[arrForSystem addObject:desDictionary];
    //[arrForSystem writeToFile:strMsgForUserPath atomically:YES];
    [msgDictionary writeToFile:strMsgForUserPath atomically:YES];
}
/**
 *之前消息分类型罗列的时候使用这个方法
 */
//+ (void)storeMsg:(NSDictionary *)userInfo
//{
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
//    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
//    NSString *strMsgType = [userInfo objectForKey:@"msgType"];
//    NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *strRootPath = arr[0];
//    NSString *strMsgForUserPath = [strRootPath stringByAppendingPathComponent:@"msg_user.plist"];
//    NSString *strMsgForSystemPath = [strRootPath stringByAppendingPathComponent:@"msg_system.plist"];
//    NSString *strMsgForBroadcastPath = [strRootPath stringByAppendingPathComponent:@"msg_broadcast.plist"];
//    //
//    NSString *strTitle = [userInfo objectForKey:@"title"];
//    if(!strTitle||strTitle.length==0) strTitle = @"";
//    NSString *strContent = [userInfo objectForKey:@"msg_content"];
//    if(!strContent||strContent.length==0) strContent = @"";
//    NSDictionary *desDictionary = @{@"title":strTitle, @"content":strContent, @"date":strDate};
//    //
//    if([strMsgType isEqualToString:@"01"])
//    {
//        NSMutableArray *arrForUser = [[NSMutableArray alloc] initWithContentsOfFile:strMsgForUserPath];
//        if(!arrForUser) arrForUser = [[NSMutableArray alloc] init];
//        [arrForUser addObject:desDictionary];
//        [arrForUser writeToFile:strMsgForUserPath atomically:YES];
//    }
//    else if([strMsgType isEqualToString:@"02"])
//    {
//        NSMutableArray *arrForSystem = [[NSMutableArray alloc] initWithContentsOfFile:strMsgForSystemPath];
//        if(!arrForSystem) arrForSystem = [[NSMutableArray alloc] init];
//        [arrForSystem addObject:desDictionary];
//        [arrForSystem writeToFile:strMsgForSystemPath atomically:YES];
//    }
//    else if([strMsgType isEqualToString:@"03"])
//    {
//        NSMutableArray *arrForBroadcast = [[NSMutableArray alloc] initWithContentsOfFile:strMsgForBroadcastPath];
//        if(!arrForBroadcast) arrForBroadcast = [[NSMutableArray alloc] init];
//        [arrForBroadcast addObject:desDictionary];
//        [arrForBroadcast writeToFile:strMsgForBroadcastPath atomically:YES];
//    }
//}

@end
