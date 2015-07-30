//
//  BIDOpenHFTXViewController.m
//  zhongrongbao
//
//  Created by mal on 14-10-16.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDOpenHFTXViewController.h"
#import "BIDWebPageJumpViewController.h"
#import "BIDCommonMethods.h"
/**
 *获取汇付天下注册地址
 */
static NSString *strRegisterURL = @"UserPnr/UserRegister.shtml";

@interface BIDOpenHFTXViewController ()

@end

@implementation BIDOpenHFTXViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"开通汇付天下";
    //返回按钮设置
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backBtnHandler)];
    [BIDCommonMethods setImgForBtn:_openBtn imgForNormal:@"redBtnBgNormal.png" imgForPress:@"redBtnBgPress.png" inset:UIEdgeInsetsMake(10, 10, 11, 11)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backBtnHandler
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)openBtnHandler:(id)sender
{
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strRegisterURL];
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
                    NSString *strRegisterURL = [dictionary objectForKey:@"data"];
                    BIDWebPageJumpViewController *vc = [[BIDWebPageJumpViewController alloc] initWithNibName:@"BIDWebPageJumpViewController" bundle:nil];
                    vc.desURL = strRegisterURL;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                else
                {
                    [BIDCommonMethods showAlertView:[dictionary objectForKey:@"message"] buttonTitle:@"关闭" delegate:nil tag:0];
                }
            }
            else
            {
                [BIDCommonMethods showAlertView:@"请求失败" buttonTitle:@"关闭" delegate:nil tag:0];
            }
        });
    });
}

- (IBAction)noOpenBtnHandler:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
