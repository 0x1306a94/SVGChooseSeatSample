//
//  KKYuntuSeatAreaRainbowGenerator.m
//  SVGChooseSeatSample
//
//  Created by king on 2023/8/31.
//

#import "KKYuntuSeatAreaRainbowGenerator.h"

#import "KKYuntuSeatAreaModel.h"

#import <GLKit/GLKMathUtils.h>
#import <UIKit/UIKit.h>

#import <YYModel/NSObject+YYModel.h>

@import SVGKit;

@interface KKYuntuSeatAreaRainbowDrawCommand : NSObject <NSCopying>
@property (nonatomic, assign) NSInteger zIndex;
@property (nonatomic, assign) CGRect rect;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIBezierPath *path1;
@property (nonatomic, strong) UIBezierPath *path2;
@property (nonatomic, assign) CGAffineTransform transform;
@end

@implementation KKYuntuSeatAreaRainbowDrawCommand
- (id)copyWithZone:(NSZone *)zone {
    return [self yy_modelCopy];
}

@end

@interface KKYuntuSeatAreaRainbowGenerator ()
@property (nonatomic, strong) UIImage *baseImage;
@property (nonatomic, strong) NSArray<KKYuntuSeatAreaModel *> *areas;
@property (nonatomic, strong) NSMutableArray<KKYuntuSeatAreaRainbowDrawCommand *> *drawCommands;
@end

@implementation KKYuntuSeatAreaRainbowGenerator
- (instancetype)initWithBaseImage:(UIImage *)baseImage areas:(NSArray<KKYuntuSeatAreaModel *> *)areas {
    if (self == [super init]) {
        self.baseImage = baseImage;
        self.areas = areas;
        self.drawCommands = [NSMutableArray<KKYuntuSeatAreaRainbowDrawCommand *> arrayWithCapacity:areas.count];
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    NSString *rectPattern = @"width: (\\d+)px; height: (\\d+)px; .* z-index: (\\d+); left: (\\d+)px; top: (\\d+)px;";
    NSRegularExpression *rectRegularExpression = [[NSRegularExpression alloc] initWithPattern:rectPattern options:NSRegularExpressionCaseInsensitive error:nil];

    for (KKYuntuSeatAreaModel *area in self.areas) {
        NSString *shapestyle = area.shapestyle;
        if (shapestyle.length == 0) {
            continue;
        }
        NSTextCheckingResult *matchs = [rectRegularExpression matchesInString:shapestyle options:NSMatchingReportCompletion range:NSMakeRange(0, shapestyle.length)].firstObject;
        if (matchs == nil || matchs.numberOfRanges != 6) {
            continue;
        }

        // 解析rect
        CGRect rect = CGRectZero;
        NSString *width = [shapestyle substringWithRange:[matchs rangeAtIndex:1]];
        NSString *height = [shapestyle substringWithRange:[matchs rangeAtIndex:2]];
        NSString *left = [shapestyle substringWithRange:[matchs rangeAtIndex:4]];
        NSString *top = [shapestyle substringWithRange:[matchs rangeAtIndex:5]];
        rect.origin = CGPointMake(left.floatValue, top.floatValue);
        rect.size = CGSizeMake(width.floatValue, height.floatValue);

        NSInteger zIndex = [[shapestyle substringWithRange:[matchs rangeAtIndex:3]] integerValue];
        // 解析color
        UIColor *fillColor = UIColor.clearColor;
        do {
            NSString *color = area.color;
            fillColor = [UIColor colorWithCGColor:CGColorWithSVGColor(SVGColorFromString(color.UTF8String))];
        } while (0);

        // path
        UIBezierPath *path1 = [self parseClipPathFrom:area.nstyle containerSize:rect.size];
        UIBezierPath *path2 = [self parseClipPathFrom:area.nstyle2 containerSize:rect.size];
        KKYuntuSeatAreaRainbowDrawCommand *drawCommand = [KKYuntuSeatAreaRainbowDrawCommand new];
        drawCommand.zIndex = zIndex;
        drawCommand.rect = rect;
        drawCommand.color = fillColor;
        drawCommand.path1 = path1;
        drawCommand.path2 = path2;
        drawCommand.transform = CGAffineTransformIdentity;

        do {
            if (area.fzzstyle.length > 0) {
                NSString *fzzstyle = area.fzzstyle;
                NSRange range = [fzzstyle rangeOfString:@"rotate("];
                if (range.location != NSNotFound) {
                    NSRange valueRange = NSMakeRange(range.location + range.length, fzzstyle.length - 5 - range.location - range.length);
                    NSString *value = [fzzstyle substringWithRange:valueRange];
                    float deg = [value floatValue];

                    CGPoint centenr = CGPointMake(rect.size.width * 0.5, rect.size.height * 0.5);
                    CGAffineTransform transform = CGAffineTransformMakeTranslation(centenr.x, centenr.y);
                    transform = CGAffineTransformRotate(transform, GLKMathDegreesToRadians(deg));
                    transform = CGAffineTransformTranslate(transform, -centenr.x, -centenr.y);

                    drawCommand.transform = transform;
                }
            }
        } while (0);

        [self.drawCommands addObject:drawCommand];
    }

    [self.drawCommands sortUsingComparator:^NSComparisonResult(KKYuntuSeatAreaRainbowDrawCommand *_Nonnull obj1, KKYuntuSeatAreaRainbowDrawCommand *_Nonnull obj2) {
        return obj1.zIndex - obj2.zIndex;
    }];
    asm("nop");
}

- (UIBezierPath *)parseClipPathFrom:(NSString *)str containerSize:(CGSize)containerSize {
    if (str == nil || str.length == 0) {
        return nil;
    }
    NSString *pathPattern = @"-webkit-clip-path:\\s*(.*?);";
    NSRegularExpression *pathRegularExpression = [[NSRegularExpression alloc] initWithPattern:pathPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray<__kindof NSTextCheckingResult *> *matchs = [pathRegularExpression matchesInString:str options:NSMatchingReportCompletion range:NSMakeRange(0, str.length)];
    UIBezierPath *mainPath = [UIBezierPath bezierPath];
    for (NSTextCheckingResult *match in matchs) {
        if (match.numberOfRanges != 2) {
            continue;
        }
        NSString *subStr = [str substringWithRange:[match rangeAtIndex:1]];
        if ([subStr hasPrefix:@"polygon("]) {
            UIBezierPath *path = [self parsePolygonPath:subStr containerSize:containerSize];
            if (path && ![path isEmpty]) {
                [mainPath appendPath:path];
            }
        } else if ([subStr hasPrefix:@"circle("]) {
            UIBezierPath *path = [self parseCirclePath:subStr containerSize:containerSize];
            if (path && ![path isEmpty]) {
                [mainPath appendPath:path];
            }
        }
    }
    [mainPath closePath];
    return mainPath;
}

- (UIBezierPath *)parsePolygonPath:(NSString *)str containerSize:(CGSize)containerSize {
    if (str == nil || str.length == 0) {
        return nil;
    }
    NSString *pointStr = [str substringWithRange:NSMakeRange(8, str.length - 9)];
    NSArray<NSString *> *points = [pointStr componentsSeparatedByString:@", "];
    UIBezierPath *path = nil;
    NSMutableArray<NSValue *> *cgPoints = [NSMutableArray<NSValue *> arrayWithCapacity:10];
    for (NSString *p in points) {
        NSArray<NSString *> *arr = [p componentsSeparatedByString:@" "];
        if (arr.count != 2) {
            continue;
        }
        NSString *first = arr.firstObject;
        NSString *last = arr.lastObject;
        CGFloat x = 0;
        CGFloat y = 0;
        if ([first hasSuffix:@"%"] || [last hasSuffix:@"%"]) {
            first = [first stringByReplacingOccurrencesOfString:@"%" withString:@""];
            x = [first floatValue] / 100.0 * containerSize.width;

            last = [last stringByReplacingOccurrencesOfString:@"%" withString:@""];
            y = [last floatValue] / 100.0 * containerSize.height;
        } else if ([first hasSuffix:@"px"] || [last hasSuffix:@"px"]) {
            first = [first stringByReplacingOccurrencesOfString:@"px" withString:@""];
            x = [first floatValue];

            last = [last stringByReplacingOccurrencesOfString:@"px" withString:@""];
            y = [last floatValue];
        } else {
            continue;
        }

        [cgPoints addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
    }
    NSInteger pointsCount = cgPoints.count;
    if (pointsCount >= 3) {
        path = [UIBezierPath bezierPath];
        [path moveToPoint:cgPoints[0].CGPointValue];
        for (NSInteger i = 1; i < pointsCount; i++) {
            CGPoint endPoint = cgPoints[i].CGPointValue;
            [path addLineToPoint:endPoint];
            //            if (i < pointsCount - 1) {
            //                CGPoint nextPoint = cgPoints[i + 1].CGPointValue;
            //                CGPoint controlPoint = CGPointMake((endPoint.x + nextPoint.x) * 0.5, (endPoint.y + nextPoint.y) * 0.5);
            //                [path addQuadCurveToPoint:endPoint controlPoint:controlPoint];
            //            }
        }
    }
    [path closePath];

    return path;
}

- (UIBezierPath *)parseCirclePath:(NSString *)str containerSize:(CGSize)containerSize {
    if (str == nil || str.length == 0) {
        return nil;
    }
    NSScanner *scanner = [NSScanner scannerWithString:str];

    float radius = -1;
    float centerX = -1, centerY = -1;

    [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil];
    [scanner scanFloat:&radius];

    if ([str containsString:@"at center"]) {
        centerX = containerSize.width * 0.5;
        centerY = containerSize.height * 0.5;
    } else {
        [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil];
        [scanner scanFloat:&centerX];
        [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil];
        [scanner scanFloat:&centerY];

        centerX = (centerX / 100.0) * containerSize.width;
        centerY = (centerY / 100.0) * containerSize.height;
    }

    if (radius == -1 || centerX == -1 || centerY == -1) {
        return nil;
    }
    radius = (radius / 100.0) * fminf(containerSize.width, containerSize.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(centerX, centerY) radius:radius startAngle:GLKMathDegreesToRadians(0) endAngle:GLKMathDegreesToRadians(360) clockwise:YES];
    return path;
}

- (void)generateWithCompleteHandler:(void (^)(UIImage *_Nonnull))completeHandler {
    UIImage *baseImage = self.baseImage;
    NSArray<KKYuntuSeatAreaRainbowDrawCommand *> *drawCommands = [[NSArray<KKYuntuSeatAreaRainbowDrawCommand *> alloc] initWithArray:self.drawCommands copyItems:YES];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat preferredFormat];
        format.opaque = YES;
        format.scale = 1.0;
        UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:baseImage.size format:format];
        UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *_Nonnull rendererContext) {
            [baseImage drawAtPoint:CGPointZero];
            CGContextRef cgContext = rendererContext.CGContext;
            for (KKYuntuSeatAreaRainbowDrawCommand *command in drawCommands) {
                CGContextSaveGState(cgContext);
                UIBezierPath *path1 = command.path1;
                UIBezierPath *path2 = command.path2;

#if 0
                if (path1 && ![path1 isEmpty] && path2 && ![path2 isEmpty]) {
                    CGContextTranslateCTM(cgContext, command.rect.origin.x, command.rect.origin.y);
                    CGContextConcatCTM(cgContext, command.transform);
                    CGContextAddPath(cgContext, path1.CGPath);
                    [command.color setFill];
                    CGContextClip(cgContext);

                    CGContextAddPath(cgContext, path2.CGPath);
                    [command.color setFill];
                    CGContextFillPath(cgContext);
                } else if (path1 && ![path1 isEmpty]) {
                    CGContextTranslateCTM(cgContext, command.rect.origin.x, command.rect.origin.y);
                    CGContextConcatCTM(cgContext, command.transform);

                    CGContextAddPath(cgContext, path1.CGPath);
                    [command.color setFill];
                    CGContextFillPath(cgContext);
                } else {
                    CGContextTranslateCTM(cgContext, command.rect.origin.x, command.rect.origin.y);
                    CGContextConcatCTM(cgContext, command.transform);
                    [command.color setFill];
                    CGContextFillRect(cgContext, (CGRect){CGPointZero, command.rect.size});
                }
#else
                    CGContextTranslateCTM(cgContext, command.rect.origin.x, command.rect.origin.y);
                    CGContextConcatCTM(cgContext, command.transform);
                    if (path1 && ![path1 isEmpty]) {
                        //                        [path1 addClip];
                        CGContextAddPath(cgContext, path1.CGPath);
                        CGContextClip(cgContext);
                    }

                    if (path2 && ![path2 isEmpty]) {
                        //                        [path2 addClip];
                        CGContextAddPath(cgContext, path2.CGPath);
                        CGContextClip(cgContext);
                    }
                    [command.color setFill];
                    CGContextFillRect(cgContext, (CGRect){CGPointZero, command.rect.size});

#endif
                CGContextRestoreGState(cgContext);
            }
        }];
        !completeHandler ?: completeHandler(image);
    });
}
@end
