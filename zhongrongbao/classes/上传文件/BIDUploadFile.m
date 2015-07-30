//
//  BIDUploadFile.m
//  shangwuting
//
//  Created by mal on 13-12-24.
//  Copyright (c) 2013年 mal. All rights reserved.
//

const NSString *BOUNDARY = @"--abcd";
const NSString *END_BOUNDARY = @"--abcd--";

#import "BIDUploadFile.h"
#import "BIDCommonMethods.h"
#import "BIDCustomSpinnerView.h"
#import "BIDAppDelegate.h"

@implementation BIDUploadFile
@synthesize urlConnection;
@synthesize urlRequest;
@synthesize fileSize;
@synthesize fileData;
@synthesize uploadedLength;

@synthesize delegate;

@synthesize label;
@synthesize progressView;
@synthesize cancelBtn;
@synthesize uploadView;
@synthesize bgView;
@synthesize spinnerView;
@synthesize hintMsg;

- (id)init
{
    if(self=[super init])
    {
        fileData = [NSMutableData data];
        [self initUploadView];
    }
    return self;
}

- (void)initURL:(NSString *)strURL
{
    //fileData = [NSMutableData data];
    NSURL *url = [NSURL URLWithString:strURL];
    urlRequest = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:180];
    //
    //[self initUploadView];
}

- (void)initUploadView
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    [bgView setBackgroundColor:[UIColor colorWithWhite:0.5f alpha:0.5f]];
    
    CGSize uploadViewSize = CGSizeMake(300, 0);
    uploadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, uploadViewSize.width, uploadViewSize.height)];
    uploadView.layer.borderWidth = 5;
    uploadView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    uploadView.layer.cornerRadius = 8;
    [uploadView setBackgroundColor:[UIColor colorWithWhite:0.2f alpha:0.8f]];
    
    CGRect ownFrame = uploadView.frame;
    CGSize labelSize = CGSizeMake(ownFrame.size.width, 30);
    CGRect labelFrame = CGRectMake(0, 5, labelSize.width, labelSize.height);
    label = [[UILabel alloc] initWithFrame:labelFrame];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:18.0f];
    label.textColor = [UIColor blackColor];
    label.text = @"正在上传...";
    [label setBackgroundColor:[UIColor clearColor]];
    [uploadView addSubview:label];
    
    CGSize progressViewSize = CGSizeMake(ownFrame.size.width-10, 5);
    CGRect progressViewFrame = CGRectMake(5, label.frame.origin.y+label.frame.size.height+10, progressViewSize.width, progressViewSize.height);
    progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    progressView.frame = progressViewFrame;
    [uploadView addSubview:progressView];
    
    CGSize btnSize = CGSizeMake(150, 20);
    CGRect btnFrame = CGRectMake((ownFrame.size.width-btnSize.width)/2, progressView.frame.origin.y+progressView.frame.size.height+20, btnSize.width, btnSize.height);
    cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //[btn setBackgroundColor:[UIColor clearColor]];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [cancelBtn setTitle:@"取消上传" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnHandler) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.frame = btnFrame;
    cancelBtn.layer.borderWidth = 1;
    cancelBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    [uploadView addSubview:cancelBtn];
    
    ownFrame.size.height = label.frame.size.height + progressView.frame.size.height + cancelBtn.frame.size.height + 50;
    uploadView.frame = ownFrame;
    
    //spinnerView
    spinnerView = [[BIDCustomSpinnerView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    [spinnerView initLayout];
    spinnerView.content = @"请稍候..";
}

//添加普通键值对
- (void)addData:(NSString *)strKey value:(NSString *)strValue
{
    NSMutableString *str = [[NSMutableString alloc] initWithCapacity:1];
    [str appendFormat:@"%@\r\n", BOUNDARY];
    [str appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", strKey];
    [str appendFormat:@"%@\r\n", strValue];
    [fileData appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
}

//添加本地文件
- (void)addFileFromLocal:(NSString *)strFileName fieldName:(NSString *)strFieldName
{
    NSURL *libraryURL = [BIDCommonMethods getLibraryPath];
    if(!libraryURL) return;
    NSString *str = [[NSString alloc] initWithFormat:@"downloads/doc/%@", strFileName];
    NSURL *fileURL = [libraryURL URLByAppendingPathComponent:str];
    NSMutableString *str1 = [[NSMutableString alloc] initWithCapacity:1];
    [str1 appendFormat:@"%@\r\n", BOUNDARY];
    [str1 appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", strFieldName, strFileName];
    //声明上传文件的格式
    [str1 appendFormat:@"Content-Type: image/jpg\r\n\r\n"];
    [fileData appendData:[str1 dataUsingEncoding:NSUTF8StringEncoding]];
    
    //添加文件数据
    [fileData appendData:[NSData dataWithContentsOfURL:fileURL]];
    NSString *str2 = @"\r\n";
    [fileData appendData:[str2 dataUsingEncoding:NSUTF8StringEncoding]];
}

//添加内存中的文件数据
- (void)addFileFromMemory:(NSString *)strFileName fieldName:(NSString *)strFieldName data:(NSData *)data
{
    NSMutableString *str = [[NSMutableString alloc] initWithCapacity:1];
    [str appendFormat:@"%@\r\n", BOUNDARY];
    [str appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", strFieldName, strFileName];
    //声明上传文件的格式
    [str appendFormat:@"Content-Type: image/jpg\r\n\r\n"];
    [fileData appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
    
    //添加文件数据
    [fileData appendData:data];
    NSString *str1 = @"\r\n";
    [fileData appendData:[str1 dataUsingEncoding:NSUTF8StringEncoding]];
}

//添加结束符
- (void)addEndBoundary
{
    [fileData appendData:[END_BOUNDARY dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)finishAddFile
{
    [self addEndBoundary];
    //设置HTTPHeader中Content-Type的值
    NSString *content = [[NSString alloc] initWithFormat:@"multipart/form-data; boundary=%@", @"abcd"];
    //设置HTTPHeader
    [urlRequest setValue:content forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[BIDAppDelegate getRefererAddr] forHTTPHeaderField:@"Referer"];
    //设置Content-Length
    [urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[fileData length]] forHTTPHeaderField:@"Content-Length"];
    //设置http body
    [urlRequest setHTTPBody:fileData];
    //http method
    [urlRequest setHTTPMethod:@"POST"];
    
    //文件大小
    fileSize = fileData.length;
}

//开始上传
- (void)startUpload
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGRect uploadFrame = uploadView.frame;
    uploadFrame.origin.x = (screenSize.width-uploadFrame.size.width)/2;
    uploadFrame.origin.y = (screenSize.height-uploadFrame.size.height)/2;
    uploadView.frame = uploadFrame;
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:bgView];
    [keyWindow addSubview:uploadView];
    urlConnection = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
}

//取消上传
- (void)cancelBtnHandler
{
    [urlConnection cancel];
    [bgView removeFromSuperview];
    [uploadView removeFromSuperview];
}

#pragma mark NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    if([obj isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dictionary = (NSDictionary*)obj;
        hintMsg = [dictionary objectForKey:@"message"];
    }
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    CGFloat rate = totalBytesWritten*1.0f / totalBytesExpectedToWrite;
    [progressView setProgress:rate animated:YES];
    if(rate==1)
    {
        [fileData setLength:0];
        uploadedLength = 0;
        [progressView setProgress:0];
        [bgView removeFromSuperview];
        [uploadView removeFromSuperview];
        [spinnerView showTheView];
    }
}

//上传完成
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [spinnerView dismissTheView];
    [NSThread sleepForTimeInterval:0.5f];
    [fileData setLength:0];
    uploadedLength = 0;
    [progressView setProgress:0];
    [bgView removeFromSuperview];
    [uploadView removeFromSuperview];
    NSString *str = [[NSString alloc] initWithFormat:@"%@", hintMsg];
    [BIDCommonMethods showAlertView:str buttonTitle:@"关闭" delegate:self tag:0];
}

//上传出错
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [progressView setProgress:0];
    [fileData setLength:0];
    [urlConnection cancel];
    [bgView removeFromSuperview];
    [uploadView removeFromSuperview];
    [spinnerView dismissTheView];
    [BIDCommonMethods showAlertView:@"请求超时,请重新尝试" buttonTitle:@"关闭" delegate:nil tag:0];
}

#pragma mark UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [delegate uploadFileSuccess];
}

@end
