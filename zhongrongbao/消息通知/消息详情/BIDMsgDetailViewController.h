//
//  BIDMsgDetailViewController.h
//  zhongrongbao
//
//  Created by mal on 14/12/26.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDBaseViewController.h"

@interface BIDMsgDetailViewController : BIDBaseViewController
{
    IBOutlet UILabel *_titleLabel;
    IBOutlet UITextView *_contentTextView;
}

@property (copy, nonatomic) NSString *msgTitle;
@property (copy, nonatomic) NSString *msgDate;
@property (copy, nonatomic) NSString *msgContent;

@end
