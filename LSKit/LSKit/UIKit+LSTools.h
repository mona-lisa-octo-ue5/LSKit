//
//  UIKit+LSTools.h
//  LSKit
//
//  Created by 石玉龙 on 2021/8/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^LSViewAnimationBlock)(void(^ _Nullable animation)(void), void(^ _Nullable completion)(BOOL finished));


@interface UIView (LSTools)

@property (nonatomic, copy) LSViewAnimationBlock ls_animation;

- (void)addSubviews:(NSArray <UIView *>*)views;
@end


@interface UIButton (LSTools)

@property (nonatomic, assign) UIEdgeInsets touchAreaInsets;
@end


@interface UIColor (LSTools)

- (UIImage *)toImage;
- (UIImage *(^)(CGSize size))image;
- (UIColor * _Nonnull (^)(CGFloat))colorAlpha;
@end

typedef UIImage *_Nonnull (^LSCombineImageBlock)(UIImage *_Nonnull image);


@interface UIImage (LSTools)

@property (nonatomic, copy) LSCombineImageBlock combine;

+ (UIImage *)genratorImageWithColors:(NSArray <UIColor *>*)colors
                       withDirection:(UIRectEdge)direction
                            andFrame:(CGRect)frame;
+ (UIImage *(^)(CGSize size, UIColor *color))image;
+ (UIImage *)generatorImage:(UIColor *)color;
- (UIImage * (^)(CGFloat cornerRadius))cornerRadius;
- (NSString *)ls_save;
@end


@interface CALayer (LSTools)

+ (CAGradientLayer *)layerColors:(NSArray <UIColor *>*)colors withDirection:(UIRectEdge)direction andFrame:(CGRect)frame;
@end


typedef UIImageView *_Nonnull(^LSImageViewMaskBlock)(UIColor *tintColor, NSInteger max, NSArray <NSNumber *>*indexs, UIRectEdge direct);
typedef void (^LSImageViewSetImageBlock)(UIImage *image, CGSize size);

@interface UIImageView (LSTools)

@property (nonatomic, copy, readonly) LSImageViewMaskBlock ls_setMask;
@property (nonatomic, copy, readonly) LSImageViewSetImageBlock ls_setImage;

@end



NS_ASSUME_NONNULL_END
