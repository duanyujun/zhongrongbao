//
//  BIDResponseView.h
//  mashangban
//
//  Created by mal on 14-8-15.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIDResponseView : UIView
{
    IBOutlet UIImageView *_imgView;
    IBOutlet UILabel *_responseLabel;
}

@property (copy, nonatomic) NSString *imgName;
@property (copy, nonatomic) NSString *response;

@end
