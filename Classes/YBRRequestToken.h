//
//  YBRRequestToken.h
//  YBRenstore
//
//  Created by bdkj on 2020/6/23.
//  Copyright © 2020 BDKJ_Hbb. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YBRRequestToken <NSObject>

// Cancel the Action
- (void)Cancel;

// Status Is Running
- (BOOL)IsRunning;

@end

NS_ASSUME_NONNULL_END
