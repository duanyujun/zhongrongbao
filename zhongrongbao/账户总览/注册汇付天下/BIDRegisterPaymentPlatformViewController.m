//
//  BIDRegisterPaymentPlatformViewController.m
//  zhongrongbao
//
//  Created by mal on 14-10-6.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDRegisterPaymentPlatformViewController.h"

@interface BIDRegisterPaymentPlatformViewController ()<UIWebViewDelegate>

@end

@implementation BIDRegisterPaymentPlatformViewController
@synthesize registerURL;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"注册汇付天下";
    [self.view setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f]];
    [_webView setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f]];
    [_webView setOpaque:NO];
    NSURL *url = [NSURL URLWithString:registerURL];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    //self.spinnerView.content = @"正在加载..";
    //[self.spinnerView showTheView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //[self.spinnerView dismissTheView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    //[self.spinnerView dismissTheView];
    //[BIDCommonMethods showAlertView:@"打开注册链接失败" buttonTitle:@"关闭" delegate:nil tag:0];
}

@end
