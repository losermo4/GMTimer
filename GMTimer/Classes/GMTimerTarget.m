//
//  GMTimerTarget.m
//  GMTimer
//
//  Created by 高敏 on 2023/2/19.
//

#import "GMTimerTarget.h"
#import <objc/runtime.h>

void GMTimerInvoke(NSObject *target, SEL aSel, NSInteger value) {
    NSMethodSignature *signature = [target methodSignatureForSelector:aSel];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setArgument:&value atIndex:2];
    invocation.selector = aSel;
    invocation.target = target;
    [invocation invoke];
}


@interface GMTimerTargetTargetDealloc : NSObject
@property (nonatomic, copy) void (^deallocBlock)(void);
@end
@implementation GMTimerTargetTargetDealloc
- (void)dealloc {
    !self.deallocBlock?:self.deallocBlock();
}
@end




@interface GMTimerTarget ()
@property (nonatomic, strong) NSMutableDictionary <NSString *, GMTimerTargetItem *> *items;
@property (nonatomic, copy) GMTimerDeallocBlock deallocBlock;

@end

@implementation GMTimerTarget


- (instancetype)initWithTarget:(NSObject *)target speed:(NSTimeInterval)speed  deallocBlock:(GMTimerDeallocBlock)deallocBlock {
    self = [super init];
    if (self) {
        self.target = target;
        self.speed = speed;
        self.deallocBlock = deallocBlock;
        GMTimerTargetTargetDealloc *deallocTarget = [[GMTimerTargetTargetDealloc alloc] init];
        __weak typeof(self) _self = self;
        deallocTarget.deallocBlock = ^{
            __strong typeof(_self) self = _self;
            !self.deallocBlock?:self.deallocBlock();
        };
        NSString *key = [NSString stringWithFormat:@"kGMTimerTargetDeallocKey_%lf",self.speed];
        void *kGMTimerTargetDeallocKey = (__bridge void *)(key);
        objc_setAssociatedObject(self.target, kGMTimerTargetDeallocKey, deallocTarget, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return self;
}

- (NSInteger)addIdentfy:(NSString *)identify aSel:(SEL)aSel useBlock:(GMTimerCallBlock)useBlock {
    @synchronized (self) {
        GMTimerTargetItem *item = [self.items objectForKey:identify];
        if (!item) {
            item = [[GMTimerTargetItem alloc] init];
            [self.items setObject:item forKey:identify];
        }
        item.speed = self.speed;
        item.identify = identify;
        item.aSel = aSel;
        item.block = useBlock;
        item.time = 0;
    }
    return self.items.count;
}

- (NSInteger)removeIdentfy:(NSString *)identify {
    @synchronized (self) {
        [self.items removeObjectForKey:identify];
    }
    return self.items.count;
}

- (void)call {
    NSDictionary *items = self.items.copy;
    for (GMTimerTargetItem *item in items.allValues) {
        item.time++;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (item.target && item.aSel && [item.target respondsToSelector:item.aSel]) {
                GMTimerInvoke(item.target, item.aSel, item.time);
            }
            !item.block?:item.block(item.time);
        });
    }
}

- (NSMutableDictionary<NSString *,GMTimerTargetItem *> *)items {
    if (!_items) {
        _items = [NSMutableDictionary dictionary];
    }
    return _items;
}


@end
