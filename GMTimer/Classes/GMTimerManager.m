//
//  GMTimerManager.m
//  GMTimer
//
//  Created by 高敏 on 2023/2/19.
//

#import "GMTimerManager.h"

extern void GMTimerInvoke(NSObject *target, SEL aSel, NSInteger value);

@interface GMTimerManager ()

@property (nonatomic, strong) NSMutableDictionary <NSNumber *, GMTimer *> *timers;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, NSMutableArray <GMTimerTarget *>*> *targets;

@end

@implementation GMTimerManager

+ (instancetype)shareInstance {
    static GMTimerManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[GMTimerManager alloc] init];
    });
    return manager;
}


- (void)timerWithSpeed:(NSTimeInterval)speed
                target:(NSObject *)target
              identify:(NSString *)identify
                  aSel:(SEL)aSel {
    [self timerWithSpeed:speed target:target identify:identify useBlock:nil aSel:aSel];
}

- (void)timerWithSpeed:(NSTimeInterval)speed
                target:(NSObject *)target
              identify:(NSString *)identify
              useBlock:(GMTimerCallBlock)useBlock {
    [self timerWithSpeed:speed target:target identify:identify useBlock:useBlock aSel:nil];
}


- (void)timerWithSpeed:(NSTimeInterval)speed
                target:(NSObject *)target
              identify:(NSString *)identify
              useBlock:(GMTimerCallBlock)useBlock
                  aSel:(SEL)aSel {
    if (speed <= 0 || !target || !identify) return;
    GMTimer *timer = [self createTimer:speed];
    if (!timer) return;
    GMTimerTarget *t = [self targetWithSpeed:speed target:target needCreate:YES];
    [t addIdentfy:identify aSel:aSel useBlock:useBlock];
    [timer start];
}

- (void)timerDownWithSpeed:(NSTimeInterval)speed
                    target:(NSObject *)target
                  identify:(NSString *)identify
                     count:(NSInteger)count
                      aSel:(SEL)aSel
             completeBlock:(void (^)(void))completeBlock {
    __weak typeof(self) _self = self;
    __weak typeof(target) _target = target;
    [self timerWithSpeed:speed target:target identify:identify useBlock:^(NSInteger timeInterval) {
        __strong typeof(_self) self = _self;
        __strong typeof(_target) target = _target;
        if (target && aSel && [target respondsToSelector:aSel]) {
            GMTimerInvoke(target, aSel, count-timeInterval);
        }
        if (timeInterval >= count) {
            [self removeSpeed:speed target:target identify:identify];
            !completeBlock?:completeBlock();
        }
    }];
}


- (void)timerDownWithSpeed:(NSTimeInterval)speed
                    target:(NSObject *)target
                  identify:(NSString *)identify
                     count:(NSInteger)count
                  useBlock:(GMTimerCallBlock)useBlock
             completeBlock:(void (^)(void))completeBlock {
    __weak typeof(self) _self = self;
    __weak typeof(target) _target = target;
    [self timerWithSpeed:speed target:target identify:identify useBlock:^(NSInteger timeInterval) {
        __strong typeof(_self) self = _self;
        __strong typeof(_target) target = _target;
        !useBlock?:useBlock(count-timeInterval);
        if (timeInterval >= count) {
            [self removeSpeed:speed target:target identify:identify];
            !completeBlock?:completeBlock();
        }
    }];
}



- (void)removeSpeed:(NSTimeInterval)speed
           target:(NSObject *)target
         identify:(NSString *)identify {
    @synchronized (self) {
        GMTimerTarget *t = [self targetWithSpeed:speed target:target needCreate:NO];
        if (!t) return;
        NSInteger count = [t removeIdentfy:identify];
        if (count == 0) {
            NSMutableArray *targets = [self.targets objectForKey:@(speed)];
            [targets removeObject:t];
            if (targets.count == 0) {
                [self.targets removeObjectForKey:@(speed)];
                GMTimer *timer = [self.timers objectForKey:@(speed)];
                [timer cancel];
                [self.timers removeObjectForKey:@(speed)];
            }
        }
        
    }
}

- (void)removeWithTarget:(NSObject *)target {
    @synchronized (self) {
        NSArray *keys = self.targets.allKeys.copy;
        for (NSNumber *speed in keys) {
            NSMutableArray <GMTimerTarget *> *targets = [self.targets objectForKey:speed];
            [targets enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(GMTimerTarget *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.target == target) {
                    [targets removeObject:obj];
                }
            }];
            if (targets.count == 0) {
                GMTimer *timer = [self.timers objectForKey:speed];
                [timer cancel];
                [self.timers removeObjectForKey:speed];
                [self.targets removeObjectForKey:speed];
            }
        }
    }
}

- (GMTimerTarget *)targetWithSpeed:(NSTimeInterval)speed target:(NSObject *)target needCreate:(BOOL)needCreate {
    GMTimerTarget *t;
    @synchronized (self) {
        NSMutableArray *targets = [self.targets objectForKey:@(speed)];
        if (!targets && needCreate) {
            targets = [NSMutableArray array];
            [self.targets setObject:targets forKey:@(speed)];
        }
        for (GMTimerTarget *tg in targets) {
            if (tg.target == target) {
                t = tg;
                break;
            }
        }
        if (!t && needCreate) {
            __weak typeof(self) _self = self;
            __weak typeof(target) _target = target;
            t = [[GMTimerTarget alloc] initWithTarget:target speed:speed deallocBlock:^{
                __strong typeof(_self) self = _self;
                __strong typeof(_target) target = _target;
                [self removeWithTarget:target];
            }];
            [targets addObject:t];
        }
    }
    return t;
}


#pragma mark -- Timer

- (void)timeCall:(NSTimeInterval)speed {
    @synchronized (self) {
        NSMutableArray *targets = [self.targets objectForKey:@(speed)];
        NSArray <GMTimerTarget *>*ts = targets.copy;
        [ts enumerateObjectsUsingBlock:^(GMTimerTarget * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj call];
        }];
    }
}


- (GMTimer *)createTimer:(NSTimeInterval)speed {
    GMTimer *timer;
    @synchronized (self) {
        timer = [self.timers objectForKey:@(speed)];
        if (!timer) {
            __weak typeof(self) _self = self;
            timer = [[GMTimer alloc] initWithSpeed:speed callBlock:^{
                __strong typeof(_self) self = _self;
                [self timeCall:speed];
            }];
            [self.timers setObject:timer forKey:@(speed)];
        }
    }
    return timer;
}



- (NSMutableDictionary<NSNumber *,GMTimer *> *)timers {
    if (!_timers) {
        _timers = [NSMutableDictionary dictionary];
    }
    return _timers;
}

- (NSMutableDictionary<NSNumber *,NSMutableArray<GMTimerTarget *> *> *)targets {
    if (!_targets) {
        _targets = [NSMutableDictionary dictionary];
    }
    return _targets;
}

@end
