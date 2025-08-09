//
//  KKChooseSeatHelper.m
//  SVGChooseSeatSample
//
//  Created by KK on 2025/8/3.
//

#import "KKChooseSeatHelper.h"

#import "KKTradeSVGItemModel.h"
#import "KKTradeSVGModel.h"

@import SVGKit;

@implementation KKChooseSeatHelper
+ (KKTradeSVGModel *)parserWithSVGImage:(SVGKImage *)image {
    KKTradeSVGModel *svgModel = [KKTradeSVGModel new];
    SVGSVGElement *domTree = image.DOMTree;
    NSString *transform = [domTree getAttribute:@"transform"];
    if ([transform containsString:@"scale"]) {
        NSArray<NSString *> *components = [transform componentsSeparatedByString:@" "];
        for (NSString *item in components) {
            if ([item containsString:@"scale"]) {
                NSString *value = [item stringByReplacingOccurrencesOfString:@"scale(" withString:@""];
                value = [value stringByReplacingOccurrencesOfString:@")" withString:@""];
                CGFloat scale = [value floatValue];
                svgModel.scale = scale;
                break;
            }
        }
    }

    if (svgModel.scale == 0.0) {
        svgModel.scale = 1.0;
    }

    // 初始化用于存储解析结果的容器
    NSMutableArray<KKTradeSVGItemModel *> *nodeList = [NSMutableArray<KKTradeSVGItemModel *> array];
    NSMutableDictionary *floorIdSVGItemModelDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *floorIdRectsDict = [NSMutableDictionary dictionary];

    // 获取所有 SVG 元素
    NSArray *allElements = [self getAllElementWithNodeList:domTree.childNodes];

    BOOL hasRowIdError = NO;
    BOOL hasFloorIdError = NO;

    // 遍历所有 SVG 元素
    for (SVGElement *element in allElements) {

        // 获取元素的 floorId
        NSString *floorId = [self getValueFrameNode:element forKey:@"floorId"];

        if (floorId && ![floorId isEqual:[NSNull null]]) {
            floorId = [NSString stringWithFormat:@"%@", floorId];
            hasFloorIdError = YES;
        }

        // 获取元素的 row_id
        Attr *rowIdAttribute = [element getAttributeNode:@"row_id"];

        // 检查元素是否为 SVG 形状、floorId 是否有效，且没有 row_id
        if ([element isKindOfClass:[BaseClassForAllSVGBasicShapes class]] &&
            floorId.length > 0 &&
            !rowIdAttribute) {

            // 获取该 floorId 对应的 rects 数组，如果不存在则创建
            NSMutableArray *rectsForFloorId = [floorIdRectsDict objectForKeyedSubscript:floorId];
            if (!rectsForFloorId) {
                rectsForFloorId = [NSMutableArray array];
                [floorIdRectsDict setObject:rectsForFloorId forKeyedSubscript:floorId];
            }

            // 获取元素的 CGPath 并应用 transform
            CGPathRef relativePath = [(BaseClassForAllSVGBasicShapes *)element pathForShapeInRelativeCoords];
            CGAffineTransform transform = [(BaseClassForAllSVGBasicShapes *)element transform];
            // 如果 transform 属性存在，应用 transform
            NSString *transformString = [self getAttributeValueForElement:element attribute:@"transform"];
            if (transformString.length > 0) {
                relativePath = CGPathCreateCopyByTransformingPath(relativePath, &transform);
            }

            // 获取路径的边界框
            CGRect pathBoundingBox = CGPathGetPathBoundingBox(relativePath);
            // 将边界框封装成 NSValue 并添加到 rects 数组
            [rectsForFloorId addObject:[NSValue valueWithCGRect:pathBoundingBox]];
            // 创建 ChooseSeatHelper 内部的 SVGItemModel
            KKTradeSVGItemModel *svgItemModel = [self getSVGItemWithNode:element];
            [svgItemModel setPathRect:pathBoundingBox];
            [svgItemModel setPathRef:relativePath];
            [svgItemModel setElement:element];

            // 将 itemModel 存储到字典和数组中
            [floorIdSVGItemModelDict setObject:svgItemModel forKeyedSubscript:floorId];
            [nodeList addObject:svgItemModel];

            hasRowIdError = YES;
        }
    }

    // 处理解析错误
    NSError *fatalErrors = [image.parseErrorsAndWarnings.errorsFatal lastObject];
    svgModel.fatalParseError = fatalErrors;

    [svgModel setFloorIdError:!hasFloorIdError];
    [svgModel setRow_idError:!hasRowIdError];

    // 将解析出的数据设置到 svgModel 中
    [svgModel setFloorIdRectsDict:floorIdRectsDict];
    [svgModel setFloorIdSVGItemModelDict:floorIdSVGItemModelDict];
    [svgModel setNodeList:nodeList];

    SVGLength *svgWidth = [domTree width];
    SVGLength *svgHeight = [domTree height];

    SVGRect viewBox = [domTree viewBox];

    if (svgWidth && svgWidth.unitType != SVG_LENGTHTYPE_PERCENTAGE) {
        if (svgHeight) {
            goto LABEL_42;
        }
    } else {
        if (viewBox.width <= 0) {
            viewBox.width = 3000.0;
            svgWidth = [SVGLength svgLengthFromNSString:[NSString stringWithFormat:@"%f", viewBox.width]];
            [domTree setWidth:svgWidth];
        }
    }

LABEL_42:
    if (svgHeight && svgHeight.unitType != SVG_LENGTHTYPE_PERCENTAGE) {
        goto LABEL_48;
    } else {
        if (viewBox.height <= 0) {
            viewBox.height = 3000.0;
            svgHeight = [SVGLength svgLengthFromNSString:[NSString stringWithFormat:@"%f", viewBox.height]];
            [domTree setWidth:svgHeight];
        }
    }

LABEL_48:
    [svgModel setWidth:[svgWidth value]];
    [svgModel setHeight:[svgHeight value]];

    if (!SVGRectIsInitialized(domTree.viewBox) && !SVGRectIsInitialized(domTree.viewport)) {
        [domTree setViewBox:viewBox];
    }

    return svgModel;
}

+ (NSArray *)getAllElementWithNodeList:(NodeList *)nodeList {
    if (nodeList.length == 0) {
        return @[];
    }
    NSMutableArray *allElements = [[NSMutableArray alloc] init];  // v14
    for (NSUInteger i = 0; i < nodeList.length; i++) {
        Node *node = [nodeList item:i];
        if ([node isKindOfClass:[SVGElement class]]) {
            SVGElement *element = (SVGElement *)node;
            NSString *tagName = [element tagName];

            if ([tagName isEqualToString:@"g"]) {
                NodeList *childNodes = [element childNodes];
                NSArray *childElements = [self getAllElementWithNodeList:childNodes];
                [allElements addObjectsFromArray:childElements];
            } else {
                [allElements addObject:element];
            }
        }
    }

    return [allElements copy];
}

+ (NSString *_Nullable)getValueFrameNode:(SVGElement *)element forKey:(NSString *)key {
    if (key == nil) {
        return nil;
    }

    if (![element isKindOfClass:Element.class]) {
        return nil;
    }
    Attr *attr = [element getAttributeNode:key];
    NSString *value = [attr value];
    return value;
}

// 假设 Element 是一个 SVG 元素对象，attribute 是一个 NSString
+ (NSString *)getAttributeValueForElement:(SVGElement *)element attribute:(NSString *)attribute {

    // 默认返回值为空字符串
    NSString *resultString = @"";

    // 如果元素是 BaseClassForAllSVGBasicShapes 的子类
    if ([element isKindOfClass:[BaseClassForAllSVGBasicShapes class]]) {

        // 获取元素的 style 属性
        CSSStyleDeclaration *style = [element style];
        // 获取 style 的 cssText，例如 "fill: red; stroke: black;"
        NSString *cssText = [style cssText];

        // 将 cssText 拆分成单独的样式声明
        NSArray *styleDeclarations = [cssText componentsSeparatedByString:@";"];

        // 遍历样式声明，查找匹配的属性
        if (styleDeclarations.count > 0) {

            // 格式化要查找的属性名，例如 "transform:"
            NSString *searchAttribute = [NSString stringWithFormat:@"%@:", attribute];

            for (NSString *declaration in styleDeclarations) {
                // 去除声明中的空格，例如 "fill: red" -> "fill:red"
                NSString *cleanDeclaration = [declaration stringByReplacingOccurrencesOfString:@" " withString:@""];

                // 如果这个样式声明包含了我们要找的属性名
                if ([cleanDeclaration containsString:searchAttribute]) {

                    // 拆分出值的部分，例如 "fill:red" -> "red"
                    NSArray *components = [cleanDeclaration componentsSeparatedByString:@":"];

                    // 确保有值，并赋值给 resultString
                    if (components.count > 1) {
                        resultString = [components objectAtIndex:1];
                    }

                    break;
                }
            }
        }

        Attr *attributeNode = [element getAttributeNode:attribute];
        NSString *attributeValue = [attributeNode value];
        if (attributeValue) {
            resultString = attributeValue;
        }
    }

    return resultString;
}

// 假设 element 是一个 SVG 元素对象
+ (KKTradeSVGItemModel *)getSVGItemWithNode:(SVGElement *)element {

    // a3 对应传入的 element

    // 创建一个新的 KKTradeSVGItemModel 对象
    KKTradeSVGItemModel *svgItemModel = [[KKTradeSVGItemModel alloc] init];

    // 如果 element 是 BaseClassForAllSVGBasicShapes 的实例，则填充一些与路径相关的属性
    if ([element isKindOfClass:[BaseClassForAllSVGBasicShapes class]]) {

        // 获取元素的 CGPath 并计算其边界框
        CGPathRef pathRef = [(BaseClassForAllSVGBasicShapes *)element pathForShapeInRelativeCoords];
        CGRect boundingBox = CGPathGetBoundingBox(pathRef);

        // 设置 KKTradeSVGItemModel 的路径相关属性
        [svgItemModel setPathRect:boundingBox];
        [svgItemModel setPathRef:pathRef];
        [svgItemModel setElement:element];
    }

    // 接下来，通过反复调用 ChooseSeatHelper 的另一个方法来获取各种属性值，并设置到 svgItemModel 中

    // 获取 "x" 属性并设置
    NSString *xValue = [self getValueFrameNode:element forKey:@"x"];
    [svgItemModel setX:xValue];

    // 获取 "y" 属性并设置
    NSString *yValue = [self getValueFrameNode:element forKey:@"y"];
    [svgItemModel setY:yValue];

    // 获取 "fill" 属性并设置
    NSString *fillValue = [self getValueFrameNode:element forKey:@"fill"];
    [svgItemModel setFill:fillValue];

    // 获取 "stroke" 属性并设置
    NSString *strokeValue = [self getValueFrameNode:element forKey:@"stroke"];
    [svgItemModel setStroke:strokeValue];

    // 获取 "stroke-width" 属性并设置
    NSString *strokeWidthValue = [self getValueFrameNode:element forKey:@"stroke-width"];
    [svgItemModel setStroke_width:strokeWidthValue];

    // 获取 "stroke-miterlimit" 属性并设置
    NSString *strokeMiterlimitValue = [self getValueFrameNode:element forKey:@"stroke-miterlimit"];
    [svgItemModel setStroke_miterlimit:strokeMiterlimitValue];

    // 获取 "width" 属性并设置
    NSString *widthValue = [self getValueFrameNode:element forKey:@"width"];
    [svgItemModel setWidth:widthValue];

    // 获取 "height" 属性并设置
    NSString *heightValue = [self getValueFrameNode:element forKey:@"height"];
    [svgItemModel setHeight:heightValue];

    // 获取 "static_resource_id" 属性并设置
    NSString *staticResourceIdValue = [self getValueFrameNode:element forKey:@"static_resource_id"];
    [svgItemModel setStatic_resource_id:staticResourceIdValue];

    // 获取 "class" 属性并设置
    NSString *svgClassValue = [self getValueFrameNode:element forKey:@"class"];
    [svgItemModel setSvgClass:svgClassValue];

    // 获取 "static_resource_typex" 属性并设置
    NSString *staticResourceTypexValue = [self getValueFrameNode:element forKey:@"static_resource_typex"];
    [svgItemModel setStatic_resource_typex:staticResourceTypexValue];

    // 获取 "transform" 属性并设置
    NSString *transformValue = [self getValueFrameNode:element forKey:@"transform"];
    [svgItemModel setTransform:transformValue];

    // 获取 "bound" 属性并设置
    NSString *boundValue = [self getValueFrameNode:element forKey:@"bound"];
    [svgItemModel setBound:boundValue];

    // 获取 "floorId" 属性并设置
    NSString *floorIdValue = [self getValueFrameNode:element forKey:@"floorId"];
    [svgItemModel setFloorId:floorIdValue];

    // 获取 "floorName" 属性并设置
    NSString *floorNameValue = [self getValueFrameNode:element forKey:@"floorName"];
    [svgItemModel setFloorName:floorNameValue];

    // 获取 "static_resource_desc" 属性并设置
    NSString *staticResourceDescValue = [self getValueFrameNode:element forKey:@"static_resource_desc"];
    [svgItemModel setStatic_resource_desc:staticResourceDescValue];

    // 获取 "points" 属性并设置
    NSString *pointsValue = [self getValueFrameNode:element forKey:@"points"];
    [svgItemModel setPoints:pointsValue];

    // 获取 "d" (path data) 属性并设置
    NSString *dValue = [self getValueFrameNode:element forKey:@"d"];
    [svgItemModel setD:dValue];

    // 获取 "style" 属性并设置
    NSString *styleValue = [self getValueFrameNode:element forKey:@"style"];
    [svgItemModel setStyle:styleValue];

    return svgItemModel;
}

+ (CGFloat)getSvgScaleWithSvgMode:(KKTradeSVGModel *)svgModel {

    // 根据一个配置索引来确定最大宽度
    CGFloat maxWidth;  // v4
    if (YES /*[ChooseSeatHelper chooseSeatConfigIndex:5] == YES*/) {
        maxWidth = 1000.0;
    } else {
        maxWidth = 4000.0;
    }

    CGFloat scale = 1.0;
    CGFloat svgWidth = [svgModel width];
    if (svgWidth > 0.0 && svgWidth > maxWidth) {
        scale = maxWidth / svgWidth;
    }
    return scale;
}

@end
