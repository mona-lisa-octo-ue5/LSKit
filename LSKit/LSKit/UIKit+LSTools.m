//
//  UIKit+LSTools.m
//  LSKit
//
//  Created by 石玉龙 on 2021/8/26.
//

#import "UIKit+LSTools.h"
#import "Obj+LSTools.h"
#import "LSTools.h"
#import <objc/runtime.h>
#import <float.h>
#import <objc/objc.h>

@implementation UIView (LSTools)

- (LSViewAnimationBlock)ls_animation {
    return ^(void (^animation)(void), void (^completion)(BOOL finished)) {
        [UIView animateWithDuration:0.25
                              delay:0
                            options:UIViewAnimationOptionAllowAnimatedContent
                         animations:^{
            if (animation) {
                animation();
            }
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
    };
}

- (void)addSubviews:(NSArray<UIView *> *)views {
    views.each(^(id  _Nonnull obj, NSInteger idx, BOOL * _Nonnull stop) {
        [self addSubview:obj];
    });
}

@end


@implementation UIButton (LSTools)

- (UIEdgeInsets)touchAreaInsets {
    return [objc_getAssociatedObject(self, @selector(touchAreaInsets)) UIEdgeInsetsValue];
}

- (void)setTouchAreaInsets:(UIEdgeInsets)touchAreaInsets {
    NSValue *value = [NSValue valueWithUIEdgeInsets:touchAreaInsets];
    objc_setAssociatedObject(self, @selector(touchAreaInsets), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    UIEdgeInsets touchAreaInsets = self.touchAreaInsets;
    CGRect bounds = self.bounds;
    bounds = CGRectMake(bounds.origin.x + touchAreaInsets.left,
                        bounds.origin.y + touchAreaInsets.top,
                        bounds.size.width - touchAreaInsets.left - touchAreaInsets.right,
                        bounds.size.height - touchAreaInsets.top - touchAreaInsets.bottom);
    return CGRectContainsPoint(bounds, point);
}

@end


@implementation UIColor (LSTools)

- (UIImage *)toImage {
    return [UIImage generatorImage:self];
}

- (UIImage * _Nonnull (^)(CGSize))image {
    weak_maker(self);
    return ^(CGSize size) {
        return UIImage.image(size, weakself);
    };
}

- (UIColor * _Nonnull (^)(CGFloat))colorAlpha {
    return ^(CGFloat alpha) {
        return [UIColor colorWithRed:self.red green:self.green blue:self.blue alpha:alpha];
    };
}

- (CGColorSpaceModel)colorSpaceModel {
    return CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
}

- (BOOL)canProvideRGBComponents {
    switch (self.colorSpaceModel) {
        case kCGColorSpaceModelRGB:
        case kCGColorSpaceModelMonochrome:
            return YES;
            break;
        default:
            return NO;
            break;
    }
}

- (CGFloat)red {
    NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -red");
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    return c[0];
}

- (CGFloat)green {
    NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -green");
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    if (self.colorSpaceModel == kCGColorSpaceModelMonochrome) return c[0];
    return c[1];
}

- (CGFloat)blue {
    NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -blue");
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    if (self.colorSpaceModel == kCGColorSpaceModelMonochrome) return c[0];
    return c[2];
}

- (CGFloat)white {
    NSAssert(self.colorSpaceModel == kCGColorSpaceModelMonochrome, @"Must be an RGB color to use -white");
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    return c[0];
}

- (CGFloat)alpha {
    return CGColorGetAlpha(self.CGColor);
}

@end


@implementation UIImage (LSTools)

- (LSCombineImageBlock)combine {
    return ^(UIImage *image) {
        CGRect frame = CGRectZero;
        frame.size = image.size;
        frame.origin = CGPointMake(self.size.width / 2 - image.size.width / 2,
                                   self.size.height / 2 - image.size.height / 2);
        UIGraphicsBeginImageContext(self.size);
        [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
        [image drawInRect:frame];
        UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return resultImg;
    };
}

+ (UIImage *)generatorImageWithColors:(NSArray <UIColor *>*)colors
                        withDirection:(UIRectEdge)direction
                             andFrame:(CGRect)frame {
    CALayer *layer = [CALayer layerColors:colors withDirection:direction andFrame:frame];
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, 0);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outputImage;
}

+ (UIImage * _Nonnull (^)(CGSize, UIColor * _Nonnull))image {
    return ^(CGSize size, UIColor *color) {
        CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.mainScreen.scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillRect(context, rect);
        UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return theImage;
    };
}

+ (UIImage *)generatorImage:(UIColor *)color {
    return UIImage.image(CGSizeMake(1, 1), color);
}

- (UIImage * _Nonnull (^)(CGFloat))cornerRadius {
    return ^(CGFloat cornerRadios) {
        CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
        UIGraphicsBeginImageContextWithOptions(self.size, NO, UIScreen.mainScreen.scale);
        [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadios] addClip];
        [self drawInRect:rect];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    };
}

- (NSString *)ls_save {
    NSString *fileName = [NSString.randomFileName append:@".jpg"];
    NSString *relativePath = @"/Documents/Cache/ImageData/";
    NSString *path = [NSHomeDirectory() append:relativePath];
    if (![NSFileManager.defaultManager fileExistsAtPath:path]) {
        [NSFileManager.defaultManager createDirectoryAtPath:path
                                withIntermediateDirectories:YES
                                                 attributes:nil
                                                      error:nil];
    }
    path = [path append:fileName];
    NSData *imgData = UIImageJPEGRepresentation(self, 1);
    [imgData writeToFile:path atomically:YES];
    NSString *imagePath = [relativePath append:fileName];
    LSLog(YES, @"图片保存成功：%@", imagePath);
    return imagePath;
}

@end


@implementation CALayer (LSTools)

+ (CAGradientLayer *)layerColors:(NSArray<UIColor *> *)colors withDirection:(UIRectEdge)direction andFrame:(CGRect)frame {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    NSMutableArray *tmpClrArr = [NSMutableArray arrayWithCapacity:colors.count];
    NSMutableArray *tmpLocArr = [NSMutableArray arrayWithCapacity:colors.count];
    colors.each(^(UIColor *obj, NSInteger idx, BOOL * _Nonnull stop) {
        [tmpClrArr addObject:[obj CGColor]];
        [tmpLocArr addObject:@(idx * (1.0 / (colors.count - 1)))];
    });
    gradientLayer.colors = tmpClrArr;
    gradientLayer.locations = tmpLocArr;
    switch (direction) {
        case UIRectEdgeNone:
        case UIRectEdgeAll:
        case UIRectEdgeTop: {
            gradientLayer.startPoint = CGPointMake(0, 0);
            gradientLayer.endPoint = CGPointMake(0, 1.0);
        } break;
        case UIRectEdgeBottom: {
            gradientLayer.startPoint = CGPointMake(0, 1.0);
            gradientLayer.endPoint = CGPointMake(0, 0);
        } break;
        case UIRectEdgeLeft: {
            gradientLayer.startPoint = CGPointMake(0, 0);
            gradientLayer.endPoint = CGPointMake(1.0, 0);
        } break;
        case UIRectEdgeRight: {
            gradientLayer.startPoint = CGPointMake(1.0, 0);
            gradientLayer.endPoint = CGPointMake(0, 0);
        } break;
        default:
            break;
    }
    gradientLayer.frame = frame;
    return gradientLayer;
}

@end


@implementation UIImageView (LSTools)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self exchangeInstanceMethodWithSelfClass:self
                                 originalSelector:@selector(setImage:)
                                 swizzledSelector:@selector(ls_setImage:)];
    });
}

- (void)ls_setImage:(UIImage *)image {
    [self ls_setImage:image];
    CALayer *layer = [self ls_makeLayer];
    if (image && self.frame.size.width && layer) {
        layer.frame = self.bounds;
    }
}

- (CALayer *)ls_makeLayer {
    return objc_getAssociatedObject(self, _cmd);
}

- (LSImageViewMaskBlock)ls_setMask {
    return ^(UIColor *tintClr, NSInteger max, NSArray <NSNumber *>* indexs, UIRectEdge direct) {
        NSMutableArray <UIColor *>* clrs = [NSMutableArray arrayWithCapacity:max];
        for (NSInteger i = 0; i < max; i++) {
            [clrs addObject:UIColor.clearColor];
            indexs.each(^(NSNumber *obj, NSInteger idx, BOOL * _Nonnull stop) {
                if (obj.integerValue == i) {
                    clrs[i] = tintClr;
                    *stop = YES;
                }
            });
        }
        CALayer *layer = [CALayer layerColors:clrs withDirection:direct andFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        objc_setAssociatedObject(self, @selector(ls_makeLayer), layer, OBJC_ASSOCIATION_ASSIGN);
        [self.layer addSublayer:layer];
        return self;
    };
}

- (LSImageViewSetImageBlock)ls_setImage {
    return ^(UIImage *image, CGSize size) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage *newImage = nil;
            if (size.width / size.height - image.size.width / image.size.height < 0.1) {
                UIGraphicsBeginImageContextWithOptions(size, YES, 0);
                [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
                newImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }else {
                newImage = image;
            }
            dispatch_on_main_queue(^{
                self.image = newImage;
            });
        });
    };
}

@end
