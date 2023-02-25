#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "GMTimer.h"
#import "GMTimerManager.h"
#import "GMTimerTarget.h"
#import "GMTimerTargetItem.h"

FOUNDATION_EXPORT double GMTimerVersionNumber;
FOUNDATION_EXPORT const unsigned char GMTimerVersionString[];

