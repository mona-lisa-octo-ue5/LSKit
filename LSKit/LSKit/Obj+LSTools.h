//
//  Obj+LSTools.h
//  LSKit
//
//  Created by 石玉龙 on 2021/8/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSMutableArray *_Nonnull(^LSMap)(id _Nonnull (^ _Nonnull)(id _Nullable obj));
typedef NSMutableArray *_Nonnull(^LSFilter)(BOOL (^ _Nonnull)(id _Nonnull obj));
typedef void (^LSEach)(void (^_Nonnull)(id _Nonnull obj, NSInteger idx, BOOL * _Nonnull stop));
typedef id _Nullable (^LSOnceFilter)(BOOL (^ _Nonnull)(id _Nonnull obj));

@interface NSArray (LSTools)

@property (nonatomic, copy, readonly) LSMap _Nullable map;
@property (nonatomic, copy, readonly) LSFilter _Nullable filter;
@property (nonatomic, copy, readonly) LSEach _Nullable each;
@property (nonatomic, copy, readonly) LSOnceFilter _Nullable onceFilter;
@end

typedef BOOL (^LSStringEqual)(NSString * _Nullable compStr);

@interface NSString (LSTools)

@property (nonatomic, strong, readonly) NSURL * _Nonnull url;
@property (nonatomic, copy, readonly) LSStringEqual _Nullable equal;

+ (NSString *)randomFileName;
+ (NSString *)stringHexWithDec:(NSUInteger)dec;
- (UIImage *)img;
- (NSString *)append:(NSString *)str;
@end

@interface NSObject (LSTools)

@property (nonatomic, assign, class) NSInteger maxInstanceCount;
@property (nonatomic, strong, readonly) NSString *clsStr;
@property (nonatomic, assign, readonly) NSInteger instanceCount;

- (void)upInstanceCount;
- (void)downInstanceCount;

+ (void)exchangeInstanceMethodWithSelfClass:(Class)selfClass
                           originalSelector:(SEL)originalSelector
                           swizzledSelector:(SEL)swizzledSelector;
@end

@interface NSDate (LSTools)

+ (NSString *)stampStr;
@end

NS_ASSUME_NONNULL_END
