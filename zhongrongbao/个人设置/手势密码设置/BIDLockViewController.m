//
//  BIDLockViewController.m
//  mashangban
//
//  Created by mal on 14-8-11.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDLockViewController.h"
#import "BIDLockViewForSet.h"
#import "BIDLockViewForLogin.h"
#import "BIDManagerInNavViewController.h"
#import "BIDCommonMethods.h"

@interface BIDLockViewController ()<BIDLockViewForSetDelegate, UIAlertViewDelegate>

@end

@implementation BIDLockViewController
@synthesize bLogin;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"设置手势密码";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:239.0f/255.0f green:239.0f/255.0f blue:243.0f/255.0f alpha:1.0f]];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBarHidden = NO;
    // Do any additional setup after loading the view from its nib.
    if(bLogin)
    {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"跳过" style:UIBarButtonItemStyleBordered target:self action:@selector(skipBtnHandler)];
    }
    [self initView];
}
/**
 *跳过
 */
- (void)skipBtnHandler
{
    [BIDCommonMethods showAlertView:@"下次可在个人设置中重新设置手势密码" buttonTitle:@"关闭" delegate:self tag:0];
}

- (void)initView
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    //if(!bLogin)
    {
        CGRect lockViewFrame = CGRectMake(0, 0, screenSize.width, screenSize.height-64);
        _lockView = [[BIDLockViewForSet alloc] initWithFrame:lockViewFrame];
        _lockView.delegate = self;
        [self.view addSubview:_lockView];
    }
//    else
//    {
//        CGRect lockViewForLoginFrame = CGRectMake(0, 100.0f, screenSize.width, 300.0f);
//        _lockViewForLogin = [[BIDLockViewForLogin alloc] initWithFrame:lockViewForLoginFrame];
//        [self.view addSubview:_lockViewForLogin];
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark BIDLockViewForSetDelegate
- (void)setGesturePasswordSuccess
{
    if(bLogin)
    {
        BIDManagerInNavViewController *vc = [[BIDManagerInNavViewController alloc] init];
        [self.navigationController setViewControllers:@[vc] animated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BIDManagerInNavViewController *vc = [[BIDManagerInNavViewController alloc] init];
    [self.navigationController setViewControllers:@[vc] animated:YES];
}

@end
