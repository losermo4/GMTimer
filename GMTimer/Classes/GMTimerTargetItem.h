//
//  GMTimerTargetItem.h
//  GMTimer
//
//  Created by 高敏 on 2023/2/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^GMTimerCallBlock)(NSInteger timeInterval);
@interface GMTimerTargetItem : NSObject
@property (nonatomic, assign) NSTimeInterval speed;
@property (nonatomic, weak) NSObject *target;
@property (nonatomic, copy) NSString *identify;
@property (nonatomic) SEL aSel;
@property (nonatomic, copy) GMTimerCallBlock block;
@property (nonatomic) NSInteger time;
@end

NS_ASSUME_NONNULL_END
