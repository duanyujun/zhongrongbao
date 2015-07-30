//
//  BIDEnterpriseBriefIntroductionView.h
//  zhongrongbao
//
//  Created by mal on 14-9-10.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BIDEnterpriseBriefIntroductionViewDelegate <NSObject>

- (void)refreshEnterpriseBriefIntroduction;

@end

@interface BIDEnterpriseBriefIntroductionView : UIView
{
    /**
     *完整的介绍
     */
    NSString *_wholeIntroduction;
    /**
     *部分介绍
     */
    NSString *_partialIntroduction;
}

@property (assign, nonatomic) id<BIDEnterpriseBriefIntroductionViewDelegate> delegate;

@property (copy, nonatomic) NSString *enterpriseBriefIntroduction;

@property (strong, nonatomic) IBOutlet UILabel *lineLabel;
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) IBOutlet UIButton *btn;

- (IBAction)btnDownHandler:(id)sender;

@end
