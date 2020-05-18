//
//  YSWebViewPlaceHolder.m
//  YSCoreSDK
//
//  Created by FinderTiwk on 2020/5/5.
//  Copyright © 2020 Zhejiang Yushi Network Inc. All rights reserved.
//

#import "YSWebViewPlaceHolder.h"

@interface YSWebViewPlaceHolder ()

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UILabel *tipLabel;

@end

@implementation YSWebViewPlaceHolder


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}


- (void)initSubViews{
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    self.layer.cornerRadius = 7;
    
    _indicatorView = [[UIActivityIndicatorView alloc] init];
    _indicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [self addSubview:_indicatorView];
    
    
    _tipLabel = [[UILabel alloc] init];
    _tipLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _tipLabel.textColor = [UIColor whiteColor];
    _tipLabel.numberOfLines = 2;
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    _tipLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.0];
    [self addSubview:_tipLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [_indicatorView.widthAnchor constraintEqualToConstant:35],
        [_indicatorView.heightAnchor constraintEqualToConstant:35],
        [_indicatorView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [_indicatorView.topAnchor constraintEqualToAnchor:self.topAnchor constant:20],
        
        [_tipLabel.topAnchor constraintEqualToAnchor:_indicatorView.bottomAnchor constant:11],
        [_tipLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10],
        [_tipLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10],
        [_tipLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-20],
        [_tipLabel.widthAnchor constraintLessThanOrEqualToConstant:150],
        [_tipLabel.widthAnchor constraintGreaterThanOrEqualToConstant:100],
    ]];
}


- (void)startLoading{
    self.hidden = NO;
    _tipLabel.text = @"加载中...";
    [_indicatorView startAnimating];
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    self.hidden = YES;
}

- (void)showStatus:(NSString *)status duration:(NSTimeInterval)interval{
    
    self.hidden = NO;
    self.tipLabel.text = status;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.hidden = YES;
    });
}


- (void)dismiss{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.hidden = YES;
    });
}

- (void)destory{
    [self removeFromSuperview];
}


@end
