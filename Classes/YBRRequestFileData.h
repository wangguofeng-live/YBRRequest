//
//  YBRRequestFileData.h
//  YBRenstore
//
//  Created by bdkj on 2020/5/7.
//  Copyright © 2020 BDKJ_Hbb. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YBRRequestFileData : NSObject

@property (nonatomic,copy)NSString *name;

@property (nonatomic,strong)NSData *fileData;

@property (nonatomic,copy)NSString *fileName;

@property (nonatomic,copy)NSString *mimeType;

@end

NS_ASSUME_NONNULL_END
