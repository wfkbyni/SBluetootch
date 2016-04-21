//
//  HttpClient.h
//  Collector
//
//  Created by pactera on 15/4/21.
//  Copyright (c) 2015年 panderman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModelLib.h"
#import "AFNetworking.h"


typedef NS_ENUM(NSUInteger, HttpClientRequestMethod){
    HttpClientRequestMethodGet = 0,
    HttpClientRequestMethodPost
};

@class AFHTTPRequestOperation;
@protocol HttpClientFileProtocol;

typedef void(^successBlock)(AFHTTPRequestOperation *operation, id responseObject);
typedef void(^failureBlock)(AFHTTPRequestOperation *operation, NSError *error);
typedef void(^successResultBlock)(id result);

@class JGProgressHUD;
@interface HttpClientHelper : NSObject

@property (nonatomic,weak) UIView *showHUDView;

+ (instancetype)sharedInstance;

- (void)cancelAllRequest;

- (void)post:(NSString *)url resultType:(Class)resultType parameters:(NSDictionary *)parameters success:(successResultBlock)success failure:(failureBlock)failure showLoading:(BOOL)showLoading;

- (void)postWithFiles:(NSString *)url resultType:(Class)resultType parameters:(NSDictionary *)parameters files:(NSArray *)files success:(successResultBlock)success failure:(failureBlock)failure showLoading:(BOOL)showLoading;

- (void)get:(NSString *)url parameters:(NSDictionary *)parameters
    success:(void (^)(NSString* result))success
    failure:(failureBlock)failure showLoading:(BOOL)showLoading;

#pragma mark 请求服务器返回字符串
//请求服务器返回字符串
- (void)request:(HttpClientRequestMethod)requestMthoed
                  url:(NSString *)url
           parameters:(NSDictionary *)parameters
                files:(NSArray *)files
              success:(successBlock)success
              failure:(failureBlock)failure showLoading:(BOOL)showLoading;


@end
