//
//  KKTradeSVGModel.h
//  SVGChooseSeatSample
//
//  Created by KK on 2025/8/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class KKTradeSVGItemModel;
@interface KKTradeSVGModel : NSObject
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, strong) NSError *fatalParseError;
@property (nonatomic, assign) BOOL floorIdError;
@property (nonatomic, assign) BOOL row_idError;
@property (nonatomic, strong) NSDictionary *floorIdRectsDict;
@property (nonatomic, strong) NSDictionary *floorIdSVGItemModelDict;
@property (nonatomic, strong) NSArray<KKTradeSVGItemModel *> *nodeList;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@end

NS_ASSUME_NONNULL_END
