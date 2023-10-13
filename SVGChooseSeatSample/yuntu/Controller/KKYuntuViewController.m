//
//  KKYuntuViewController.m
//  SVGChooseSeatSample
//
//  Created by king on 2023/8/31.
//

#import "KKYuntuViewController.h"

#import "KKYuntuChooseSeatView.h"
#import "KKYuntuSeatDataManager.h"

#import "KKYuntuSeatAreaDetalModel.h"
#import "KKYuntuSeatAreaModel.h"
#import "KKYuntuSeatItemModel.h"

#import "KKYuntuSeatAreaRainbowGenerator.h"

@import YYModel;

@interface KKYuntuViewController ()
@property (nonatomic, strong) KKYuntuSeatDataManager *dataManager;
@property (nonatomic, strong) KKYuntuChooseSeatView *seatView;
@property (nonatomic, strong) UIImageView *miniMapView;
@property (nonatomic, strong) NSLayoutConstraint *miniMapViewWidthLayoutConstraint;
@property (nonatomic, strong) NSLayoutConstraint *miniMapViewHeightLayoutConstraint;
@property (nonatomic, strong) KKYuntuSeatAreaRainbowGenerator *generator;
@end

@implementation KKYuntuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    KKYuntuChooseSeatView *seatView = [[KKYuntuChooseSeatView alloc] init];
    self.seatView = seatView;
    seatView.backgroundColor = [UIColor colorWithRed:(0xf8 / 255.0) green:(0xf8 / 255.0) blue:(0xf8 / 255.0) alpha:1.0];
    seatView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:seatView];

    UIImageView *miniMapView = [UIImageView new];
    self.miniMapView = miniMapView;
    miniMapView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.5];
    miniMapView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:miniMapView];

    self.miniMapViewWidthLayoutConstraint = [miniMapView.widthAnchor constraintEqualToConstant:0];
    self.miniMapViewHeightLayoutConstraint = [miniMapView.heightAnchor constraintEqualToConstant:0];

    [NSLayoutConstraint activateConstraints:@[
        [seatView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [seatView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [seatView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:50],
        [seatView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-50],

        [miniMapView.topAnchor constraintEqualToAnchor:seatView.topAnchor],
        [miniMapView.trailingAnchor constraintEqualToAnchor:seatView.trailingAnchor],
        self.miniMapViewWidthLayoutConstraint,
        self.miniMapViewHeightLayoutConstraint,
    ]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupDataManager];
}

- (void)setupDataManager {
    if (self.dataManager) {
        return;
    }

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *areaData = [NSData dataWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"data" ofType:@"json"]];
        NSData *seatData = [NSData dataWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"large_seat" ofType:@"json"]];
        NSDictionary *areaDict = [NSJSONSerialization JSONObjectWithData:areaData options:NSJSONReadingAllowFragments error:nil];
        NSDictionary *seatDict = [NSJSONSerialization JSONObjectWithData:seatData options:NSJSONReadingAllowFragments error:nil];
        NSArray<KKYuntuSeatAreaModel *> *areas = @[];
        NSArray<KKYuntuSeatItemModel *> *seats = @[];
        if (areaDict) {
            areas = [NSArray yy_modelArrayWithClass:KKYuntuSeatAreaModel.class json:areaDict[@"data"]];
        }
        if (seatDict) {
            seats = [NSArray yy_modelArrayWithClass:KKYuntuSeatItemModel.class json:seatDict[@"list_Seat"]];
        }

        KKYuntuSeatDataManager *dataManager = [[KKYuntuSeatDataManager alloc] initWithAreas:areas seats:seats];
        [dataManager rebuildSeatData];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.dataManager = dataManager;
            KKYuntuSeatAreaDetalModel *area = [dataManager seatAreaDetalAtRegionCode:@"R1694234878897934338"];
            [self.seatView useSeatArea:area];
            [self setupSeatAreaRainbowGenerator];
        });
    });
}

- (void)setupSeatAreaRainbowGenerator {
    NSArray<KKYuntuSeatAreaModel *> *areas = [self.dataManager originAreas];
    UIImage *baseImage = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"yuntu_bg" ofType:@"jpg"]];
    self.generator = [[KKYuntuSeatAreaRainbowGenerator alloc] initWithBaseImage:baseImage areas:areas];
    [self.generator generateWithCompleteHandler:^(UIImage *_Nonnull outImage) {
        if (outImage == nil) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            CGFloat w = 220;//self.seatView.frame.size.width;
            CGSize size = CGSizeMake(w, ceil(w / outImage.size.width * outImage.size.height));
            self.miniMapViewWidthLayoutConstraint.constant = size.width;
            self.miniMapViewHeightLayoutConstraint.constant = size.height;
            self.miniMapView.image = outImage;
        });
    }];
}

@end
