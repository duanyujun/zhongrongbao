//
//  BIDDataCommunication.m
//  党务通
//
//  Created by mal on 13-11-23.
//  Copyright (c) 2013年 mal. All rights reserved.
//

#import "BIDDataCommunication.h"
#import "BIDAppDelegate.h"
#import "BIDCommonMethods.h"
#import "BIDRootManagerViewController.h"

static int countPerPage = 5;
static NSDictionary *cookieDictionary;

@interface BIDDataCommunication()<UIAlertViewDelegate>
{
    NSURL *_url;
    NSMutableURLRequest *_urlRequest;
    NSURLConnection *_urlConnection;
    NSMutableData *_data;
}
@end
@implementation BIDDataCommunication
@synthesize delegate;
@synthesize completionHandler;

+ (BIDDataCommunication*)getInstance
{
    static dispatch_once_t token;
    static BIDDataCommunication *dataCommunication;
    dispatch_once(&token, ^{
        dataCommunication = [[BIDDataCommunication alloc] init];
    });
    return dataCommunication;
}

- (id)initWithURL:(NSString *)strURL
{
    self = [super init];
    if(self)
    {
        _url = [NSURL URLWithString:strURL];
        _urlRequest = [NSMutableURLRequest requestWithURL:_url];
        _urlConnection = [[NSURLConnection alloc] initWithRequest:_urlRequest delegate:self];
    }
    return self;
}

- (void)uploadDataByGetToURL:(NSString*)strURL toDictionary:(NSMutableDictionary *)desDictionary
{
    if(_data)
    {
        _data = [[NSMutableData alloc] init];
    }
    else
    {
        _data.length = 0;
    }
    _url = [NSURL URLWithString:[strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    _urlRequest = [NSMutableURLRequest requestWithURL:_url];
    _urlConnection = [[NSURLConnection alloc] initWithRequest:_urlRequest delegate:self];
}

- (NSURLConnection*)uploadDataByPostToURL:(NSString*)strURL postValue:(NSString*)postValue completionHandler:(void (^)(id obj))completionHandler1
{
    if(!_data)
    {
        _data = [[NSMutableData alloc] init];
    }
    else
    {
        _data.length = 0;
    }
    self.completionHandler = completionHandler1;
    NSData *postData = [postValue dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [[NSString alloc] initWithFormat:@"%lu", (unsigned long)postData.length];
    _url = [NSURL URLWithString:[strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    _urlRequest = [NSMutableURLRequest requestWithURL:_url];
    [_urlRequest setHTTPMethod:@"POST"];
    [_urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [_urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [_urlRequest setHTTPBody:postData];
    _urlConnection = [[NSURLConnection alloc] initWithRequest:_urlRequest delegate:self];
    return _urlConnection;
}
#pragma mark -NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if(_data&&_data.length>0)
    {
        NSError *err;
        id obj = [NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingAllowFragments error:&err];
        self.completionHandler(obj);
    }
    else
    {
        self.completionHandler(nil);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.completionHandler(nil);
    [BIDCommonMethods showAlertView:@"请求超时，请稍后重试" buttonTitle:@"关闭" delegate:nil tag:0];
}

#pragma  mark - static function
+ (void)setCountPerPage:(int)count
{
    countPerPage = count;
}
+ (int)getCountPerPage
{
    return countPerPage;
}

+ (int)uploadDataByGetToURL:(NSString *)strURL toDictionary:(NSMutableDictionary *)desDictionary
{
    NSURL *url;
    NSURLRequest *urlRequest;
    NSURLResponse *response;
    NSError *err;
    NSData *data;
    url = [NSURL URLWithString:[strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    urlRequest = [NSURLRequest requestWithURL:url];
    data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&err];
    if(data!=nil && err==nil)
    {
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
        if(dictionary!=nil && err==nil)
        {
            if(desDictionary)
            {
                [desDictionary setDictionary:dictionary];
            }
            return 1;
        }
    }
    return 0;
}

+ (int)uploadDataByPostToURL:(NSString*)strURL postValue:(NSString*)postValue toDictionary:(NSMutableDictionary*)desDictionary
{
    NSURL *url;
    NSMutableURLRequest *urlRequest;
    NSURLResponse *response = nil;
    NSError *err = nil;
    NSData *data = nil;
    NSData *postData = [postValue dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [[NSString alloc] initWithFormat:@"%lu", (unsigned long)postData.length];
    url = [NSURL URLWithString:[strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody:postData];
    data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&err];
    NSDictionary *headers = [(NSHTTPURLResponse*)response allHeaderFields];
    NSString *strCookies = [headers objectForKey:@"Set-Cookie"];
    if(strCookies.length>0)
    {
        NSArray *arr = [strCookies componentsSeparatedByString:@";"];
        NSArray *arr1 = [arr[0] componentsSeparatedByString:@"="];
        NSArray *arr2 = [arr[1] componentsSeparatedByString:@"="];
        NSString *strDomain = [BIDAppDelegate getServerAddr];
        strDomain = [strDomain substringFromIndex:7];
        cookieDictionary = @{NSHTTPCookieName:@"JSESSIONID", NSHTTPCookieValue:arr1[1], NSHTTPCookieDomain:strDomain, NSHTTPCookiePath:arr2[1]};
        
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSHTTPCookie *newCookie = [NSHTTPCookie cookieWithProperties:cookieDictionary];
        [storage setCookie:newCookie];
    }

    if(data!=nil && err==nil)
    {
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
        if(dictionary!=nil && err==nil)
        {
            if(desDictionary)
            {
                [desDictionary setDictionary:dictionary];
            }
            if([[dictionary objectForKey:@"json"] isEqualToString:@"login"])
            {
                //账号在其他地方登录或登录过期
                return 2;
            }
            else
            {
                return 1;
            }
        }
    }
    return 0;
}
+ (int)uploadDataByPostWithoutCookie:(NSString*)strURL postValue:(NSString*)postValue toDictionary:(NSMutableDictionary*)desDictionary
{
    NSURL *url;
    NSMutableURLRequest *urlRequest;
    NSURLResponse *response = nil;
    NSError *err = nil;
    NSData *data = nil;
    NSData *postData = [postValue dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [[NSString alloc] initWithFormat:@"%lu", (unsigned long)postData.length];
    url = [NSURL URLWithString:[strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody:postData];
    
    //
    if(cookieDictionary && cookieDictionary.count>0)
    {
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSHTTPCookie *newCookie = [NSHTTPCookie cookieWithProperties:cookieDictionary];
        [storage setCookie:newCookie];
    }
    //
    
    data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&err];
    
    if(data!=nil && err==nil)
    {
        id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
        NSDictionary *dictionary = nil;
        if([obj isKindOfClass:[NSArray class]])
        {}
        else if([obj isKindOfClass:[NSDictionary class]])
        {
            dictionary = (NSDictionary*)obj;
        }
        if(dictionary!=nil && err==nil)
        {
            if(desDictionary)
            {
                [desDictionary setDictionary:dictionary];
            }
            if([[dictionary objectForKey:@"json"] isEqualToString:@"login"])
            {
                //账号在其他地方登录或登录过期
                return 2;
            }
            else
            {
                return 1;
            }
        }
    }
    return 0;
}
/**
 *以数组格式存储数据,针对2.0版本，新的数据请求方式
 */
+ (int)uploadDataByPostWithoutCookie:(NSString*)strURL postValue:(NSString*)postValue curPage:(NSInteger)pageNumber toArr:(NSMutableArray*)desArr
{
    NSURL *url;
    NSMutableURLRequest *urlRequest;
    NSURLResponse *response = nil;
    NSError *err = nil;
    NSData *data = nil;
    NSData *postData = [postValue dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [[NSString alloc] initWithFormat:@"%lu", (unsigned long)postData.length];
    url = [NSURL URLWithString:[strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody:postData];
    
    //
    if(cookieDictionary && cookieDictionary.count>0)
    {
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSHTTPCookie *newCookie = [NSHTTPCookie cookieWithProperties:cookieDictionary];
        [storage setCookie:newCookie];
    }
    //
    data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&err];
    
    if(data!=nil && err==nil)
    {
        id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
        if(obj!=nil && err==nil)
        {
            if([obj isKindOfClass:[NSArray class]])
            {
                NSArray *arr = (NSArray*)obj;
                [desArr addObjectsFromArray:arr];
                return 1;
            }
            else
            {
                NSDictionary *dictionary = (NSDictionary*)obj;
                NSDictionary *headDictionary = dictionary[@"head"];
                if([[headDictionary objectForKey:@"state"] isEqualToString:@"FAIL"])
                {
                    return 0;
                }
                NSArray *arr;
                NSDictionary *bodyDictionary = [dictionary objectForKey:@"body"];
                NSDictionary *pageInfoDictionary = bodyDictionary[@"pageInfo"];
                {
                    int totalPage = [[pageInfoDictionary objectForKey:@"pageCount"] intValue];
                    
                    if(pageNumber > totalPage)
                    {
                        arr = @[];
                    }
                    else
                    {
                        arr = [pageInfoDictionary objectForKey:@"pageData"];
                    }
                }
                [desArr addObjectsFromArray:arr];
                return 1;
            }
        }
        else
        {
            return  0;
        }
    }
    return 0;
}

+ (int)getDataFromNet:(NSString *)strURL toArray:(NSMutableArray *)desArr page:(int)pageNumber
{
    NSURL *url;
    NSMutableURLRequest *urlRequest;
    NSURLResponse *response;
    NSError *err;
    NSData *data;
    NSString *strPost = @"";
    NSString *findStr = @"?";
    NSRange range = [strURL rangeOfString:findStr];
    if(range.location==NSNotFound)
    {
        strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"page.currentPage\":\"%d\", \"page.showCount\":\"%d\"}", pageNumber, countPerPage];
    }
    else
    {
        NSString *strParam = [strURL substringFromIndex:range.location+1];
        NSArray *arr = [strParam componentsSeparatedByString:@"="];
        NSString *strField = arr[0];
        NSString *strValue = arr[1];
        strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"page.currentPage\":\"%d\", \"page.showCount\":\"%d\", \"%@\":\"%@\"}", pageNumber, countPerPage, strField, strValue];
    }
    NSData *postData = [strPost dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [[NSString alloc] initWithFormat:@"%lu", (unsigned long)postData.length];
    url = [NSURL URLWithString:[strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody:postData];
    //
    if(cookieDictionary && cookieDictionary.count>0)
    {
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSHTTPCookie *newCookie = [NSHTTPCookie cookieWithProperties:cookieDictionary];
        [storage setCookie:newCookie];
    }
    //
    data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&err];

    if(data!=nil && err==nil)
    {
        id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
        if(obj!=nil && err==nil)
        {
            if([obj isKindOfClass:[NSArray class]])
            {
                NSArray *arr = (NSArray*)obj;
                [desArr addObjectsFromArray:arr];
                return 1;
            }
            else
            {
                NSDictionary *dictionary = (NSDictionary*)obj;
                if([[dictionary objectForKey:@"json"] isEqualToString:@"login"])
                {
                    return 2;
                }
                NSArray *arr;
                NSDictionary *subDictionary = [dictionary objectForKey:@"page"];
                if(!subDictionary)
                {
                    arr = [dictionary objectForKey:@"dataList"];
                }
                else
                {
                    int totalPage = [[subDictionary objectForKey:@"totalPage"] intValue];
                    
                    if(pageNumber > totalPage)
                    {
                        arr = @[];
                    }
                    else
                    {
                        arr = [dictionary objectForKey:@"dataList"];
                    }
                }
                [desArr addObjectsFromArray:arr];
                return 1;
            }
        }
        else
        {
            return  0;
        }
    }
    return 0;
}

+ (int)getDataFromNet:(NSString *)strURL toDictionary:(NSMutableDictionary *)desDictionary
{
    NSURL *url;
    NSMutableURLRequest *urlRequest;
    NSURLResponse *response;
    NSError *err;
    NSData *data;
    url = [NSURL URLWithString:[strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    //
    
    if(cookieDictionary && cookieDictionary.count>0)
    {
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSHTTPCookie *newCookie = [NSHTTPCookie cookieWithProperties:cookieDictionary];
        [storage setCookie:newCookie];
    }
    //
    data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&err];
    if(err)
    {
        NSLog(@"%@", [err localizedDescription]);
    }
    if(data!=nil && err==nil)
    {
        id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
        if(obj!=nil && err==nil)
        {
            if([obj isKindOfClass:[NSArray class]])
            {
            }
            else if([obj isKindOfClass:[NSDictionary class]])
            {
                [desDictionary setDictionary:obj];
                if([[desDictionary objectForKey:@"json"] isEqualToString:@"login"])
                {
                    return 2;
                }
            }
            return 1;
        }
        else
        {
            return 0;
        }
    }
    return 0;
}

+ (int)getDataFromNet:(NSString *)strURL data:(NSMutableData *)desData
{
    NSURL *url;
    NSURLRequest *urlRequest;
    NSURLResponse *response;
    NSError *err;
    NSData *data;
    url = [NSURL URLWithString:[strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    urlRequest = [[NSURLRequest alloc] initWithURL:url];
    //
    if(cookieDictionary && cookieDictionary.count>0)
    {
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSHTTPCookie *newCookie = [NSHTTPCookie cookieWithProperties:cookieDictionary];
        [storage setCookie:newCookie];
    }
    //
    data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&err];
    if(data!=nil && err==nil)
    {
        [desData appendData:data];
        return 1;
    }
    return 0;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BIDAppDelegate *appDelegate = (BIDAppDelegate*)[UIApplication sharedApplication].delegate;
    BIDRootManagerViewController *rootVC = appDelegate.rootManagerVC;
    [rootVC jumpToLoginViewController];
}

@end
