//
//  YBRResponse.h
//  YBRInsiderApp
//
//  Created by bdkj on 2018/4/28.
//  Copyright © 2018年 BDKJ_Hbb. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YBRRequest;

@interface YBRResponse : NSObject

@property (nonatomic, readonly)YBRRequest* request;

-(instancetype)initWithRequest:(YBRRequest *)request;

@property (nonatomic, strong)id responseObject;

@end
