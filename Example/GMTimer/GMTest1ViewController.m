//
//  GMTest1ViewController.m
//  GMTimer_Example
//
//  Created by 高敏 on 2023/2/19.
//  Copyright © 2023 gaomin2588. All rights reserved.
//

#import "GMTest1ViewController.h"
#import <GMTimer/GMTimerManager.h>

@interface GMTest1ViewController ()

@end

@implementation GMTest1ViewController

- (void)dealloc {
    NSLog(@"GMTest1ViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[GMTimerManager shareInstance] timerWithSpeed:1 target:self identify:@"1" useBlock:^(NSInteger timeInterval) {
        NSLog(@"1-1 %ld",timeInterval);
    }];
//    [[GMTimerManager shareInstance] timerWithSpeed:2 target:self identify:@"2" useBlock:^(NSInteger timeInterval) {
//        NSLog(@"2-2 %ld",timeInterval);
//    }];
    __weak typeof(self) _self = self;
    [[GMTimerManager shareInstance] timerDownWithSpeed:1 target:self identify:@"1-down" count:10 useBlock:^(NSInteger timeInterval) {
        NSLog(@"1 --- %ld", timeInterval);
    } completeBlock:^{
        NSLog(@"1 fininsh %@", _self);
    }];

//    [[GMTimerManager shareInstance] timerDownWithSpeed:2 target:self identify:@"2" count:10 useBlock:^(NSInteger timeInterval) {
//        NSLog(@"2 --- %ld", timeInterval);
//    } completeBlock:^{
//        NSLog(@"2 fininsh %@", self);
//    }];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.navigationController pushViewController:GMTest1ViewController.new animated:YES];
}


@end
