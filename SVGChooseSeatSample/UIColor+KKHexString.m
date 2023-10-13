//
//  UIColor+KKHexString.m
//  SVGChooseSeatSample
//
//  Created by king on 2023/10/13.
//

#import "UIColor+KKHexString.h"

@implementation UIColor (KKHexString)
- (NSString *)kk_css_rgba {
    CGFloat r, g, b, a;
    if (![self getRed:&r green:&g blue:&b alpha:&a]) {
        return nil;
    }
    NSString *rgba = [NSString stringWithFormat:@"rgba(%.0f,%.0f,%.0f,%.2f)",
                                                round(r * 255),
                                                round(g * 255),
                                                round(b * 255),
                                                a];
    return rgba;
}
@end
