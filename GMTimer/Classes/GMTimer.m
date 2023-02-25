//
//  GMTimer.m
//  GMTimer
//
//  Created by 高敏 on 2023/2/19.
//

#import "GMTimer.h"

@interface GMTimer ()

@property (nonatomic) dispatch_source_t timer;
@property (nonatomic, assign) NSTimeInterval speed;
@property (nonatomic, copy) GMTimerBlock callBlock;
@end

@implementation GMTimer


- (instancetype)initWithSpeed:(NSTimeInterval)speed callBlock:(GMTimerBlock)callBlock {
    self = [super init];
    if (self) {
        self.speed = speed;
        self.callBlock = callBlock;
    }
    return self;
}

- (void)start {
    if (!_timer) {
        dispatch_queue_t queue = dispatch_queue_create("com.gm.timer", 0);
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
        dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), self.speed * NSEC_PER_SEC, 0);
        __weak typeof(self) _self = self;
        dispatch_source_set_event_handler(_timer, ^{
            __strong typeof(_self) self = _self;
            !self.callBlock?:self.callBlock();
        });
        dispatch_resume(_timer);
    }
}


- (void)cancel {
    if (self.timer) {
        dispatch_source_cancel(self.timer);
        self.timer = nil;
    }
}


@end
