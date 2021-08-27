//
//  Obj+LSTools.m
//  LSKit
//
//  Created by 石玉龙 on 2021/8/26.
//

#import "Obj+LSTools.h"
#import "LSTools.h"
#import <objc/runtime.h>

@implementation NSArray (JDTools)

- (LSMap)map {
    return ^(id (^Block)(id)) {
        __block NSMutableArray *result = [NSMutableArray arrayWithCapacity:0];
        [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [result addObject:Block(obj)];
        }];
        return result;
    };
}

- (LSOnceFilter)onceFilter {
    return ^(BOOL (^Block)(id)) {
        __block id result = nil;
        [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (Block(obj)) {
                result = obj;
                *stop = YES;
            }
        }];
        return result;
    };
}

- (LSFilter)filter {
    return ^(BOOL (^Block)(id)) {
        __block NSMutableArray *result = [NSMutableArray arrayWithCapacity:0];
        [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (Block(obj)) {
                [result addObject:obj];
            }
        }];
        return result;
    };
}

- (LSEach)each {
    return ^(void(^Block)(id, NSInteger, BOOL * _Nonnull)) {
        BOOL stop = NO;
        for (NSInteger i = 0; i < self.count; i ++) {
            Block(self[i], i, &stop);
            if (stop) {
                break;
            }
        }
    };
}
@end


@implementation NSString (LSTools)

- (NSURL *)url {
    if ([self hasPrefix:@"/"]) {
        return [NSURL fileURLWithPath:self];
    }
    return [NSURL URLWithString:self];
}

- (LSStringEqual)equal {
    return ^(NSString *compStr) {
        if (!compStr) {
            return NO;
        }
        return [self isEqualToString:compStr];
    };
}

- (UIImage *)img {
    return [UIImage imageNamed:self];
}

+ (NSString *)stringHexWithDec:(NSUInteger)dec {
    char hexChar[9];
    sprintf(hexChar, "%lx", (unsigned long)dec);
    return [NSString stringWithCString:hexChar encoding:NSUTF8StringEncoding];
}

- (NSString *)append:(NSString *)str {
    if (str) {
        return [self stringByAppendingString:str];
    }
    return self;
}

+ (NSString *)randomFileName {
    NSString *stampStr = [NSDate stampStr];
    NSString *randomStr = [NSString stringHexWithDec:rand()];
    return [[stampStr append:@"-"] append:randomStr];
}

@end


typedef NSMutableDictionary <NSString *, NSNumber *> LSInstanceCountContext;
LSInstanceCountContext *_insCountContext = nil;

@implementation NSObject (LSTools)
@dynamic instanceCount;

+ (void)setMaxInstanceCount:(NSInteger)maxInstanceCount {
    if (self.maxInstanceCount == NSIntegerMax) {
        [self.insCountContext setValue:@(0) forKey:self.clsStr];
    }
    objc_setAssociatedObject(self.class, @selector(maxInstanceCount), @(maxInstanceCount), OBJC_ASSOCIATION_RETAIN);
}

- (LSInstanceCountContext *)insCountContext {
    if (!_insCountContext) {
        _insCountContext = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _insCountContext;
}

- (NSString *)clsStr {
    return NSStringFromClass(self.class);
}

- (void)upInstanceCount {
    NSNumber *countNumber = [self.insCountContext valueForKey:self.clsStr];
    if (countNumber) {
        [self.insCountContext setValue:@(countNumber.integerValue + 1) forKey:self.clsStr];
        LSLog([self.class maxInstanceCount] != NSIntegerMax, @"[%@ %@]: max: %ld, cur: %ld", self.clsStr, ls_cmd, [self.class maxInstanceCount], countNumber.integerValue + 1);
    }
}

- (void)downInstanceCount {
    NSNumber *countNumber = [self.insCountContext valueForKey:self.clsStr];
    if (countNumber && countNumber.integerValue > 0) {
        [self.insCountContext setValue:@(countNumber.integerValue - 1) forKey:self.clsStr];
        LSLog([self.class maxInstanceCount] != NSIntegerMax, @"[%@ %@]: max: %ld, cur: %ld", self.clsStr, ls_cmd, [self.class maxInstanceCount], countNumber.integerValue - 1);
    }
}

- (NSInteger)instanceCount {
    NSNumber *countNumber = [self.insCountContext valueForKey:self.clsStr];
    if (countNumber) {
        return countNumber.integerValue;
    }
    return 0;
}

+ (void)exchangeInstanceMethodWithSelfClass:(Class)selfClass originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector {
    Method originalMethod = class_getInstanceMethod(selfClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(selfClass, swizzledSelector);
    BOOL didAddMethod = class_addMethod(selfClass,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(selfClass,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    }else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}
@end


@implementation NSDate (LSTools)

+ (NSString *)stampStr {
    NSTimeInterval secs = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970];
    return [NSString stringHexWithDec:secs];
}

@end
