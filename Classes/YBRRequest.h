//
//  YBRRequest.h
//  BDYBRen
//
//  Created by 杨阳 on 15/5/11.
//  Copyright (c) 2015年 BDKJ_IOS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YBRFormable.h"
#import "YBRRequestFormable.h"
#import "YBRRequestToken.h"

#import "YBRResponse.h"


/**
YBRRequest Error Domain
 
*/
FOUNDATION_EXPORT NSErrorDomain const YBRRequestErrorDomain;

#define YBRRequestErrorDomain_Code_ServiceError 20000 //服务器发送的错误信息
#define YBRRequestErrorDomain_Code_Success_Failure_Dedirect 10300 //成功重定向

typedef NS_ENUM(NSUInteger, YBRResponseHandlerStatus) {
    YBRResponseHandlerStatus_Success,   //成功
    YBRResponseHandlerStatus_Failure,   //失败
    YBRResponseHandlerStatus_Suspend,   //中止
};

typedef void(^YBRRequestSuccessBlock)(YBRResponse* argResponse);
typedef void(^YBRRequestFailureBlock)(YBRResponse* argResponse, NSError* argError);

@class YBRRequest;
@class AFSecurityPolicy;
@protocol YBRRequestParamsProviderProtocol <NSObject>

@optional
- (NSDictionary *)ybr_paramsWithUrl:(NSString*)argUrl andTag:(NSString*)argTag forRequest:(YBRRequest *)request;
- (NSDictionary *)ybr_headersWithUrl:(NSString*)argUrl andTag:(NSString*)argTag forRequest:(YBRRequest *)request;
- (NSDictionary *)ybr_qureyItemsWithUrl:(NSString*)argUrl andTag:(NSString*)argTag forRequest:(YBRRequest *)request;

- (AFSecurityPolicy *)ybr_securityPolicy;

@end

@protocol YBRResponseHandlerProtocol <NSObject>

@optional
- (YBRResponseHandlerStatus)ybr_responseSuccess:(YBRRequest *)argRequest;

/**
 处理失败信息
 return 返回新的错误信息(NSError) 用于替代原有错误信息
 */
- (NSError *)ybr_responseFailure:(YBRRequest *)argRequest Error:(NSError *)argError;

//是否打印信息
- (BOOL)ybr_responsePrint:(YBRRequest *)argRequest;

@end

// This class is a wrapper of ASIFormDataRequest. We use this class to do the
// the webserive request to simplify the code.
@interface YBRRequest : NSObject
<
YBRRequestFormable,
YBRRequestToken
>
{
    NSString* m_strRequestTag;              // Tag to distinguish the request
    NSString* m_strUrl;                     // The URL of the request
    NSMutableDictionary* m_dicParams;              // The parameters
    NSDictionary* m_dicResponse;            // The dictionary after the JASON parsing
    BOOL m_bSilent;                         // If pop up error message when the request failed
    BOOL m_bSucceed;                        // YES if the request succeeded.
}

@property (readonly) NSString* requestTag;
@property (readonly) NSDictionary* response;
@property (assign) BOOL silent;
@property (assign) BOOL succeed;

@property (nonatomic,assign)YBRFormableMethod httpMethod;

/**
 设置参数提供者
 */
+ (void)setupParamsProvider:(id <YBRRequestParamsProviderProtocol>)argParamsProvider;
/**
 设置返回结果处理者
 */
+ (void)setupResponseHandler:(id <YBRResponseHandlerProtocol>)argResponseHandler;

/**
 * 网络请求超时时长
 */
@property (nonatomic , assign) NSTimeInterval timeoutInterval;

#pragma mark - Initialization

/**
 初始化
 BaseUrl 传入完整的BaseUrl
 Tag 标记并会拼接到BaseUrl之后
 */
- (id)initWithBaseUrl:(NSString*)argBaseUrl andTag:(NSString*)argTag;

/**
 初始化
 Url 传入完整的Url
 Tag 只做标记不参与实际请求
 */
- (id)initWithUrl:(NSString*)argUrl andTag:(NSString*)argTag;

// Start the asynchronous request
- (void)StartRequestWithSuccess:(void(^)(YBRRequest* argRequest))argSuccess failure:(void(^)(YBRRequest* argRequest, NSError* argError))argFailure;

// Set the parameters for the request
- (void)SetParamValue:(NSString*)argValue forKey:(NSString *)argKey;

- (void)SetParamValues:(NSDictionary<NSString *,id> *)argParams;

- (void)SetParamData:(NSData*)argValue forKey:(NSString *)argKey;

// Set the image data parameter for the request
- (void)AddImageData:(UIImage*)argImage forKey:(NSString *)argKey;

// Set the mp3 data parameter for the request
- (void)AddMP3Data:(NSData*)argData forKey:(NSString *)argKey;


#pragma mark -
@property (nonatomic, copy)YBRRequestSuccessBlock successBlock;
@property (nonatomic, copy)YBRRequestFailureBlock FailureBlock;

// Start the asynchronous request
- (void)StartGETRequestWithSuccess:(YBRRequestSuccessBlock)argSuccess
                        andFailure:(YBRRequestFailureBlock)argFailure;

- (void)StartPOSTRequestWithSuccess:(YBRRequestSuccessBlock)argSuccess
                         andFailure:(YBRRequestFailureBlock)argFailure;

@end

@interface YBRRequest (ProxyBridge)

- (id)getSecurityPolicy;

- (NSArray *)getFileDataArray;

@end

#pragma mark - Bridge

@interface YBRRequest (Bridge)

// Start the asynchronous request
- (void)StartRequestWithSuccess:(void(^)(YBRRequest* argRequest))argSuccess andFailure:(void(^)(YBRRequest* argRequest, NSString* argError))argFailure;

@end


#pragma mark - Download
@interface YBRRequest (Download)

- (void)downloadWithURL:(NSString*)argURL
                Success:(void(^)(void))argSuccess;

@end
