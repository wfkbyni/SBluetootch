//
//  HttpClient.m
//  Collector
//
//  Created by pactera on 15/4/21.
//  Copyright (c) 2015年 panderman. All rights reserved.
//

#import "HttpClientHelper.h"
#import "HttpClientFileModel.h"

@interface HttpClientHelper ()

@property (nonatomic,strong) NSString *baseUrl;

@property (nonatomic,strong) JGProgressHUD *hud;

@end

//static HttpClientHelper *helper = nil;

@implementation HttpClientHelper

- (void)cancelAllRequest{
    [self.hud dismiss];
    [[AFHTTPRequestOperationManager manager].operationQueue cancelAllOperations];
}

+ (instancetype)sharedInstance{
    static HttpClientHelper *result = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        result = [HttpClientHelper new];
        result.baseUrl = [NSString stringWithFormat:@"http://%@",serverurl];
        result.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    });
    return result;
}

- (void)post:(NSString *)url resultType:(Class)resultType parameters:(NSDictionary *)parameters success:(successResultBlock)success failure:(failureBlock)failure showLoading:(BOOL)showLoading{
    [self postWithFiles:url resultType:resultType parameters:parameters files:nil success:success failure:failure showLoading:showLoading];
}

- (void)postWithFiles:(NSString *)url resultType:(Class)resultType parameters:(NSDictionary *)parameters files:(NSArray *)files success:(successResultBlock)success failure:(failureBlock)failure showLoading:(BOOL)showLoading{
    
    void (^resultBlockVar)(AFHTTPRequestOperation*, NSString*) = ^(AFHTTPRequestOperation *operation, id responseObject){
        if (!success) {
            return;
        }
        if (resultType == [NSString class]) {
            success(responseObject);
            return;
        }
        NSAssert([NSJSONSerialization isValidJSONObject:responseObject], @"非json格式！");
        if ([resultType isKindOfClass:[NSArray class]]) {
            NSArray *arrayResult = [JSONModel arrayOfModelsFromDictionaries:responseObject];
            success(arrayResult);
        }else{
            NSError *jsonParseError;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:&jsonParseError];
            JSONModel *modelResult = [[resultType alloc] initWithData:jsonData error:&jsonParseError];
            NSAssert(!jsonParseError, [jsonParseError description]);
            success(modelResult);
        }
        return;
    };
    
    [self request:HttpClientRequestMethodPost url:url parameters:parameters files:files success:resultBlockVar failure:failure showLoading:showLoading];
}



- (void)get:(NSString *)url parameters:(NSDictionary *)parameters success:(void (^)(NSString* result))success failure:(failureBlock)failure showLoading:(BOOL)showLoading{
    [self request:HttpClientRequestMethodGet url:url parameters:parameters files:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        success(responseObject);
    }failure:failure showLoading:showLoading];
    
}

- (void)request:(HttpClientRequestMethod)requestMthoed
                  url:(NSString *)url
           parameters:(NSDictionary *)parameters
                files:(NSArray *)files
              success:(successBlock)success
        failure:(failureBlock)failure showLoading:(BOOL)showLoading{
    [self.hud dismiss];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/html",@"application/json", @"text/json", @"text/javascript",@"application/x-javascript", nil];
    
    void (^successVar)(AFHTTPRequestOperation*, id) = ^(AFHTTPRequestOperation *operation, id responseObject){
        if (self) {
            [self.hud dismiss];
        }
        NSString *responseString = operation.responseString;
        if (!responseString && operation.responseData.length > 0) {
            responseString = [[NSString alloc] initWithData:operation.responseData encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
        }
        if (responseString.length) {
            DebugLog(@"\n%@",responseString);
        }
        if (success) {
            if (responseObject == nil) {
                success(operation,responseString);
            }else{
                success(operation,responseObject);
            }
        }
    };
    void (^failureVar)(AFHTTPRequestOperation*, NSError*) = ^(AFHTTPRequestOperation *operation, NSError *error){
        if (self && showLoading) {
            self.hud.textLabel.text = @"请求错误!";
            self.hud.indicatorView = [[JGProgressHUDErrorIndicatorView alloc] init];
            self.hud.square = YES;
            [self.hud show];
            [self.hud dismissAfterDelay:3.0];
        }
        if (error) {
            DebugLog(@"error ------ %@",error);
        }
        if(failure){
            failure(operation,error);
        }
    };
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",self.baseUrl,url];
    DebugLog(@"url:%@",requestUrl);
    self.hud.indicatorView = nil;
    if(requestMthoed == HttpClientRequestMethodPost){
        //如果存在文件
        if (files && files.count > 0) {
            if (showLoading) {
                self.hud.indicatorView = [[JGProgressHUDRingIndicatorView alloc] initWithHUDStyle:self.hud.style];
                [self.hud show];
            }
            AFHTTPRequestOperation *reqeustOperation = [manager POST:requestUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                if (!files || files.count == 0) {
                    return;
                }
                for (HttpClientFileModel *file in files) {
                    if (file == (id)[NSNull null]) {
                        continue;
                    }
                    [formData appendPartWithFileData:file.fileData
                                                name:file.requestFileName
                                            fileName:file.fileName
                                            mimeType:file.mimeType];
                }
            } success:successVar failure:failureVar];
            //显示进度
            [reqeustOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
                if (!self) {
                    return;
                }
                CGFloat percent = totalBytesWritten/(CGFloat)totalBytesExpectedToWrite;
                
                self.hud.detailTextLabel.text = [NSString stringWithFormat:@"%lu%%",(unsigned long)(percent * 100)];
                [self.hud setProgress:percent animated:YES];
                
                self.hud.layoutChangeAnimationDuration = 0.0;
            }];
            
        }else{
            if (showLoading) {
                self.hud.indicatorView = [[JGProgressHUDIndeterminateIndicatorView alloc] initWithHUDStyle:self.hud.style];
                self.hud.detailTextLabel.text = nil;
                self.hud.textLabel.text = nil;
                [self.hud show];
            }
            //否则使用普通上传
            [manager POST:requestUrl parameters:parameters success:successVar failure:failureVar];
        }
        
    }else{
        if (showLoading) {
            self.hud.indicatorView = [[JGProgressHUDIndeterminateIndicatorView alloc] initWithHUDStyle:self.hud.style];
            self.hud.detailTextLabel.text = nil;
            self.hud.textLabel.text = nil;
            [self.hud show];
        }
        [manager GET:requestUrl parameters:parameters success:successVar failure:failureVar];
    }
}

@end
