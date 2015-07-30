//
//  BIDRepaymentPlanView.h
//  zhongrongbao
//
//  Created by mal on 14-9-12.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIDRepaymentPlanView : UIView
{
    IBOutlet UIScrollView *_myScrollView;
}

- (void)initViewWithTitles:(NSArray*)titleArr infoArr:(NSArray*)infoArr;

@end
