//
//  BIDSystemAboutViewController.h
//  zhongrongbao
//
//  Created by mal on 14/11/12.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDBaseViewController.h"

@interface BIDSystemAboutViewController : BIDBaseViewController
{
    /**
     *当前版本号
     */
    IBOutlet UILabel *_curVersionLabel;
    /**
     *更新版本
     */
    IBOutlet UIButton *_updateBtn;
    /**
     *新版本介绍
     */
    IBOutlet UIButton *_describeBtn;
}
/**
 *更新版本
 */
- (IBAction)updateBtnHandler:(id)sender;
/**
 *新版本介绍
 */
- (IBAction)descriptionBtnHandler:(id)sender;

/**
 *官网
 */
- (IBAction)toWebsite:(id)sender;
/**
 *免责声明
 */
- (IBAction)toDisclaimer:(id)sender;
/**
 *隐私声明
 */
- (IBAction)toPrivacyStatement:(id)sender;
/**
 *微博
 */
- (IBAction)toWeibo:(id)sender;

@end
