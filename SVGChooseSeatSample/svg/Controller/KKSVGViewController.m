//
//  KKSVGViewController.m
//  SVGChooseSeatSample
//
//  Created by king on 2023/8/28.
//

#import "KKSVGViewController.h"

#import "KKSVGChooseSeatView.h"
#import "KKSVGDrawSeatView.h"

#import "NSBundle+SVGResources.h"

#import "KKChooseSeatHelper.h"
#import "KKChooseSeatModel.h"
#import "KKTradeSVGModel.h"

@import SVGKit;

@interface KKSVGViewController ()
@property (nonatomic, strong) KKSVGChooseSeatView *chooseSeatView;
@property (nonatomic, assign) CGFloat zoomScale9;
@property (nonatomic, assign) CGFloat zoomScale18;
@property (nonatomic, assign) CGFloat zoomScale30;
@property (nonatomic, assign) CGFloat zoomScale50;

@property (nonatomic, assign) CGFloat svgScale;
@property (nonatomic, strong) KKTradeSVGModel *svgModel;
@property (nonatomic, assign) CGSize boxSize;

@property (nonatomic, strong) KKChooseSeatModel *choosetSeatModel;
@end

@implementation KKSVGViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.choosetSeatModel = [KKChooseSeatModel new];

    KKSVGChooseSeatView *chooseSeatView = [[KKSVGChooseSeatView alloc] init];
    self.chooseSeatView = chooseSeatView;
    chooseSeatView.backgroundColor = UIColor.orangeColor;
    [self.view addSubview:chooseSeatView];
    chooseSeatView.translatesAutoresizingMaskIntoConstraints = NO;

    [NSLayoutConstraint activateConstraints:@[
        [chooseSeatView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [chooseSeatView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [chooseSeatView.heightAnchor constraintEqualToAnchor:chooseSeatView.widthAnchor multiplier:662.0 / 414.0],
        [chooseSeatView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        //        [chooseSeatView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:50],
        //        [chooseSeatView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-50],
    ]];

    [self.view layoutIfNeeded];

    SVGKImage *image = [SVGKImage imageNamed:@"performbg_2" inBundle:[NSBundle kk_SVGResources]];

    self.svgModel = [KKChooseSeatHelper parserWithSVGImage:image];
    self.svgScale = [KKChooseSeatHelper getSvgScaleWithSvgMode:self.svgModel];

    KKSVGDrawSeatView *drawSeatView = chooseSeatView.drawSeatView;
    drawSeatView.seatWidth = self.svgScale * 12.0 / self.svgModel.scale;
    drawSeatView.scale = self.svgScale / self.svgModel.scale;
    CGFloat boxWidth = self.svgModel.width * self.svgScale;
    CGFloat boxHeight = self.svgModel.height * self.svgScale;
    self.boxSize = CGSizeMake(boxWidth, boxHeight);

    NSLog(@"svgScale: %f svgModel Scale: %f boxSize: %@ seatWidth: %f seatScale: %f", self.svgScale, self.svgModel.scale, NSStringFromCGSize(self.boxSize), drawSeatView.seatWidth, drawSeatView.scale);
    [image scaleToFitInside:self.boxSize];
    [chooseSeatView setContentSize:self.boxSize];

    [self setZoomScale];

    chooseSeatView.layeredImageView.image = image;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)setZoomScale {

    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat svgScale = self.svgScale;
    CGFloat svgModelScale = self.svgModel.scale;

    // 1. 计算不同级别下的缩放比例

    // zoomScale9
    // `self.zoomScale9 = viewWidth / (svgScale * 36.0 / svgModelScale * 9.0);`
    // 简化: `viewWidth / (svgScale * 324.0 / svgModelScale)`
    self.zoomScale9 = viewWidth / ((svgScale * 36.0) / svgModelScale * 9.0);

    // zoomScale18
    // `self.zoomScale18 = viewWidth / (svgScale * 36.0 / svgModelScale * 18.0);`
    // 简化: `viewWidth / (svgScale * 648.0 / svgModelScale)`
    self.zoomScale18 = viewWidth / ((svgScale * 36.0) / svgModelScale * 18.0);

    // zoomScale30
    // `self.zoomScale30 = viewWidth / (svgScale * 36.0 / svgModelScale * 36.0);`
    // 简化: `viewWidth / (svgScale * 1296.0 / svgModelScale)`
    self.zoomScale30 = viewWidth / ((svgScale * 36.0) / svgModelScale * 36.0);

    // zoomScale50
    // `self.zoomScale50 = viewWidth / (svgScale * 36.0 / svgModelScale * 50.0);`
    // 简化: `viewWidth / (svgScale * 1800.0 / svgModelScale)`
    self.zoomScale50 = viewWidth / ((svgScale * 36.0) / svgModelScale * 50.0);

    // 2. 设置最大缩放比例 (maximumZoomScale)

    // 计算一个基础缩放比例
    // `v26 = 1.0 / (svgScale / svgModelScale);`
    CGFloat baseScale = 1.0 / (svgScale / svgModelScale);

    CGFloat maximumZoomScale = self.zoomScale9;

    // 确保最大缩放比例不小于这个基础比例
    if (maximumZoomScale < baseScale) {
        maximumZoomScale = baseScale;
    }

    // 获取 chooseSeatView 的 scrollView，并设置 maximumZoomScale
    UIScrollView *scrollView = self.chooseSeatView.scrollView;
    [scrollView setMaximumZoomScale:maximumZoomScale];

    // 3. 设置最小缩放比例 (minimumZoomScale)

    // `v31 = viewWidth / self.boxSize.width;`
    // boxSize 是一个 CGRect，这里的 width 可能是整个座位的 bounding box 的宽度
    CGFloat minimumZoomScale = viewWidth / self.boxSize.width;

    // 获取 chooseSeatView 的 scrollView，并设置 minimumZoomScale
    [scrollView setMinimumZoomScale:minimumZoomScale];

    NSLog(@"minimumZoomScale: %f svgModel maximumZoomScale: %f", minimumZoomScale, maximumZoomScale);
}

/*
// 假设 a3 是 seatListDic，a4 是 error
- (void)getSeatListCompletionWithSeatListDic:(NSDictionary *)seatListDic error:(NSError *)error {
    
    // v25 对应 seatListDic
    // 假设 self.chooseSeatModel 包含座位区域信息
    
    // 获取座位区域信息和区域列表
    DMSeatAreaInfo *seatAreaInfo = self.chooseSeatModel.seatAreaInfo; // v5
    NSArray *areaList = seatAreaInfo.areaList; // v6
    
    // 遍历 areaList 中的每个区域（DMSeatAreaModel）
    for (SeatAreaModel *area in areaList) { // 外部循环
        
        // 获取区域的 areaId，并格式化为字符串作为字典的键
        NSString *areaId = area.areaId;
        NSString *areaIdString = [NSString stringWithFormat:@"%@", areaId]; // v10
        
        // 从 seatListDic 中获取该区域的座位列表
        // v11 是座位列表，一个 NSArray
        NSArray *seatsForArea = [seatListDic objectForKey:areaIdString];

        // 如果该区域有座位数据
        if (seatsForArea.count > 0) {
            
            // 遍历该区域的每个座位（SeatModel）
            for (SeatModel *seat in seatsForArea) { // 内部循环
                
                // 检查 svgImage 是否存在，如果存在则进行位置转换
                if (self.svgImage) {
                    
                    // 获取座位的原始位置
                    CGPoint originalLocation = [seat origLocation]; // v14, v18
                    
                    // 获取缩放比例
                    CGFloat svgScale = self.svgScale; // self->_svgScale
                    CGFloat svgModelScale = self.svgModel.scale; // v16, v20

                    // 计算新的位置
                    // newX = (originalLocation.x * svgScale) / svgModel.scale
                    // newY = (originalLocation.y * svgScale) / svgModel.scale
                    CGFloat newX = (originalLocation.x * svgScale) / svgModelScale; // v17
                    CGFloat newY = (originalLocation.y * svgScale) / svgModelScale; // v19
                    
                    // 设置座位的新位置
                    [seat setLocation:CGPointMake(newX, newY)];
                }
                
                // 将区域名称设置到座位模型中
                // v21 是 area.areaName
                [seat setKantaiName:area.areaName];
                
                // 将区域 ID 设置到座位模型中
                // v22 是 area.areaId
                [seat setAreaId:area.areaId];
            }
            
            // 将处理好的座位列表设置回 area 模型中
            [area setSeats:seatsForArea];
        }
    }
}
 */
@end
