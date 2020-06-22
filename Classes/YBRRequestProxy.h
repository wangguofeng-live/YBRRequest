//
//  YBRRequestProxy.h
//  YBRInsiderApp
//
//  Created by bdkj on 2018/4/27.
//  Copyright © 2018年 BDKJ_Hbb. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YBRRequest;
@class YBRResponse;

@interface YBRRequestProxy : NSObject

@property (readonly) id response;

// Start the asynchronous request
- (void)request:(YBRRequest *)request
        Success:(void(^)(YBRResponse* argResponse))argSuccess
        Failure:(void(^)(YBRResponse* argResponse, NSError* argError))argFailure;


//- (void)uploadRequest:(YBRRequest<YBRUploadFormable> *)request
//              Success:(void(^)(YBRResponse* argResponse))argSuccess
//              Failure:(void(^)(YBRResponse* argResponse, NSError* argError))argFailure;

- (void)downloadWithURL:(NSString*)argURL
                Success:(void(^)(void))argSuccess;

#pragma mark - 检查网络是否通畅
- (BOOL)checkNetworkConnection;

@end
