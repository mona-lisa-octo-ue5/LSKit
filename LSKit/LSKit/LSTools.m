//
//  LSTools.m
//  LSKit
//
//  Created by 石玉龙 on 2021/8/26.
//

#import "LSTools.h"

void LSLog(BOOL condition, NSString * _Nullable fmt, ...) {
    fmt = [fmt stringByAppendingString:@"···\n\n"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"[-yyyy/MM/dd HH:mm:ss.SSS-]···"];
    NSDate *datenow = [NSDate date];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    
    if (condition) {
        va_list args;
        va_start(args, fmt);
        NSString *logStr = [[NSString alloc] initWithFormat:fmt arguments:args];
        va_end(args);
        printf("\n···%s%s", currentTimeString.UTF8String, logStr.UTF8String);
    }
}

CGSize ls_image_scale(CGSize size) {
    CGSize trans = CGSizeMake(0, 0);
    CGFloat stander = ScreenWidth * 0.512;
    CGFloat minSide = ScreenWidth * 0.512 * 0.512;
    if (size.width >= size.height) {
        trans.width = stander;
        CGFloat height = stander / size.width * size.height;
        trans.height = MAX(minSide, height);
    }else {
        trans.height = stander;
        CGFloat width = stander / size.height * size.width;
        trans.width = MAX(minSide, width);
    }
    return trans;
}
