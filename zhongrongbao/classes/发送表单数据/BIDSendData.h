//
//  BIDSendData.h
//  mashangban
//
//  Created by mal on 14-6-23.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BIDPassValueDelegate.h"

@protocol BIDSendDataDelegate<NSObject>
- (void)passData:(NSData*)data;
@end

@class BIDCustomSpinnerView;

@interface BIDSendData : NSObject<NSURLConnectionDelegate, NSURLConnectionDataDelegate, UIAlertViewDelegate>

@property (strong, nonatomic)NSURLConnection *urlConnection;
@property (strong, nonatomic)NSMutableURLRequest *urlRequest;
@property (strong, nonatomic)NSMutableData *contentData;
@property (copy, nonatomic)NSString *strTitle;
@property (strong, nonatomic)BIDCustomSpinnerView *spinnerView;
@property (strong, nonatomic)NSObject<BIDPassValueDelegate> *delegate;
@property (assign, nonatomic)NSObject<BIDSendDataDelegate> *sendDataDelegate;
@property (strong, nonatomic)NSMutableData *receiveData;

- (id)initDataWithURL:(NSString*)strURL strText:(NSString*)strText;
//以字符串填充
- (void)addData:(NSString*)strKey value:(NSString*)strValue;
//以NSData填充
- (void)addData1:(NSString *)strKey value:(NSData*)data;
- (void)addEndBoundary;
- (void)finishAddData;
- (void)startExecute;

@end
