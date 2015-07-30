//
//  BIDWebPageJumpViewController.m
//  zhongrongbao
//
//  Created by mal on 14-10-16.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDWebPageJumpViewController.h"
#import "BIDManagerInNavViewController.h"

@interface BIDWebPageJumpViewController ()

@end

@implementation BIDWebPageJumpViewController
@synthesize desURL;
@synthesize navTitle;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if(navTitle.length>0)
    {
        self.title = navTitle;
    }
    else
    {
        self.title = @"汇付天下";
    }
    [self.view setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f]];
    [_webView setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f]];
    [_webView setOpaque:NO];
    //返回按钮设置
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backBtnHandler)];
    //
    NSURL *url = [NSURL URLWithString:desURL];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if(parent && [parent isKindOfClass:[BIDManagerInNavViewController class]])
    {
        parent.navigationItem.title = @"消息详情";
        parent.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)backBtnHandler
{
    [self.navigationController popViewControllerAnimated:YES];
}

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
