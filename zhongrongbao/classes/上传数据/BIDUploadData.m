//
//  BIDUploadData.m
//  shangwuting
//
//  Created by mal on 14-1-7.
//  Copyright (c) 2014年 mal. All rights reserved.
//
static NSString *BOUNDARY = @"--abcd";
static NSString *END_BOUNDARY = @"--abcd--";

#import "BIDUploadData.h"
#import "BIDCustomSpinnerView.h"
#import "BIDCommonMethods.h"

@implementation BIDUploadData
@synthesize urlConnection;
@synthesize urlRequest;
@synthesize contentData;
@synthesize strTitle;
@synthesize spinnerView;
@synthesize delegate;

- (id)initData:(NSString *)strURL strText:(NSString *)strText
{
    if(self = [super init])
    {
        contentData = [NSMutableData data];
        NSURL *url = [NSURL URLWithString:strURL];
        urlRequest = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:180];
        spinnerView = [[BIDCustomSpinnerView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        [spinnerView initLayout];
        strTitle = strText;
    }
    return self;
}

- (void)addData:(NSString *)strKey value:(NSString *)strValue
{
    NSMutableString *str = [[NSMutableString alloc] initWithCapacity:1];
    [str appendFormat:@"%@\r\n", BOUNDARY];
    [str appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", strKey];
    [str appendFormat:@"%@\r\n", strValue];
    [contentData appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)addData1:(NSString *)strKey value:(NSData *)data
{
    NSMutableString *str = [[NSMutableString alloc] initWithCapacity:1];
    [str appendFormat:@"%@\r\n", BOUNDARY];
    [str appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", strKey];
    //[str appendFormat:@"%@\r\n", strValue];
    [str appendFormat:@"Content-Type: image/jpg\r\n\r\n"];
    [contentData appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
    [contentData appendData:data];
    NSString *str1 = @"\r\n";
    [contentData appendData:[str1 dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)addEndBoundary
{
    [contentData appendData:[END_BOUNDARY dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)finishAddData
{
    [self addEndBoundary];
    //设置HTTPHeader中Content-Type的值
    NSString *content = [[NSString alloc] initWithFormat:@"multipart/form-data; boundary=%@", @"abcd"];
    //设置HTTPHeader
    [urlRequest setValue:content forHTTPHeaderField:@"Content-Type"];
    //设置Content-Length
    [urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[contentData length]] forHTTPHeaderField:@"Content-Length"];
    //设置http body
    [urlRequest setHTTPBody:contentData];
    //http method
    [urlRequest setHTTPMethod:@"POST"];
}

- (void)startExecute
{
    [self finishAddData];
    spinnerView.content = [[NSString alloc] initWithFormat:@"正在%@..", strTitle];
    [spinnerView showTheView];
    urlConnection = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
}

//上传成功
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [contentData setLength:0];
    [spinnerView dismissTheView];
    NSString *strMsg = [[NSString alloc] initWithFormat:@"%@成功", strTitle];
    [BIDCommonMethods showAlertView:strMsg buttonTitle:@"关闭" delegate:self tag:0];
}

//上传出错
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [contentData setLength:0];
    [spinnerView dismissTheView];
    NSString *strMsg = [[NSString alloc] initWithFormat:@"%@失败", strTitle];
    [BIDCommonMethods showAlertView:strMsg buttonTitle:@"关闭" delegate:nil tag:0];
}

#pragma mark UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [delegate passValue:0];
}

@end
