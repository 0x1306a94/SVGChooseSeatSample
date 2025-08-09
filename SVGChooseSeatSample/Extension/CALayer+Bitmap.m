//
//  CALayer+Bitmap.m
//  SVGChooseSeatSample
//
//  Created by king on 2023/10/15.
//

#import "CALayer+Bitmap.h"

#import <UIKit/UIGraphicsImageRenderer.h>
@implementation CALayer (Bitmap)
- (UIImage *)kk_toImage:(CGFloat)scale {

    UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat preferredFormat];
    format.scale = scale;
    format.opaque = self.opaque;

    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:self.frame.size format:format];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *_Nonnull rendererContext) {
        [self renderInContext:rendererContext.CGContext];
    }];
    return image;
}
@end
