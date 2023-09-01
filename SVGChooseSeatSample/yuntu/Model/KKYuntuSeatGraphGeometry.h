//
//  KKYuntuSeatGraphGeometry.h
//  SVGChooseSeatSample
//
//  Created by king on 2023/8/30.
//

#ifndef KKYuntuSeatGraphGeometry_h
#define KKYuntuSeatGraphGeometry_h

#import <CoreGraphics/CGGeometry.h>
#import <Foundation/Foundation.h>

typedef struct {
    NSInteger x;
    NSInteger y;
} KKYuntuSeatGraphPoint;

typedef struct {
    NSInteger w;
    NSInteger h;
} KKYuntuSeatGraphSize;

typedef struct {
    KKYuntuSeatGraphPoint origin;
    KKYuntuSeatGraphSize size;
} KKYuntuSeatGraphRect;

NS_INLINE CGSize CGSizeFromKKYuntuSeatGraphSize(KKYuntuSeatGraphSize from) {
    return CGSizeMake((CGFloat)from.w, (CGFloat)from.h);
};

NS_INLINE CGRect CGRectFromKKYuntuSeatGraphRect(KKYuntuSeatGraphRect from) {
    return CGRectMake((CGFloat)from.origin.x, (CGFloat)from.origin.y, (CGFloat)from.size.w, (CGFloat)from.size.h);
};
#endif /* KKYuntuSeatGraphGeometry_h */
