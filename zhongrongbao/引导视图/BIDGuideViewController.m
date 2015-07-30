//
//  BIDGuideViewController.m
//  zhongrongbao
//
//  Created by mal on 14/11/11.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDGuideViewController.h"
#import "BIDRootManagerViewController.h"
#import "BIDCommonMethods.h"
#import "BIDGestureToUnlockViewController.h"

@interface BIDGuideViewController ()<UIScrollViewDelegate>
{
    int _curPage;
    UIButton *_skipBtn;
}

@end

@implementation BIDGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    _curPage = 0;
    NSArray *arr1 = @[@"small1@2x", @"small2@2x", @"small3@2x"];
    NSArray *arr2 = @[@"big1@2x", @"big2@2x", @"big3@2x"];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    for(int i=0; i<3; i++)
    {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(i*screenSize.width, 0, screenSize.width, screenSize.height)];
        [_myScrollView addSubview:imgView];
        UIImage *img = nil;
        NSString *strPath;
        if(screenSize.height>=568.0f)
        {
            strPath = [[NSBundle mainBundle] pathForResource:arr2[i] ofType:@"png"];
        }
        else
        {
            strPath = [[NSBundle mainBundle] pathForResource:arr1[i] ofType:@"png"];
        }
        img = [UIImage imageWithContentsOfFile:strPath];
        [imgView setImage:img];
    }
    [_myScrollView setContentSize:CGSizeMake(screenSize.width*3, screenSize.height)];
    _myScrollView.delegate = self;
    //
    _skipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:_skipBtn];
    CGSize btnSize;
    CGFloat posY = 0.0f;
    CGFloat space = 20.0f;
    CGFloat fontSize = 18.0f;
    if(screenSize.height>=568.0f)
    {
        btnSize = CGSizeMake(80, 25);
        posY = 18.0f;
        space = 15.0f;
        fontSize = 10.0f;
    }
    else
    {
        btnSize = CGSizeMake(73, 23);
        posY = 10.0f;
        space = 10.0f;
        fontSize = 10.0f;
    }
    _skipBtn.frame = CGRectMake(screenSize.width-space-btnSize.width, posY, btnSize.width, btnSize.height);
    UIColor *color = [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.2f];
    _skipBtn.layer.borderColor = color.CGColor;
    _skipBtn.layer.borderWidth = 0.5;
    _skipBtn.layer.cornerRadius = 2;
    [_skipBtn setTitle:@"跳过" forState:UIControlStateNormal];
    [_skipBtn setTitleColor:color forState:UIControlStateNormal];
    [_skipBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_skipBtn addTarget:self action:@selector(skipBtnHandler) forControlEvents:UIControlEventTouchUpInside];
    [_skipBtn.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSArray *arr = _myScrollView.subviews;
    UIView *sub1 = arr[0];
    NSLog(@"%f", CGRectGetMinY(sub1.frame));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)skipBtnHandler
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    NSString *strConfigPath = [BIDCommonMethods getConfigPath];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:strConfigPath];
    NSNumber *gesturePasswordState = [dictionary objectForKey:@"gesturePasswordState"];
    NSString *strGesturePassword = [dictionary objectForKey:@"gesturePassword"];
    //手势密码开启并且设置过手势密码
    if([gesturePasswordState intValue]==1 && strGesturePassword.length>0)
    {
        //进入手势解锁界面
        BIDGestureToUnlockViewController *gestureToUnlockVC = [[BIDGestureToUnlockViewController alloc] initWithNibName:@"BIDGestureToUnlockViewController" bundle:nil];
        gestureToUnlockVC.bToHomePage = YES;
        NSArray *arr = self.navigationController.viewControllers;
        NSMutableArray *arr1 = [[NSMutableArray alloc] initWithArray:arr];
        [arr1 removeObjectAtIndex:1];
        [arr1 addObject:gestureToUnlockVC];
        [self.navigationController setViewControllers:arr1];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if(page == _curPage)
    {
        if(page==2)
        {
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            NSString *strConfigPath = [BIDCommonMethods getConfigPath];
            NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:strConfigPath];
            NSNumber *gesturePasswordState = [dictionary objectForKey:@"gesturePasswordState"];
            NSString *strGesturePassword = [dictionary objectForKey:@"gesturePassword"];
            //手势密码开启并且设置过手势密码
            if([gesturePasswordState intValue]==1 && strGesturePassword.length>0)
            {
                //进入手势解锁界面
                BIDGestureToUnlockViewController *gestureToUnlockVC = [[BIDGestureToUnlockViewController alloc] initWithNibName:@"BIDGestureToUnlockViewController" bundle:nil];
                gestureToUnlockVC.bToHomePage = YES;
                NSArray *arr = self.navigationController.viewControllers;
                NSMutableArray *arr1 = [[NSMutableArray alloc] initWithArray:arr];
                [arr1 removeObjectAtIndex:1];
                [arr1 addObject:gestureToUnlockVC];
                [self.navigationController setViewControllers:arr1];
            }
            else
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
    else
    {
        _curPage = page;
        _pageControl.currentPage = page;
    }
}

@end
