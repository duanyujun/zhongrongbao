//
//  BIDSystemAboutViewController.m
//  zhongrongbao
//
//  Created by mal on 14/11/12.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDSystemAboutViewController.h"
#import "BIDDataCommunication.h"
#import "BIDVersionDescriptionViewController.h"
#import "BIDWebPageJumpViewController.h"

static NSString *strLinkURL = @"version/getFooter.shtml";

@interface BIDSystemAboutViewController ()<UIAlertViewDelegate>
{
    NSString *_trackViewURL;
    NSString *_websiteURL;
    NSString *_disclaimerURL;
    NSString *_privacyStatementURL;
    NSString *_weiboURL;
}

@end

@implementation BIDSystemAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _websiteURL = @"";
    _disclaimerURL = @"";
    _privacyStatementURL = @"";
    _weiboURL = @"";
    //获取当前版本
    NSString *strCurrentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    _curVersionLabel.text = [[NSString alloc] initWithFormat:@"中融宝V %@", strCurrentVersion];
    //获取链接
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strLinkURL];
    [self.spinnerView showTheView];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        int rev = [BIDDataCommunication getDataFromNet:strURL toDictionary:dictionary];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinnerView dismissTheView];
            if(rev==1)
            {
                if([[dictionary objectForKey:@"json"] isEqualToString:@"success"])
                {
                    NSArray *arr = [dictionary objectForKey:@"dataList"];
                    for(NSDictionary *dictionary in arr)
                    {
                        NSString *strName = [dictionary objectForKey:@"name"];
                        NSString *strRequest = [dictionary objectForKey:@"request"];
                        if([strName isEqualToString:@"官网"])
                        {
                            _websiteURL = strRequest;
                        }
                        else if([strName isEqualToString:@"免责声明"])
                        {
                            _disclaimerURL = strRequest;
                        }
                        else if([strName isEqualToString:@"隐私声明"])
                        {
                            _privacyStatementURL = strRequest;
                        }
                        else if([strName isEqualToString:@"微博"])
                        {
                            _weiboURL = strRequest;
                        }
                    }
                }
            }
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    //
    parent.navigationItem.titleView = nil;
    parent.navigationItem.title = @"关于系统";
    parent.navigationItem.rightBarButtonItem = nil;
}

- (IBAction)updateBtnHandler:(id)sender
{
    NSString *strCurrentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    //查询最新版本
    NSString *strURL = @"http://itunes.apple.com/lookup?id=942349023";
    [self.spinnerView showTheView];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        int value = [BIDDataCommunication uploadDataByGetToURL:strURL toDictionary:dictionary];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinnerView dismissTheView];
            if(value == 1)
            {
                NSArray *infoArr = [dictionary objectForKey:@"results"];
                if(infoArr.count==0)
                {
                    [BIDCommonMethods showAlertView:@"您已经是最新版本啦!" buttonTitle:@"关闭" delegate:nil tag:0];
                }
                else
                {
                    NSDictionary *infoDic = infoArr[0];
                    NSString *strLatestVersion = [infoDic objectForKey:@"version"];
                    _trackViewURL = [infoDic objectForKey:@"trackViewUrl"];
                    if([strCurrentVersion isEqualToString:strCurrentVersion])
                    {
                        [BIDCommonMethods showAlertView:@"您已经是最新版本啦!" buttonTitle:@"关闭" delegate:nil tag:0];
                    }
                    else
                    {
                        NSString *strVersionMsg = [[NSString alloc] initWithFormat:@"当前版本:%@\r\n最新版本:%@", strCurrentVersion, strLatestVersion];
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:strVersionMsg delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:@"更新", nil];
                        [alertView show];
                    }
                }
            }
        });
    });
}

- (IBAction)descriptionBtnHandler:(id)sender
{
    BIDVersionDescriptionViewController *vc = [[BIDVersionDescriptionViewController alloc] initWithNibName:@"BIDVersionDescriptionViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)toWebsite:(id)sender
{
    if(_websiteURL.length>0)
    {
        [self jumpToURL:_websiteURL title:@"官网"];
    }
}

- (IBAction)toDisclaimer:(id)sender
{
    if(_disclaimerURL.length>0)
    {
        [self jumpToURL:_disclaimerURL title:@"免责声明"];
    }
}

- (IBAction)toPrivacyStatement:(id)sender
{
    if(_privacyStatementURL.length>0)
    {
        [self jumpToURL:_privacyStatementURL title:@"隐私声明"];
    }
}

- (IBAction)toWeibo:(id)sender
{
    if(_weiboURL.length>0)
    {
        [self jumpToURL:_weiboURL title:@"微博"];
    }
}

- (void)jumpToURL:(NSString *)strURL title:(NSString*)strTitle
{
//    NSURL *url = [NSURL URLWithString:strURL];
//    [[UIApplication sharedApplication] openURL:url];
    BIDWebPageJumpViewController *vc = [[BIDWebPageJumpViewController alloc] initWithNibName:@"BIDWebPageJumpViewController" bundle:nil];
    vc.desURL = strURL;
    vc.navTitle = strTitle;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //更新
    if(buttonIndex==1)
    {
        if(_trackViewURL.length>0)
        {
            NSURL *url = [NSURL URLWithString:_trackViewURL];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

@end
