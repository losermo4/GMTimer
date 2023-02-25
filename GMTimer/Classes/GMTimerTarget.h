//
//  GMTimerTarget.h
//  GMTimer
//
//  Created by 高敏 on 2023/2/19.
//

#import <Foundation/Foundation.h>
#import <GMTimer/GMTimerTargetItem.h>

NS_ASSUME_NONNULL_BEGIN


typedef void(^GMTimerDeallocBlock)(void);

@interface GMTimerTarget : NSObject

@property (nonatomic, weak) NSObject *target;
@property (nonatomic, assign) NSTimeInterval speed;

- (instancetype)initWithTarget:(NSObject *)target
speed:(NSTimeInterval)speed deallocBlock:(GMTimerDeallocBlock)deallocBlock;

- (NSInteger)addIdentfy:(NSString *)identify aSel:(SEL)aSel useBlock:(GMTimerCallBlock)useBlock;
- (NSInteger)removeIdentfy:(NSString *)identify;
- (void)call;

@end

NS_ASSUME_NONNULL_END
