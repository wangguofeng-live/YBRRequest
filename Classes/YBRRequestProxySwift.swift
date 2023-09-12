//
//  YBRRequestProxySwift.swift
//  YBRRequest
//
//  Created by bdkj on 2023/3/7.
//

import UIKit

import Alamofire

class YBRRequestProxySwift: NSObject {
    
    //1
    let sessionManager: Session = {
        //2
        let configuration = URLSessionConfiguration.af.default
        //3
        configuration.timeoutIntervalForRequest = 30
        //4
        return Session(configuration: configuration)
    }()
    
//    + (NSSet *)acceptableContentTypes {
//        return [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
//    }

//    public func sessionManagerWithBaseUrl(_ baseUrl:String) -> Session {
//
//        static dispatch_once_t once;
//        static NSMutableDictionary *dicHTTPSessionManager;
//
//        dispatch_once(&once, ^{
//            dicHTTPSessionManager = [NSMutableDictionary dictionary];
//        });
//
//        AFHTTPSessionManager *manager = [dicHTTPSessionManager objectForKey:baseUrl];
//        if (manager == nil) {
//            manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
//            [manager setTaskDidFinishCollectingMetricsBlock:^(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSURLSessionTaskMetrics * _Nullable metrics) {
//                //cache task metrics
//                [YBRRequestProxyCache setMetrics:metrics forTask:task];
//            }];
//        }
//        [dicHTTPSessionManager setObject:manager forKey:baseUrl];
//
//
//        return manager;
//
//    }
    
    // Start the asynchronous request
    func request(request:YBRRequest, success: (_ response:YBRResponse) -> Void, failure: (_ response:YBRResponse, _ error:NSError) -> Void) -> Void {
        
//        sessionManager.request(url, parameters: queryParameters)
        
        guard let requestURL = NSURL(string: request.url) else { return }
        
        let baseUrl = "\(requestURL.scheme)://\(requestURL.host)"
        
        // Setup the http manager
        let httpSessionManager = sessionManager
        
       
//        AFHTTPSessionManager* pHttpSessionManager = [YBRRequestProxy sessionManagerWithBaseUrl:baseUrl];
//        httpSessionManager.request(URLConvertible)
//
//        //content types
//        pHttpSessionManager.responseSerializer.acceptableContentTypes = [YBRRequestProxy acceptableContentTypes]; //接收类型
//
//        //timeout
//        [pHttpSessionManager.requestSerializer setTimeoutInterval:request.timeoutInterval]; //超时时间
//
//        //setup security plicy
//        id pSecurityPolicy = [request getSecurityPolicy];
//        if (pSecurityPolicy) [pHttpSessionManager setSecurityPolicy:pSecurityPolicy];
//
//        switch (request.method) {
//            case YBRFormableMethod_POST:
//            {
//                self.dataTask = [pHttpSessionManager POST:request.url parameters:request.parameters headers:request.headers constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//
//                    //挂载文件
//                     for (YBRRequestFileData *pFileData in [request getFileDataArray]) {
//                         [formData appendPartWithFileData:pFileData.fileData name:pFileData.name fileName:pFileData.fileName mimeType:pFileData.mimeType];
//                     }
//
//                } progress:^(NSProgress * _Nonnull uploadProgress) {
//
//                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//
//                    // reqeust duration
//                    NSTimeInterval taskIntervalDuration = [YBRRequestProxyCache gettMetricsForTask:task].taskInterval.duration;
//
//                    YBRResponse *pResponse = [[YBRResponse alloc] initWithRequest:request];
//                    pResponse.responseObject = responseObject;
//                    pResponse.responseDuration = taskIntervalDuration;
//                    m_pResponse = responseObject;
//                    if(argSuccess) argSuccess(pResponse);
//                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//
//                    // reqeust duration
//                    NSTimeInterval taskIntervalDuration = [YBRRequestProxyCache gettMetricsForTask:task].taskInterval.duration;
//
//                    YBRResponse *pResponse = [[YBRResponse alloc] initWithRequest:request];
//                    pResponse.responseDuration = taskIntervalDuration;
//
//                    if(argFailure) argFailure(pResponse, error);
//
//                }];
//            }
//                break;
//            case YBRFormableMethod_GET:
//            {
//                self.dataTask = [pHttpSessionManager GET:request.url parameters:request.parameters headers:request.headers progress:^(NSProgress * _Nonnull uploadProgress) {
//
//                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//
//                    // reqeust duration
//                    NSTimeInterval taskIntervalDuration = [YBRRequestProxyCache gettMetricsForTask:task].taskInterval.duration;
//
//                    YBRResponse *pResponse = [[YBRResponse alloc] initWithRequest:request];
//                    pResponse.responseObject = responseObject;
//                    pResponse.responseDuration = taskIntervalDuration;
//                    m_pResponse = responseObject;
//                    if(argSuccess) argSuccess(pResponse);
//                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//
//                    // reqeust duration
//                    NSTimeInterval taskIntervalDuration = [YBRRequestProxyCache gettMetricsForTask:task].taskInterval.duration;
//
//                    YBRResponse *pResponse = [[YBRResponse alloc] initWithRequest:request];
//                    pResponse.responseDuration = taskIntervalDuration;
//
//                    if(argFailure) argFailure(pResponse, error);
//
//                }];
//            }
//                break;
//            default:
//            {
//                NSAssert(1, @"请求未支持");
//            }
//                break;
//        }
    }
}
