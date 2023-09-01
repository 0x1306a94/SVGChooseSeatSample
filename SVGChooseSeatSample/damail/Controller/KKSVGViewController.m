//
//  KKSVGViewController.m
//  SVGChooseSeatSample
//
//  Created by king on 2023/8/28.
//

#import "KKSVGViewController.h"

#import "KKSVGChooseSeatView.h"

#import "NSBundle+SVGResources.h"

@import SVGKit;

@interface KKSVGViewController ()
@property (nonatomic, strong) KKSVGChooseSeatView *seatView;
@end

@implementation KKSVGViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    KKSVGChooseSeatView *seatView = [[KKSVGChooseSeatView alloc] init];
    self.seatView = seatView;
    seatView.backgroundColor = UIColor.orangeColor;
    [self.view addSubview:seatView];
    seatView.translatesAutoresizingMaskIntoConstraints = NO;

    [NSLayoutConstraint activateConstraints:@[
        [seatView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [seatView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [seatView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:50],
        [seatView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-50],
    ]];

    [self.view layoutIfNeeded];
    
    SVGKImage *image = [SVGKImage imageNamed:@"performbg" inBundle:[NSBundle kk_SVGResources]];
    [seatView updateBackgroudSeatImage:image];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //    [self.seatView updateScale:0.375];
}
@end
