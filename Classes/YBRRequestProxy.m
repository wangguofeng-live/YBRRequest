//
//  YBRRequestProxy.m
//  YBRInsiderApp
//
//  Created by bdkj on 2018/4/27.
//  Copyright © 2018年 BDKJ_Hbb. All rights reserved.
//

#import "YBRRequestProxy.h"

#import <AFNetworking/AFNetworking.h>
//#import "NSString+YBRTools.h"
//#import <Crashlytics/Answers.h>
//#import <CocoaLumberjack/CocoaLumberjack.h>

#import "YBRRequest.h"
#import "YBRResponse.h"
#import "YBRRequestFileData.h"

@interface YBRRequestProxy ()
{
    id m_pResponse;
}

@property (nonatomic, strong)NSURLSessionDataTask *dataTask;

@end

@implementation YBRRequestProxy
@synthesize response = m_pResponse;

+ (NSSet *)acceptableContentTypes {
    return [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
}

- (void)request:(YBRRequest *)request Success:(void(^)(YBRResponse* argResponse))argSuccess Failure:(void(^)(YBRResponse* argResponse, NSError* argError))argFailure {
    
    NSURL *requestURL = [NSURL URLWithString:request.url];
    NSString *baseUrl = [NSString stringWithFormat:@"%@://%@",requestURL.scheme, requestURL.host];
    
    // Setup the http manager
    AFHTTPSessionManager* pHttpSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
    
    //content types
    pHttpSessionManager.responseSerializer.acceptableContentTypes = [YBRRequestProxy acceptableContentTypes]; //接收类型
    
    //timeout
    [pHttpSessionManager.requestSerializer setTimeoutInterval:request.timeoutInterval]; //超时时间
    
    //setup security plicy
    id pSecurityPolicy = [request getSecurityPolicy];
    if (pSecurityPolicy) [pHttpSessionManager setSecurityPolicy:pSecurityPolicy];
    
    switch (request.method) {
        case YBRFormableMethod_POST:
        {
            self.dataTask = [pHttpSessionManager POST:request.url parameters:request.parameters headers:request.headers constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                
                //挂载文件
                 for (YBRRequestFileData *pFileData in [request getFileDataArray]) {
                     [formData appendPartWithFileData:pFileData.fileData name:pFileData.name fileName:pFileData.fileName mimeType:pFileData.mimeType];
                 }
                
            } progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                YBRResponse *pResponse = [[YBRResponse alloc] initWithRequest:request];
                pResponse.responseObject = responseObject;
                m_pResponse = responseObject;
                if(argSuccess) argSuccess(pResponse);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                YBRResponse *pResponse = [[YBRResponse alloc] initWithRequest:request];
                
                if(argFailure) argFailure(pResponse, error);
                
            }];
        }
            break;
        case YBRFormableMethod_GET:
        {
            self.dataTask = [pHttpSessionManager GET:request.url parameters:request.parameters headers:request.headers progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                YBRResponse *pResponse = [[YBRResponse alloc] initWithRequest:request];
                pResponse.responseObject = responseObject;
                m_pResponse = responseObject;
                if(argSuccess) argSuccess(pResponse);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                YBRResponse *pResponse = [[YBRResponse alloc] initWithRequest:request];
                
                if(argFailure) argFailure(pResponse, error);
                
            }];
        }
            break;
        default:
        {
            NSAssert(1, @"请求未支持");
        }
            break;
    }
    
}


//- (void)uploadRequest:(YBRRequest<YBRUploadFormable> *)request
//              Success:(void(^)(YBRResponse* argResponse))argSuccess
//              Failure:(void(^)(YBRResponse* argResponse, NSError* argError))argFailure {
//    // Setup the http manager
//
//    AFHTTPSessionManager* pHttpSessionManager = [AFHTTPSessionManager manager];
//    pHttpSessionManager.responseSerializer.acceptableContentTypes = [YBRRequestProxy acceptableContentTypes];
//    [pHttpSessionManager.requestSerializer setTimeoutInterval:120];
//
//    // Start the post request
//    self.dataTask = [pHttpSessionManager POST:request.url
//                                   parameters:request.parameters
//                    constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
//
//                        for (YBRUploadData *pUploadData in request.uploadData) {
//
//                            [formData appendPartWithFileData:pUploadData.data name:pUploadData.name fileName:pUploadData.fileName mimeType:pUploadData.mimeType];
//                        }
//
//                    }
//                                     progress:^(NSProgress * _Nonnull uploadProgress) {
//
//                                     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//                                         YBRResponse *pResponse = [[YBRResponse alloc] initWithRequest:request];
//                                         pResponse.responseObject = responseObject;
//
//                                         if(argSuccess) argSuccess(pResponse);
//                                     }
//                                      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                                          YBRResponse *pResponse = [[YBRResponse alloc] initWithRequest:request];
//
//                                          if(argFailure) argFailure(pResponse, error);
//                                      }];
//
//}

- (void)downloadWithURL:(NSString*)argURL
                Success:(void(^)(void))argSuccess
{
    NSArray *array = [argURL componentsSeparatedByString:@"/"]; //从字符A中分隔成2个元素的数组
    NSString* strFileName = [array lastObject];
    BOOL bIsExist = [self _isFileExist:strFileName];
    if (bIsExist == YES) {
        return;
    }
    
    
    //1.创建会话管理者
    AFHTTPSessionManager *manager =[AFHTTPSessionManager manager];
    NSURL *url = [NSURL URLWithString:argURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //2.下载文件
    /*
     第一个参数：请求对象
     第二个参数：进度回调
     downloadProgress.completedUnitCount :已经下载的数据
     downloadProgress.totalUnitCount：数据的总大小
     第三个参数：destination回调，该block需要返回值（NSURL类型），告诉系统应该把文件剪切到什么地方
     targetPath：文件的临时保存路径tmp，随时可能被删除
     response：响应头信息
     第四个参数：completionHandler请求完成后回调
     response：响应头信息
     filePath：文件的保存路径，即destination回调的返回值
     error：错误信息
     */
    NSURLSessionDownloadTask *download = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //监听下载进度
        //completedUnitCount 已经下载的数据大小
        //totalUnitCount     文件数据的中大小
        //NSSLog(@"%f",1.0 *downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        /**
         * 1:1：请求路径：NSUrl *url = [NSUrl urlWithString:path];从网络请求路径  2：把本地的file文件路径转成url，NSUrl *url = [NSURL fileURLWithPath:fullPath]；
         2：返回值是一个下载文件的路径
         *
         */
        NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:response.suggestedFilename];
        
        return [NSURL fileURLWithPath:fullPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        /**
         *filePath:下载后文件的保存路径
         */
        if (argSuccess) {
            argSuccess();
        }
    }];
    
    //3.执行Task
    [download resume];
}

#pragma mark - 判断文件是否已经在沙盒中已经存在
- (BOOL)_isFileExist:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath:filePath];
    return result;
}

#pragma mark - 检查网络是否通畅
- (BOOL)checkNetworkConnection
{
    struct sockaddr zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sa_len = sizeof(zeroAddress);
    zeroAddress.sa_family = AF_INET;
    
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags) {
        printf("Error. Count not recover network reachability flags\n");
        return NO;
    }
    
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (isReachable && !needsConnection) ? YES : NO;
}

@end
