//
//  BIDDataCommunication.h
//  党务通
//
//  Created by mal on 13-11-23.
//  Copyright (c) 2013年 mal. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ROWS_PER_PAGE 5

@protocol BIDDataCommunicationDelegate <NSObject>
- (void)connectionCanceled;
@end

@interface BIDDataCommunication : NSObject

@property (copy, nonatomic) NSString *destinationURL;
@property (assign, nonatomic) id<BIDDataCommunicationDelegate> delegate;
@property (copy, nonatomic) void (^completionHandler)(id obj);

+ (BIDDataCommunication*)getInstance;

- (id)initWithURL:(NSString*)strURL;

//以get方式提交数据
- (void)uploadDataByGetToURL:(NSString*)strURL toDictionary:(NSMutableDictionary *)desDictionary;
//以post方式提交数据
- (NSURLConnection*)uploadDataByPostToURL:(NSString*)strURL postValue:(NSString*)postValue completionHandler:(void (^)(id obj))completionHandler1;

//以get方式提交数据
+ (int)uploadDataByGetToURL:(NSString*)strURL toDictionary:(NSMutableDictionary *)desDictionary;

//以post方式提交数据
+ (int)uploadDataByPostToURL:(NSString*)strURL postValue:(NSString*)postValue toDictionary:(NSMutableDictionary*)desDictionary;
+ (int)uploadDataByPostWithoutCookie:(NSString*)strURL postValue:(NSString*)postValue toDictionary:(NSMutableDictionary*)desDictionary;
+ (int)uploadDataByPostWithoutCookie:(NSString*)strURL postValue:(NSString*)postValue curPage:(NSInteger)pageNumber toArr:(NSMutableArray*)desArr;

//分页获取数据
+ (int)getDataFromNet:(NSString*)strURL toArray:(NSMutableArray*)desArr page:(int)pageNumber;

//不需要分页
+ (int)getDataFromNet:(NSString*)strURL toDictionary:(NSMutableDictionary*)desDictionary;

+ (int)getDataFromNet:(NSString*)strURL data:(NSMutableData*)desData;

+ (void)setCountPerPage:(int)count;
+ (int)getCountPerPage;

@end
