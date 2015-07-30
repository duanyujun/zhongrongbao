//
//  BIDFinancialStatusView.h
//  zhongrongbao
//
//  Created by mal on 14-9-11.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIDFinancialStatusView : UIView
{
    IBOutlet UIScrollView *_myScrollView;
}

- (void)initViewWithArr:(NSArray*)arr;

@end
