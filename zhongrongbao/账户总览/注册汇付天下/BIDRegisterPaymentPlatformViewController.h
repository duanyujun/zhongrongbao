//
//  BIDRegisterPaymentPlatformViewController.h
//  zhongrongbao
//
//  Created by mal on 14-10-6.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BIDBaseViewController.h"

@interface BIDRegisterPaymentPlatformViewController : BIDBaseViewController
{
    IBOutlet UIWebView *_webView;
}

/**
 *汇付天下注册的url
 */
@property (copy, nonatomic) NSString *registerURL;

@end
