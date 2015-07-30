//
//  BIDOpenHFTXViewController.h
//  zhongrongbao
//
//  Created by mal on 14-10-16.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDBaseViewController.h"

@interface BIDOpenHFTXViewController : BIDBaseViewController
{
    //开通汇付天下按钮
    IBOutlet UIButton *_openBtn;
    //暂不开通
    IBOutlet UIButton *_noOpenBtn;
}

- (IBAction)openBtnHandler:(id)sender;
- (IBAction)noOpenBtnHandler:(id)sender;

@end
