//
//  BIDWebPageJumpViewController.h
//  zhongrongbao
//
//  Created by mal on 14-10-16.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIDWebPageJumpViewController : UIViewController
{
    IBOutlet UIWebView *_webView;
}

@property (copy, nonatomic) NSString *desURL;
@property (copy, nonatomic) NSString *navTitle;

@end
