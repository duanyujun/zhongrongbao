//
//  BIDWithdrawalFooterView.h
//  zhongrongbao
//
//  Created by mal on 14-9-2.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIDWithdrawalFooterView : UIView

@property (strong, nonatomic) IBOutlet UILabel *hintLabel;

- (void)refreshFooterView:(NSString*)strHint;

@end
