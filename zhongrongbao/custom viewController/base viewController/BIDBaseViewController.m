//
//  BIDBaseViewController.m
//  mashangban
//
//  Created by mal on 14-7-23.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDBaseViewController.h"

@interface BIDBaseViewController ()

@end

@implementation BIDBaseViewController
@synthesize spinnerView;
@synthesize toolBar;
@synthesize distanceToMove;
@synthesize keyboardHeight;
@synthesize stretchImgForNormal;
@synthesize stretchImgForPress;

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
    
    //设置视图的背景颜色
    [self.view setBackgroundColor:[UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0f]];
    spinnerView = [[BIDCustomSpinnerView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    [spinnerView initLayout];
    distanceToMove = 0;
    keyboardHeight = 0;
    //toolBar
    CGSize toolBarSize = CGSizeMake(320, 30);
    CGRect toolBarFrame = CGRectMake(0, 0, toolBarSize.width, toolBarSize.height);
    toolBar = [[UIToolbar alloc] initWithFrame:toolBarFrame];
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"关闭键盘" style:UIBarButtonItemStyleBordered target:self action:@selector(closeKeyboardHandler)];
    item1.tintColor = [UIColor whiteColor];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolBar setItems:[[NSArray alloc] initWithObjects:item2, item1, nil]];
    toolBar.barStyle = UIBarStyleBlack;
    toolBar.translucent = YES;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backBtnHandler)];
    //
    UIImage *imgForNormal = [UIImage imageNamed:@"blueBtnBgNormal"];
    stretchImgForNormal = [imgForNormal resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 11, 11)];
    UIImage *imgForPress = [UIImage imageNamed:@"blueBtnBgPress"];
    stretchImgForPress = [imgForPress resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 11, 11)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backBtnHandler
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    //监听键盘
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    //[self setNeedsStatusBarAppearanceUpdate];
}

//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}
//
//- (BOOL)prefersStatusBarHidden
//{
//    return NO;
//}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    keyboardHeight = keyboardSize.height;
    
    //NSValue *durationValue = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIView *firstResponderView = [keyWindow findFirstResponder];
    
    if(firstResponderView.frame.origin.y + firstResponderView.frame.size.height > (self.view.frame.size.height-(keyboardHeight-distanceToMove)))
    {
        //NSTimeInterval timeInterval;
        //[durationValue getValue:&timeInterval];
        [UIView beginAnimations:@"animation" context:nil];
        [UIView setAnimationDuration:0.25f];
        CGRect frame = self.view.frame;
        
        int moveLen = firstResponderView.frame.origin.y + firstResponderView.frame.size.height - (self.view.frame.size.height-(keyboardHeight-distanceToMove));
        distanceToMove += moveLen;
        frame.origin.y -= moveLen;
        self.view.frame = frame;
        [UIView commitAnimations];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:0.30f];
    CGRect frame = self.view.frame;
    frame.origin.y += distanceToMove;
    self.view.frame = frame;
    distanceToMove = 0;
    [UIView commitAnimations];
}

//
- (void)closeKeyboardHandler
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    //UIView *firstResponderView = [keyWindow.rootViewController.view findFirstResponder];
    UIView *firstResponderView = [keyWindow findFirstResponder];
    [firstResponderView resignFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
