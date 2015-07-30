//
//  BIDEditMobilePhoneNumberFirstStepViewController.h
//  zhongrongbao
//
//  Created by mal on 15/6/28.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import "BIDBaseViewController.h"

@interface BIDEditMobilePhoneNumberFirstStepViewController : BIDBaseViewController
{
    IBOutlet UITextField *_mobilePhoneNumberTF;
}

/**
 *原绑定手机号码
 */
@property (copy, nonatomic) NSString *oldBindingMobilePhoneNumber;

@end
