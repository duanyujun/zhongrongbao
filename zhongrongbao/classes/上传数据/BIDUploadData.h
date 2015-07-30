//
//  BIDUploadData.h
//  shangwuting
//
//  Created by mal on 14-1-7.
//  Copyright (c) 2014年 mal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BIDPassValueDelegate.h"
@class BIDCustomSpinnerView;

@interface BIDUploadData : NSObject<NSURLConnectionDelegate, NSURLConnectionDataDelegate, UIAlertViewDelegate>
@property (strong, nonatomic)NSURLConnection *urlConnection;
@property (strong, nonatomic)NSMutableURLRequest *urlRequest;
@property (strong, nonatomic)NSMutableData *contentData;
@property (copy, nonatomic)NSString *strTitle;
@property (strong, nonatomic)BIDCustomSpinnerView *spinnerView;
@property (strong, nonatomic)NSObject<BIDPassValueDelegate> *delegate;

- (id)initData:(NSString*)strURL strText:(NSString*)strText;
//以字符串填充
- (void)addData:(NSString*)strKey value:(NSString*)strValue;
//以NSData填充
- (void)addData1:(NSString *)strKey value:(NSData*)data;
- (void)addEndBoundary;
- (void)finishAddData;
- (void)startExecute;

@end
