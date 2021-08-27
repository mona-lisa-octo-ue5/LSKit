//
//  LSProtocol.h
//  LSKit
//
//  Created by 石玉龙 on 2021/8/26.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@protocol LSTarget;
@protocol LSAction <NSObject>

- (void)target:(id <LSTarget>)target tag:(NSInteger)tag;
- (void)target:(id <LSTarget>)target tagStr:(NSString *)tagStr;

@end

@protocol LSTarget <NSObject>

@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, weak) id <LSAction>dlgt;

@end

NS_ASSUME_NONNULL_END
