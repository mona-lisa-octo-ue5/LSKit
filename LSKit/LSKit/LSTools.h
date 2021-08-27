//
//  LSTools.h
//  LSKit
//
//  Created by 石玉龙 on 2021/8/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define ls_cmd ((NSString *)NSStringFromSelector(_cmd))

#define ScreenWidth UIScreen.mainScreen.bounds.size.width
#define ScreenHeight UIScreen.mainScreen.bounds.size.height
#define StatusBarHeight (UIScreen.mainScreen.bounds.size.height<812) ? 20 : 44)

#define SafeAreaTopHeight ((ScreenHeight >= 812.0) && [UIDevice.currentDevice.model isEqualToString:@"iPhone"] ? 88 : 64)
#define SafeAreaBottomHeight ((ScreenHeight >= 812.0) && [UIDevice.currentDevice.model isEqualToString:@"iPhone"] ? 34 : 0)

#define AdaptedFrame(r) ((CGFloat)(r * (ScreenWidth < ScreenHeight ? ScreenWidth : ScreenHeight) / 375))
#define AdaptedFrameByHeight(r) ((CGFloat)(r * (ScreenWidth < ScreenHeight ? ScreenHeight : ScreenWidth) / 667))

#define DSPT_AFTER(delay) dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC))

#define weak_maker(ins) __weak typeof(ins) weak##ins = ins;
#define strong_maker() __strong typeof(ins) strong##ins = ins;

static inline void dispatch_on_main_queue(void(^ _Nonnull handler)(void)) {
    if (NSThread.isMainThread) {
        handler();
    }else {
        dispatch_async(dispatch_get_main_queue(), handler);
    }
}

static inline CGPoint ls_get_center(CGRect rect) {
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

void LSLog(BOOL condition, NSString * _Nullable fmt, ...);

CGSize ls_image_scale(CGSize size);


NS_ASSUME_NONNULL_END
