//
//  GMTimerManager.h
//  GMTimer
//
//  Created by 高敏 on 2023/2/19.
//

#import <Foundation/Foundation.h>
#import "GMTimer.h"
#import "GMTimerTarget.h"

NS_ASSUME_NONNULL_BEGIN

@interface GMTimerManager : NSObject

+ (instancetype)shareInstance;


- (void)timerWithSpeed:(NSTimeInterval)speed
                target:(NSObject *)target
              identify:(NSString *)identify
                  aSel:(SEL)aSel;

- (void)timerWithSpeed:(NSTimeInterval)speed
                target:(NSObject *)target
              identify:(NSString *)identify
              useBlock:(GMTimerCallBlock)useBlock;


- (void)removeSpeed:(NSTimeInterval)speed
             target:(NSObject *)target
           identify:(NSString *)identify;


- (void)removeWithTarget:(NSObject *)target;


/// 倒计时
/// - Parameters:
///   - speed: 倒计时速度
///   - target: 倒计时绑定类
///   - identify: 倒计时标识
///   - count: 剩余倒计时数
///   - aSel: 方法
///   - completeBlock: 完成回调 需要用(weak)修饰
- (void)timerDownWithSpeed:(NSTimeInterval)speed
                    target:(NSObject *)target
               identify:(NSString *)identify
                  count:(NSInteger)count
                   aSel:(SEL)aSel
          completeBlock:(void(^)(void))completeBlock;


/// 倒计时
/// - Parameters:
///   - speed: 倒计时速度
///   - target: 倒计时绑定类
///   - identify: 倒计时标识
///   - count: 倒计时数
///   - useBlock: 倒计时回调 需要用(weak)修饰
///   - completeBlock: 倒计时完成回调 需要用(weak)修饰
- (void)timerDownWithSpeed:(NSTimeInterval)speed
                    target:(NSObject *)target
                  identify:(NSString *)identify
                     count:(NSInteger)count
                  useBlock:(GMTimerCallBlock)useBlock
             completeBlock:(void(^)(void))completeBlock;



@end

NS_ASSUME_NONNULL_END
