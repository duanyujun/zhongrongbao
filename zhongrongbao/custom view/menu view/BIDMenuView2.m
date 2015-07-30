//
//  BIDMenuView2.m
//  shangwuting
//
//  Created by mal on 13-12-20.
//  Copyright (c) 2013年 mal. All rights reserved.
//

#import "BIDMenuView2.h"

@implementation BIDMenuView2

@synthesize bgView;
@synthesize btnsArr;
@synthesize titlesArr;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame arr:(NSArray *)arr
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        titlesArr = [NSArray arrayWithArray:arr];
        btnsArr = [[NSMutableArray alloc] initWithCapacity:[titlesArr count]];
        [self initView];
    }
    return self;
}

- (id)initWithTitleArr:(NSArray *)arr
{
    self = [super init];
    if (self) {
        // Initialization code
        titlesArr = [NSArray arrayWithArray:arr];
        btnsArr = [[NSMutableArray alloc] initWithCapacity:[titlesArr count]];
        [self initView];
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

- (void)initView
{
    [self setBackgroundColor:[UIColor clearColor]];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    [bgView setBackgroundColor:[UIColor colorWithWhite:0.5 alpha:0.5]];
    
    CGSize btnSize = CGSizeMake(300, 30);
    CGSize labelSize = CGSizeMake(300, 1);
    CGRect btnFrame;
    UIButton *newBtn;
    UIButton *btn;
    for(int i=0; i<titlesArr.count; i++)
    {
        newBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        newBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        newBtn.tag = i;
        
        [newBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [newBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [newBtn setTitle:[titlesArr objectAtIndex:i] forState:UIControlStateNormal];
        [newBtn setBackgroundColor:[UIColor whiteColor]];
        if(i==0)
        {
            btnFrame = CGRectMake(0, 0, btnSize.width, btnSize.height);
        }
        else
        {
            btn = (UIButton*)btnsArr[i-1];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, btn.frame.origin.y+btn.frame.size.height, labelSize.width, labelSize.height)];
            [label setBackgroundColor:[UIColor lightGrayColor]];
            [self addSubview:label];
            btnFrame = CGRectMake(0, label.frame.origin.y+label.frame.size.height, btnSize.width, btnSize.height);
        }
        newBtn.frame = btnFrame;
        [btnsArr addObject:newBtn];
        [self addSubview:newBtn];
    }
    btn = (UIButton*)btnsArr[btnsArr.count-1];
    newBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [newBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [newBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    newBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    newBtn.tag = btnsArr.count;
    [newBtn setTitle:@"取消" forState:UIControlStateNormal];
    newBtn.frame = CGRectMake(0, btn.frame.origin.y+btn.frame.size.height+10, btnSize.width, btnSize.height);
    [newBtn setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:newBtn];
    [btnsArr addObject:newBtn];
    
    int height = [btnsArr count]*btnSize.height + (btnsArr.count-2)*labelSize.height + 10 + 5;
    CGRect ownFrame = CGRectMake(10, screenSize.height, 300, height);
    self.frame = ownFrame;
}

- (void)showMenuView
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:bgView];
    [keyWindow addSubview:self];
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:0.5f];
    CGRect ownFrame = self.frame;
    ownFrame.origin.y = screenSize.height - self.frame.size.height;
    self.frame = ownFrame;
    [UIView commitAnimations];
}

- (void)dismissMenuView
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    [UIView beginAnimations:@"hideAnimation" context:nil];
    [UIView setAnimationDuration:0.5f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationStop:finished:context:)];
    CGRect ownFrame = self.frame;
    ownFrame.origin.y = screenSize.height;
    self.frame = ownFrame;
    [UIView commitAnimations];
}
                                                  
- (void)animationStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [bgView removeFromSuperview];
    [self removeFromSuperview];
}

@end
