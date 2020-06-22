//
//  YBRRequestFormable.h
//  YBRInsiderApp
//
//  Created by bdkj on 2018/4/27.
//  Copyright © 2018年 BDKJ_Hbb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YBRFormable.h"

@protocol YBRRequestFormable <YBRFormable>

@property (nonatomic, readonly)NSString *tag;

- (NSDictionary<NSString *, id> *)parameters;

@end

/*
 *  提取 NSURLRequest 接口
 */
@protocol YBRURLRequestConvertible <NSObject>

- (NSURLRequest *)asURLRequest;

@end

/*
 *  提取 NSURLRequest 接口
 */
@protocol YBRParameterEncoding <NSObject>

- (NSURLRequest *)encodeURLRequest:(id<YBRURLRequestConvertible>) convertible parameters:(NSDictionary *)params;

@end
