//
//  YSWebViewFakeNavigationBar.m
//  YSCoreSDK
//
//  Created by FinderTiwk on 2020/5/4.
//  Copyright © 2020 Zhejiang Yushi Network Inc. All rights reserved.
//

#import "YSWebViewFakeNavigationBar.h"
#import "YSWebViewAppearance.h"

@implementation YSWebViewFakeNavigationBar

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews{

    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    YSWebViewAppearance *appearance = [YSWebViewAppearance appearance];
    self.backgroundColor = appearance.navigationBarBackgroundColor;
    
    UILayoutGuide *navigationBarLayoutGuide = [[UILayoutGuide alloc] init];
    [self addLayoutGuide:navigationBarLayoutGuide];

    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    
    _titleLabel.font = appearance.navigationBarTitleFont;
    _titleLabel.textColor = appearance.navigationBarTitleColor;
    [self addSubview:_titleLabel];

    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_backButton setImage:appearance.navigationBarBackButtonImage forState:UIControlStateNormal];
    [self addSubview:_backButton];
    
    NSLayoutYAxisAnchor *navigationBarTopAnchor;
    if (@available(iOS 11.0, *)) {
        navigationBarTopAnchor = self.safeAreaLayoutGuide.topAnchor;
    } else {
        navigationBarTopAnchor = self.topAnchor;
    }
    
    [NSLayoutConstraint activateConstraints:@[
        
        [navigationBarLayoutGuide.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [navigationBarLayoutGuide.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [navigationBarLayoutGuide.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [navigationBarLayoutGuide.topAnchor constraintEqualToAnchor:navigationBarTopAnchor],
        [navigationBarLayoutGuide.heightAnchor constraintEqualToConstant:44],
        
        [_titleLabel.leadingAnchor constraintEqualToAnchor:navigationBarLayoutGuide.leadingAnchor constant:50],
        [_titleLabel.trailingAnchor constraintEqualToAnchor:navigationBarLayoutGuide.trailingAnchor constant:-50],
        [_titleLabel.centerYAnchor constraintEqualToAnchor:navigationBarLayoutGuide.centerYAnchor],
        
        [_backButton.widthAnchor constraintEqualToConstant:40],
        [_backButton.heightAnchor constraintEqualToConstant:40],
        [_backButton.centerYAnchor constraintEqualToAnchor:navigationBarLayoutGuide.centerYAnchor],
        [_backButton.leadingAnchor constraintEqualToAnchor:navigationBarLayoutGuide.leadingAnchor constant:5],
    ]];
}



- (void)setStyle:(YSWebViewFakeNavigationBarStyle)style{
    YSWebViewAppearance *appearance = [YSWebViewAppearance appearance];
    if (style == YSWebViewFakeNavigationBarStyleDark) {
        
        _titleLabel.font = appearance.navigationBarTitleFont;
        _titleLabel.textColor = appearance.navigationBarTitleColor;
        [_backButton setImage:appearance.navigationBarBackButtonImage forState:UIControlStateNormal];
    }
    else{
        _titleLabel.font = appearance.oppositeNavigationBarTitleFont;
        _titleLabel.textColor = appearance.oppositeNavigationBarTitleColor;
        [_backButton setImage:appearance.oppositeNavigationBarBackButtonImage forState:UIControlStateNormal];

    }
}



@end
