//
//  BIDLoginAndRegisterViewController.m
//  zhongrongbao
//
//  Created by mal on 14-8-13.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDLoginAndRegisterViewController.h"
#import "BIDLoginViewController.h"
#import "BIDRegisterViewController.h"

@interface BIDLoginAndRegisterViewController ()

@end

@implementation BIDLoginAndRegisterViewController

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
    [self.view setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f]];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if(screenSize.height>=568.0f)
    {
        [_imgView setImage:[UIImage imageNamed:@"loginRegister5.png"]];
    }
    else
    {
        [_imgView setImage:[UIImage imageNamed:@"loginRegister.png"]];
    }
    UIImage *imgForNormal = [UIImage imageNamed:@"blueBtnBgNormal.png"];
    UIImage *stretchImgForNormal = [imgForNormal resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 11, 11)];
    UIImage *imgForPress = [UIImage imageNamed:@"blueBtnBgPress.png"];
    UIImage *stretchImgForPress = [imgForPress resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 11, 11)];
    [_loginBtn setBackgroundImage:stretchImgForNormal forState:UIControlStateNormal];
    [_loginBtn setBackgroundImage:stretchImgForPress forState:UIControlStateHighlighted];
    [_registerBtn setBackgroundImage:stretchImgForNormal forState:UIControlStateNormal];
    [_registerBtn setBackgroundImage:stretchImgForPress forState:UIControlStateHighlighted];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginBtnHandler:(id)sender
{
    if([UIScreen mainScreen].bounds.size.height>=568.0f)
    {
        BIDLoginViewController *loginVC = [[BIDLoginViewController alloc] initWithNibName:@"BIDLoginViewController" bundle:nil];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
    else
    {
        BIDLoginViewController *loginVC = [[BIDLoginViewController alloc] initWithNibName:@"BIDLoginViewController320x480" bundle:nil];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
}

- (IBAction)registerBtnHandler:(id)sender
{
    BIDRegisterViewController *registerVC = [[BIDRegisterViewController alloc] initWithNibName:@"BIDRegisterViewController" bundle:nil];
    [self.navigationController pushViewController:registerVC animated:YES];
}

@end
