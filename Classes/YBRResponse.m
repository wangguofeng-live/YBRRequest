//
//  YBRResponse.m
//  YBRInsiderApp
//
//  Created by bdkj on 2018/4/28.
//  Copyright © 2018年 BDKJ_Hbb. All rights reserved.
//

#import "YBRResponse.h"

@implementation YBRResponse
{
    YBRRequest *_request;
}

- (instancetype)initWithRequest:(YBRRequest *)request
{
    self = [super init];
    if (self) {
        _request = request;
    }
    return self;
}

- (YBRRequest *)request {
    return _request;
}

@end
