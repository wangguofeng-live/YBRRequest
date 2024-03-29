//
//  YBRRequest.m
//  BDYBRen
//
//  Created by 杨阳 on 15/5/11.
//  Copyright (c) 2015年 BDKJ_IOS. All rights reserved.
//

#import "YBRRequest.h"

//#import <AFNetworking/AFNetworking.h>

#import "YBRRequestProxy.h"
#import "YBRRequestFileData.h"

#define YBRREQUEST_UPLOAD_TIMEOUTINTERVAL 120 //上传文件请求超时时间
#define YBRREQUEST_DEFAULT_TIMEOUTINTERVAL 20 //默认请求超时时间

#define kWeakSelf(type)   __weak typeof(type) weak##type = type;
#define kStrongSelf(type) __strong typeof(type) type = weak##type;
///是否为空
#define IsNotNilOrNull(obj) (obj && ![obj isEqual:[NSNull null]])
///字符串是否为空
#define IsNotNilOrNullOrEmpty(obj) (IsNotNilOrNull(obj) && ![obj isEqual:@""])

NSErrorDomain const YBRRequestErrorDomain = @"YBRRequestErrorDomain";

@interface YBRRequest ()
{
    BOOL _isBaseUrl;
    NSString* m_strRequestTag;              // Tag to distinguish the request
    NSString* m_strUrl;                     // The URL of the request
    NSMutableDictionary* m_dicHeaders;      // The headers
    NSMutableDictionary* m_dicParams;       // The parameters
    NSDictionary* m_dicResponse;            // The dictionary after the JASON parsing
    BOOL m_bSilent;                         // If pop up error message when the request failed
    BOOL m_bSucceed;                        // YES if the request succeeded.
}

@property (nonatomic, strong)YBRRequestProxy *requestProxy;

@property (nonatomic,strong)NSMutableArray<YBRRequestFileData *> *fileDataArray;

@end

@implementation YBRRequest
@synthesize requestTag = m_strRequestTag;
@synthesize response = m_dicResponse;
@synthesize silent = m_bSilent;
@synthesize succeed = m_bSucceed;

//参数提供者
static id <YBRRequestParamsProviderProtocol> s_pParmsProvider = nil;
//返回结果处理者
static id <YBRResponseHandlerProtocol> s_pResponseHandler = nil;

//设置默认参数
+ (void)setupParamsProvider:(id<YBRRequestParamsProviderProtocol>)argParamsProvider{
    s_pParmsProvider = argParamsProvider;
}
//设置返回结果处理者
+ (void)setupResponseHandler:(id<YBRResponseHandlerProtocol>)argResponseHandler {
    s_pResponseHandler = argResponseHandler;
}

- (id)initWithUrl:(NSString*)argUrl andTag:(NSString*)argTag
{
    if (self = [super init]) {
        _isBaseUrl = NO;
        m_strUrl = argUrl;
        m_strRequestTag = argTag;
        m_dicHeaders = [[NSMutableDictionary alloc] init];
        m_dicParams = [[NSMutableDictionary alloc] init];
        m_dicResponse = nil;
        
        m_bSilent = NO;
        m_bSucceed = NO;
        
        self.timeoutInterval = YBRREQUEST_DEFAULT_TIMEOUTINTERVAL;
        self.httpMethod = YBRFormableMethod_POST;
        
        //填充默认参数
        [self _fillDefaultParams];
        
    }
    return self;
}

- (id)initWithBaseUrl:(NSString *)argBaseUrl andTag:(NSString *)argTag {
    if (self = [super init]) {
        _isBaseUrl = YES;
        m_strUrl = argBaseUrl;
        m_strRequestTag = argTag;
        m_dicHeaders = [[NSMutableDictionary alloc] init];
        m_dicParams = [[NSMutableDictionary alloc] init];
        m_dicResponse = nil;
        
        m_bSilent = NO;
        m_bSucceed = NO;
        
        self.timeoutInterval = YBRREQUEST_DEFAULT_TIMEOUTINTERVAL;
        self.httpMethod = YBRFormableMethod_POST;
        
        //填充默认参数
        [self _fillDefaultParams];
        
    }
    return self;
}


- (void)StartRequestWithSuccess:(void(^)(YBRRequest* argRequest))argSuccess failure:(void(^)(YBRRequest* argRequest, NSError* argError))argFailure
{
    kWeakSelf(self)
    [self StartPOSTRequestWithSuccess:^(YBRResponse *argResponse) {
        kStrongSelf(self);
        if (argSuccess) argSuccess(self);
    } andFailure:^(YBRResponse *argResponse, NSError *argError) {
        kStrongSelf(self);
        if (argFailure) argFailure(self, argError);
    }];
}

#pragma mark -
- (void)SetParamValue:(NSString*)argValue forKey:(NSString *)argKey {
    // Set the normal parameter
    /**
     此处进行了修改
     1, setObject：forkey：中value是不能够为nil的，不然会报错。
     setValue：forKey：中value能够为nil，但是当value为nil的时候，会自动调用removeObject：forKey方法
     2, setValue：forKey：中key的参数只能够是NSString类型，而setObject：forKey：的可以是任何类型
     */
    [m_dicParams setValue:argValue forKey:argKey];
}

- (void)SetParamValuesForKeysWithDictionary:(NSDictionary*)argDic forKey:(NSString *)argKey {
    [m_dicParams setValue:argDic forKey:argKey];
}

- (void)SetParamValuesForKeysWithArray:(NSArray*)argArray forKey:(NSString *)argKey {
    [m_dicParams setValue:argArray forKey:argKey];
}

- (void)SetParamValues:(NSDictionary<NSString *,id> *)argParams {
    [m_dicParams setValuesForKeysWithDictionary:argParams];
}

- (void)SetParamData:(NSData*)argValue forKey:(NSString *)argKey {
    [m_dicParams setObject:argValue forKey:argKey];
}

- (void)AddImageData:(UIImage*)argImage forKey:(NSString *)argKey
{
    //合成FileData
    NSData* pImgData = UIImageJPEGRepresentation(argImage, 0.3);
    
    YBRRequestFileData *fileData = [YBRRequestFileData new];
    fileData.name = argKey;
    fileData.fileData = pImgData;
    fileData.mimeType = @"image/jpg";
    fileData.fileName = [NSString stringWithFormat:@"%@.jpg", argKey];
    
    [self.fileDataArray addObject:fileData];
    self.timeoutInterval = YBRREQUEST_UPLOAD_TIMEOUTINTERVAL;
}

- (void)AddMP3Data:(NSData*)argData forKey:(NSString *)argKey
{
    //合成FileData
    YBRRequestFileData *fileData = [YBRRequestFileData new];
    fileData.name = argKey;
    fileData.fileData = argData;
    fileData.mimeType = @"audio/*";
    fileData.fileName = [NSString stringWithFormat:@"%@.mp3", argKey];
    
    [self.fileDataArray addObject:fileData];
    self.timeoutInterval = YBRREQUEST_UPLOAD_TIMEOUTINTERVAL;
}

- (void)SetHeaderValue:(NSString*)argValue forKey:(NSString *)argKey {
    [m_dicHeaders setObject:argValue forKey:argKey];
}

- (void)SetHeaderValues:(NSDictionary<NSString *,id> *)argHeaders {
    [m_dicHeaders setValuesForKeysWithDictionary:argHeaders];
}

#pragma mark -
- (void)StartGETRequestWithSuccess:(YBRRequestSuccessBlock)argSuccess
                        andFailure:(YBRRequestFailureBlock)argFailure {
    
    self.successBlock = argSuccess;
    self.FailureBlock = argFailure;
    
    
    YBRRequestProxy *proxy = [YBRRequestProxy new];
    self.requestProxy = proxy;
    [proxy request:self Success:^(YBRResponse *argResponse) {
        
        [self disposeRequestSuccessWihtResponse:argResponse];
        
    } Failure:^(YBRResponse *argResponse, NSError *argError) {
        
        [self disposeRequestFailureWihtResponse:argResponse andError:argError];
        
    }];
}

- (void)StartPOSTRequestWithSuccess:(YBRRequestSuccessBlock)argSuccess
                         andFailure:(YBRRequestFailureBlock)argFailure {
    
    self.FailureBlock = argFailure;
    self.successBlock = argSuccess;
    
    
    YBRRequestProxy *proxy = [YBRRequestProxy new];
    self.requestProxy = proxy;
    [proxy request:self Success:^(YBRResponse *argResponse) {
        
        [self disposeRequestSuccessWihtResponse:argResponse];
        
    } Failure:^(YBRResponse *argResponse, NSError *argError) {
        
        [self disposeRequestFailureWihtResponse:argResponse andError:argError];
        
    }];
}

#pragma mark - Response 统一处理
- (void)disposeRequestSuccessWihtResponse:(YBRResponse *)argResponse {
    
    if (IsNotNilOrNull(argResponse.responseObject)) {
        m_dicResponse = argResponse.responseObject;
    }
    
    //返回信息打印
    if (s_pResponseHandler && [s_pResponseHandler respondsToSelector:@selector(ybr_responsePrint:)]) {
        BOOL bPrint = [s_pResponseHandler ybr_responsePrint:argResponse];
        if (bPrint) {
            NSLog(@"【REQUEST】\nURL:%@ TAG: %@\nSTATUS:SUCCESS\nHEADER: %@\nPARAMS: %@\nDuration: %fs\nJSON: %@", self.url, m_strRequestTag, [self.headers description], [self.parameters description], argResponse.responseDuration, m_dicResponse);
        }
    }
    
    //处理返回结果
    if (s_pResponseHandler && [s_pResponseHandler respondsToSelector:@selector(ybr_responseSuccess:)]) {
        YBRResponseHandlerStatus status = [s_pResponseHandler ybr_responseSuccess:argResponse];
        switch (status) {
            case YBRResponseHandlerStatus_Success:  //成功
                goto REQUEST_SUCCESS;
                break;
            case YBRResponseHandlerStatus_Failure:  //失败
                goto REQUEST_FAILURE;
                break;
            case YBRResponseHandlerStatus_Suspend: //中止
                goto REQUEST_SUSPEND;
                break;
            default:
                break;
        }
    }
    
REQUEST_SUCCESS:       //请求完成
    m_bSucceed = YES;
    if(self.successBlock) self.successBlock(argResponse);
    return;
    
REQUEST_FAILURE:       //请求强制失败
    m_bSucceed = NO;
    
    [self disposeRequestFailureWihtResponse:argResponse andError:[NSError errorWithDomain:YBRRequestErrorDomain code:YBRRequestErrorDomain_Code_Success_Failure_Dedirect userInfo:nil]];
    return;
    
REQUEST_SUSPEND:    //请求中止，不做任何事情
    m_bSucceed = NO;
}

- (void)disposeRequestFailureWihtResponse:(YBRResponse *)argResponse andError:(NSError *)argError {
    m_bSucceed = NO;
    
    //返回信息打印
    if (argError && s_pResponseHandler && [s_pResponseHandler respondsToSelector:@selector(ybr_responsePrint:)]) {
        BOOL bPrint = [s_pResponseHandler ybr_responsePrint:argResponse];
        if (bPrint) {
            NSLog(@"【REQUEST】\nURL:%@ TAG: %@\nSTATUS:FAILURE\nHEADER: %@\nPARAMS: %@\nDuration: %fs\nJSON: %@", self.url, m_strRequestTag, [self.headers description], [self.parameters description], argResponse.responseDuration, [argError localizedDescription]);
        }
    }
    
    //处理返回结果
    if (s_pResponseHandler && [s_pResponseHandler respondsToSelector:@selector(ybr_responseFailure:Error:)]) {
        id obj = [s_pResponseHandler ybr_responseFailure:argResponse Error:argError];
        if ([obj isKindOfClass:[NSError class]]) {

            if(self.FailureBlock) {
                
                self.FailureBlock(argResponse, obj);
            };
        }else if ([obj isEqual:@(YES)]) {
            if(self.FailureBlock) self.FailureBlock(argResponse, argError);
        }
    }
    
}

#pragma mark - private
// 私有方法 填充默认参数
- (void)_fillDefaultParams {
    
    if (s_pParmsProvider && [s_pParmsProvider respondsToSelector:@selector(ybr_paramsWithUrl:andTag:forRequest:)]) {
        NSDictionary *dicParams = [s_pParmsProvider ybr_paramsWithUrl:m_strUrl andTag:m_strRequestTag forRequest:self];
        [self SetParamValues:dicParams];
    }
}

#pragma mark - YBRRequestToken
- (void)Cancel
{
    [self.requestProxy Cancel];
}

- (BOOL)IsRunning {
    return [self.requestProxy IsRunning];
}

#pragma mark - YBRRequestFormable
- (NSString *)url {
    
    if (_isBaseUrl) {
        NSURLComponents *urlComponents = [NSURLComponents componentsWithString:[NSString stringWithFormat:@"%@%@",m_strUrl,m_strRequestTag]];
        
        if (s_pParmsProvider && [s_pParmsProvider respondsToSelector:@selector(ybr_qureyItemsWithUrl:andTag:forRequest:)]) {
            
            NSDictionary *dicQureyItems = [s_pParmsProvider ybr_qureyItemsWithUrl:m_strUrl andTag:m_strRequestTag forRequest:self];
            
            NSMutableArray<NSURLQueryItem *> *arrQureyItems = [NSMutableArray array];
            
            //添加原有参数
            if (urlComponents.queryItems.count > 0) {
                [arrQureyItems addObjectsFromArray:urlComponents.queryItems];
            }
            
            //附加参数
            for (NSString *key in dicQureyItems.allKeys) {
                
                NSURLQueryItem *qi = [NSURLQueryItem queryItemWithName:key value:dicQureyItems[key]];
                
                [arrQureyItems addObject:qi];
            }
            
            urlComponents.queryItems = arrQureyItems;
        }
        
        return urlComponents.string;
    }else {
        return m_strUrl;
    }
}

- (YBRFormableMethod)method {
    return self.httpMethod;
}

- (NSDictionary<NSString *,NSString *> *)headers {
    if (s_pParmsProvider && [s_pParmsProvider respondsToSelector:@selector(ybr_headersWithUrl:andTag:forRequest:)]) {
        NSDictionary *dicProviderHeaders = [s_pParmsProvider ybr_headersWithUrl:m_strUrl andTag:m_strRequestTag forRequest:self];
        if (dicProviderHeaders != nil && [dicProviderHeaders isKindOfClass:[NSDictionary class]]) {
            [m_dicHeaders setValuesForKeysWithDictionary:dicProviderHeaders];
        }
    }
    return m_dicHeaders;
}

- (NSDictionary<NSString *,id> *)parameters {
    return m_dicParams;
}

- (NSString *)tag {
    return m_strRequestTag;
}

#pragma mark - Geters & Seters

- (NSMutableArray<YBRRequestFileData *> *)fileDataArray {
    if (!_fileDataArray) {
        _fileDataArray = [NSMutableArray array];
    }
    return _fileDataArray;
}

@end

@implementation YBRRequest (ProxyBridge)

// 私有方法 获取证书
- (id)getSecurityPolicy {
    
    if (s_pParmsProvider && [s_pParmsProvider respondsToSelector:@selector(ybr_securityPolicy)]) {
        return [s_pParmsProvider ybr_securityPolicy];
    }
    return nil;
}

- (NSArray *)getFileDataArray {
    return self.fileDataArray;
}

@end

#pragma mark - Bridge
@implementation YBRRequest (Bridge)

- (void)StartRequestWithSuccess:(void(^)(YBRRequest* argRequest))argSuccess andFailure:(void(^)(YBRRequest* argRequest, NSString* argError))argFailure {
    kWeakSelf(self);
    [self StartRequestWithSuccess:argSuccess failure:^(YBRRequest *argRequest, NSError *argError) {
        kStrongSelf(self)
        if (argFailure) argFailure(self, argError.localizedDescription);
    }];
}

@end

#pragma mark - Download
@implementation YBRRequest (Download)

- (void)downloadWithURL:(NSString*)argURL
                Success:(void(^)(void))argSuccess
{
    YBRRequestProxy *proxy = [YBRRequestProxy new];
    self.requestProxy = proxy;
    [proxy downloadWithURL:argURL Success:argSuccess];
}

@end
