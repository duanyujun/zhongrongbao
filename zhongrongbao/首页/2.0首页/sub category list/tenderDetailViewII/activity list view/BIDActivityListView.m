//
//  BIDActivityListView.m
//  zhongrongbao
//
//  Created by mal on 15/7/13.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import "BIDActivityListView.h"

@interface BIDActivityListView()<UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_dataSourceArr;
}
@end

@implementation BIDActivityListView
@synthesize delegate;
@synthesize activityType;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        _dataSourceArr = [[NSMutableArray alloc] init];
        _tableView = [[UITableView alloc] initWithFrame:self.bounds];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [self addSubview:_tableView];
    }
    return self;
}

- (void)setDataSourceArr:(NSArray *)arr
{
    [_dataSourceArr setArray:arr];
    [_tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSourceArr.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    static NSString *identifier = @"identifier";
    NSUInteger row = indexPath.row;
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSDictionary *dic = _dataSourceArr[row];
    cell.textLabel.text = dic[@"actName"];
    cell.textLabel.font = [UIFont systemFontOfSize:20.0f];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self removeFromSuperview];
    NSUInteger row = indexPath.row;
    NSDictionary *dic = _dataSourceArr[row];
    NSString *strActName = dic[@"actName"];
    NSString *strActId = dic[@"id"];
    switch(activityType)
    {
        case ACTIVITY_REDPACKET:
        {
            [delegate selectActivityForRedPacketWithName:strActName activityId:strActId];
        }
            break;
        case ACTIVITY_TIYANJIN:
        {
            [delegate selectActivityForTiYanJinWithName:strActName activityId:strActId];
        }
            break;
    }
}

@end
