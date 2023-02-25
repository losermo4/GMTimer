//
//  GMTimer.h
//  GMTimer
//
//  Created by 高敏 on 2023/2/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^GMTimerBlock)(void);


@interface GMTimer : NSObject

- (instancetype)initWithSpeed:(NSTimeInterval)speed callBlock:(GMTimerBlock)callBlock;

- (void)start;

- (void)cancel;


@end

NS_ASSUME_NONNULL_END
