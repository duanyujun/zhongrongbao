//
//  BIDResponseView.m
//  mashangban
//
//  Created by mal on 14-8-15.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDResponseView.h"

@implementation BIDResponseView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setResponse:(NSString *)response1
{
    _response = response1;
    [_responseLabel setText:response1];
}

- (void)setImgName:(NSString *)imgName1
{
    _imgName = imgName1;
    [_imgView setImage:[UIImage imageNamed:imgName1]];
}

@end
