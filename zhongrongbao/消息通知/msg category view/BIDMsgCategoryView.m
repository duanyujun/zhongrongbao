//
//  BIDMsgCategoryView.m
//  zhongrongbao
//
//  Created by mal on 14/12/26.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDMsgCategoryView.h"

@interface BIDMsgCategoryView()
{
    NSMutableArray *_btnArr;
    NSMutableArray *_labelArr;
    NSArray *_titleArr;
    UIColor *grayColor;
    UIColor *redColor;
}

@end

@implementation BIDMsgCategoryView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        _btnArr = [[NSMutableArray alloc] init];
        _labelArr = [[NSMutableArray alloc] init];
        _titleArr = @[@"用户消息", @"系统消息", @"广播"];
        grayColor = [UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f];
        redColor = [UIColor colorWithRed:231.0f/255.0f green:76.0f/255.0f blue:60.0f/255.0f alpha:1.0f];
        //
        [self initView];
    }
    return self;
}

- (void)initView
{
    CGRect ownFrame = self.frame;
    CGFloat width = ownFrame.size.width/3;
    CGFloat height = ownFrame.size.height;
    for(int i=0; i<3; i++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundColor:[UIColor clearColor]];
        btn.frame = CGRectMake(i*width, 0, width, height);
        [btn setTitle:_titleArr[i] forState:UIControlStateNormal];
        [btn setTitleColor:grayColor forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
        btn.tag = i;
        [btn addTarget:self action:@selector(btnDownHandler:) forControlEvents:UIControlEventTouchUpInside];
        [_btnArr addObject:btn];
        [self addSubview:btn];
        //
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i*width, height-1, width, 1)];
        [label setBackgroundColor:[UIColor clearColor]];
        [_labelArr addObject:label];
        [self addSubview:label];
    }
}

- (void)btnDownHandler:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    [delegate chooseCategoryWithIndex:btn.tag];
    [btn setTitleColor:redColor forState:UIControlStateNormal];
    UILabel *label = _labelArr[btn.tag];
    [label setBackgroundColor:redColor];
    for(int i=0; i<_btnArr.count; i++)
    {
        UIButton *btn1 = (UIButton*)(_btnArr[i]);
        UILabel *label1 = (UILabel*)(_labelArr[i]);
        if(btn.tag == btn1.tag)
        {
            continue;
        }
        [btn1 setTitleColor:grayColor forState:UIControlStateNormal];
        [label1 setBackgroundColor:[UIColor clearColor]];
    }
}

- (void)changeStateByIndex:(NSInteger)index
{
    for(int i=0; i<_btnArr.count; i++)
    {
        UIButton *btn = (UIButton*)(_btnArr[i]);
        UILabel *label = (UILabel*)(_labelArr[i]);
        if(btn.tag == index)
        {
            [btn setTitleColor:redColor forState:UIControlStateNormal];
            [label setBackgroundColor:redColor];
        }
        else
        {
            [btn setTitleColor:grayColor forState:UIControlStateNormal];
            [label setBackgroundColor:[UIColor clearColor]];
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
