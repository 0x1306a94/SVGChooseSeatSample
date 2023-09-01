//
//  NSBundle+SVGResources.m
//  SVGChooseSeatSample
//
//  Created by king on 2023/8/29.
//

#import "NSBundle+SVGResources.h"

@implementation NSBundle (SVGResources)
+ (NSBundle *_Nullable)kk_SVGResources {
    static NSBundle *__bunlde__ = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"SVGResources" withExtension:@"bundle"];
        __bunlde__ = [NSBundle bundleWithURL:url];
    });
    return __bunlde__;
}
@end
