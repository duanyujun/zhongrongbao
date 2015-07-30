//
//  BIDPopularizeViewController.m
//  zhongrongbao
//
//  Created by mal on 14-9-1.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDPopularizeViewController.h"
#import "BIDShareView.h"
#import "BIDCommonMethods.h"
#import "QRCodeGenerator.h"
#import "BIDLoginViewController.h"

/**
 *推广收益和推广人数查询
 */
static NSString *strQueryPopularizeInfoURL = @"ExtendProfit/extendProfitCount.shtml";

@interface BIDPopularizeViewController ()<UIAlertViewDelegate>
{
    BIDShareView *_shareView;
    /**
     *推广链接
     */
    NSString *_popularizeURL;
}
@end

@implementation BIDPopularizeViewController
@synthesize popularizeIncomeLabel;
@synthesize popularizePeopleCountLabel;
@synthesize shareBtn;
@synthesize imgView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //创建分享视图
    _shareView = (BIDShareView*)[[[NSBundle mainBundle] loadNibNamed:@"BIDShareView" owner:self options:nil] lastObject];
    [BIDCommonMethods setImgForBtn:shareBtn imgForNormal:@"redBtnBgNormal.png" imgForPress:@"redBtnBgPress.png" inset:UIEdgeInsetsMake(10, 10, 11, 11)];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    parent.navigationItem.titleView = nil;
    parent.navigationItem.title = @"推广达人";
    //parent.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonHandler)];
    parent.navigationItem.rightBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    //
    [self queryPopularizeInfo];
}

/**
 *查询推广收益和推广人数
 */
- (void)queryPopularizeInfo
{
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strQueryPopularizeInfoURL];
    self.spinnerView.content = @"请稍后..";
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
                    NSDictionary *subDictionary = [dictionary objectForKey:@"data"];
                    self.popularizeIncomeLabel.text = [subDictionary objectForKey:@"profitAmt"];
                    if(self.popularizeIncomeLabel.text.length==0)
                    {
                        self.popularizeIncomeLabel.text = @"0";
                    }
                    self.popularizePeopleCountLabel.text = [subDictionary objectForKey:@"recommendCouunt"];
                    _popularizeURL = [subDictionary objectForKey:@"url"];
                    _popularizeURL = [[NSString alloc] initWithFormat:@"https://www.zrbao.com/reg.shtml?param=%@", _popularizeURL];
                    UIImage *img = [QRCodeGenerator qrImageForString:_popularizeURL imageSize:imgView.frame.size.width];
                    imgView.image = img;
                    _shareView.shareURL = _popularizeURL;
                }
            }
            else if(rev==2)
            {
                [BIDCommonMethods showAlertView:err_msg buttonTitle:@"关闭" delegate:self tag:2];
            }
        });
    });
}

/**
 *分享
 */
- (void)rightBarButtonHandler
{
    [_shareView showShareView];
}

/**
 *微信分享到朋友
 */
- (IBAction)shareBtnHandler:(id)sender
{
    [_shareView showShareView];
}

#pragma mark -UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==2)
    {
        //登录
        BIDLoginViewController *vc;
        if(IPHONE4OR4S)
        {
            vc = [[BIDLoginViewController alloc] initWithNibName:@"BIDLoginViewController" bundle:nil];
        }
        else
        {
            vc = [[BIDLoginViewController alloc] initWithNibName:@"BIDLoginViewController2" bundle:nil];
        }
        vc.bRequestException = YES;
        [self.navigationController setViewControllers:@[vc] animated:YES];
    }
}

@end
