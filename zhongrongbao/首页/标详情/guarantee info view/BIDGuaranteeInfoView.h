//
//  BIDGuaranteeInfoView.h
//  zhongrongbao
//
//  Created by mal on 14-9-11.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BIDCarMortgageView;
@class BIDRoomMortgageView;

@protocol BIDGuaranteeInfoViewDelegate <NSObject>

- (void)refreshGuaranteeInfoView;

@end

@interface BIDGuaranteeInfoView : UIView
{
    BOOL _bExpanded;
    BIDCarMortgageView *_carMortgageView;
    BIDRoomMortgageView *_roomMortgageView;
    IBOutlet UILabel *_lineLabel;
}

/**
 *担保方
 */
@property (strong, nonatomic) IBOutlet UILabel *securedPartyLabel;
/**
 *保障
 */
@property (strong, nonatomic) IBOutlet UILabel *guaranteeLabel;
/**
 *双重保障
 */
@property (strong, nonatomic) IBOutlet UILabel *doubleGuaranteeLabel;
/**
 *
 */
@property (strong, nonatomic) IBOutlet UIButton *btn;
/**
 *
 */
@property (strong, nonatomic) IBOutlet UIImageView *imgView;
/**
 *
 */
@property (assign, nonatomic) id<BIDGuaranteeInfoViewDelegate> delegate;

- (IBAction)btnDownHandler:(id)sender;

- (void)initView;

@end
