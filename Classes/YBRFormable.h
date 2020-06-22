//
//  YBRFormable.h
//  YBRInsiderApp
//
//  Created by bdkj on 2018/4/27.
//  Copyright © 2018年 BDKJ_Hbb. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, YBRFormableMethod) {
    YBRFormableMethod_GET,
    YBRFormableMethod_POST,
};

@protocol YBRFormable <NSObject>

@property(nonatomic, readonly)NSString *url;

@property(nonatomic, readonly)YBRFormableMethod method;

@property(nonatomic, readonly)NSDictionary<NSString *, NSString *> *headers;

@end
