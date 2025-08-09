//
//  KKTradeSVGItemModel.h
//  SVGChooseSeatSample
//
//  Created by KK on 2025/8/3.
//

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@class SVGElement;
@interface KKTradeSVGItemModel : NSObject
@property (nonatomic, assign) CGRect pathRect;
@property (nonatomic, assign) CGPathRef pathRef;
@property (nonatomic, strong) SVGElement *element;
@property (nonatomic, strong) NSString *x;
@property (nonatomic, strong) NSString *y;
@property (nonatomic, strong) NSString *fill;
@property (nonatomic, strong) NSString *stroke;
@property (nonatomic, strong) NSString *stroke_width;
@property (nonatomic, strong) NSString *stroke_miterlimit;
@property (nonatomic, strong) NSString *width;
@property (nonatomic, strong) NSString *height;
@property (nonatomic, strong) NSString *static_resource_id;
@property (nonatomic, strong) NSString *svgClass;
@property (nonatomic, strong) NSString *static_resource_typex;
@property (nonatomic, strong) NSString *transform;
@property (nonatomic, strong) NSString *bound;
@property (nonatomic, strong) NSString *floorId;
@property (nonatomic, strong) NSString *floorName;
@property (nonatomic, strong) NSString *static_resource_desc;
@property (nonatomic, strong) NSString *points;
@property (nonatomic, strong) NSString *d;
@property (nonatomic, strong) NSString *style;
@end

NS_ASSUME_NONNULL_END
