//
//  BIDMsgDetailViewController.m
//  zhongrongbao
//
//  Created by mal on 14/12/26.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDMsgDetailViewController.h"
#import "BIDManagerInNavViewController.h"

@interface BIDMsgDetailViewController ()

@end

@implementation BIDMsgDetailViewController
@synthesize msgContent;
@synthesize msgTitle;
@synthesize msgDate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = msgTitle;
    _titleLabel.text = msgDate;
    _contentTextView.text = msgContent;
    [_contentTextView setFont:[UIFont systemFontOfSize:17.0f]];
    [_contentTextView setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if(parent && [parent isKindOfClass:[BIDManagerInNavViewController class]])
    {
        msgTitle = msgTitle.length==0?@"消息详情":msgTitle;
        parent.navigationItem.title = msgTitle;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
