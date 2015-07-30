//
//  BIDBaseViewControllerII.m
//  zhongrongbao
//
//  Created by mal on 15/6/27.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import "BIDBaseViewControllerII.h"

@interface BIDBaseViewControllerII ()
{
    UIActivityIndicatorView *_spinnerView;
}
@end

@implementation BIDBaseViewControllerII

@synthesize bNetworkConnecting;
@synthesize toolBar;
@synthesize distanceToMove;
@synthesize keyboardHeight;
@synthesize networkConnectionArr;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self initToolBarForKeyboard];
    networkConnectionArr = [[NSMutableArray alloc] init];
    //
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    _spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGRect frame = _spinnerView.frame;
    frame.origin.x = (screenSize.width-frame.size.width)/2;
    frame.origin.y = (screenSize.height-frame.size.height)/2-64;
    _spinnerView.frame = frame;
}

- (void)initToolBarForKeyboard
{
    //toolBar
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGSize toolBarSize = CGSizeMake(screenSize.width, 30);
    CGRect toolBarFrame = CGRectMake(0, 0, toolBarSize.width, toolBarSize.height);
    toolBar = [[UIToolbar alloc] initWithFrame:toolBarFrame];
    toolBar.tintColor = [UIColor whiteColor];
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"关闭键盘" style:UIBarButtonItemStyleBordered target:self action:@selector(closeKeyboardHandler)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolBar setItems:[[NSArray alloc] initWithObjects:item2, item1, nil]];
    toolBar.barStyle = UIBarStyleBlack;
    toolBar.translucent = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    UINavigationController *navController = self.navigationController;
    if(navController)
    {
        if([navController.viewControllers containsObject:self])
        {
        }
        else
        {
            //取消正在进行的网络请求
            for(NSURLConnection *connection in networkConnectionArr)
            {
                if(connection) [connection cancel];
            }
        }
    }
}

- (void)showSpinnerView
{
    if(_spinnerView)
    {
        [self.view addSubview:_spinnerView];
        [_spinnerView startAnimating];
    }
}

- (void)hideSpinnerView
{
    if(_spinnerView)
    {
        [_spinnerView stopAnimating];
        [_spinnerView removeFromSuperview];
    }
}

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

@end
