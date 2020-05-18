//
//  YSWebViewToolBar.m
//  YSCoreSDK
//
//  Created by FinderTiwk on 2020/5/4.
//  Copyright © 2020 Zhejiang Yushi Network Inc. All rights reserved.
//

#import "YSWebViewToolBar.h"
#import "YSWebViewAppearance.h"

@implementation YSWebViewToolBar

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}


- (void)initSubViews{
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.distribution = UIStackViewDistributionFillEqually;
    stackView.alignment = UIStackViewAlignmentFill;
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:stackView];
    
    
    YSWebViewAppearance *appearance = [YSWebViewAppearance appearance];
    self.backgroundColor = appearance.toolBarBackgroundColor;
    
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backButton setImage:appearance.toolBarBackButtonImage forState:UIControlStateNormal];
    [stackView addArrangedSubview:_backButton];

    _forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_forwardButton setImage:appearance.toolBarForwardButtonImage forState:UIControlStateNormal];
    [stackView addArrangedSubview:_forwardButton];

    _refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_refreshButton setImage:appearance.toolBarRefreshButtonImage forState:UIControlStateNormal];
    [stackView addArrangedSubview:_refreshButton];

    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeButton setImage:appearance.toolBarCloseButtonImage forState:UIControlStateNormal];
    [stackView addArrangedSubview:_closeButton];
    
    
    

    NSLayoutYAxisAnchor *toolBarbottomAnchor;
    
    if (@available(iOS 11.0, *)) {
        toolBarbottomAnchor = self.safeAreaLayoutGuide.bottomAnchor;
    } else {
        toolBarbottomAnchor = self.bottomAnchor;
    }
    
    [NSLayoutConstraint activateConstraints:@[
        [stackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [stackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [stackView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [stackView.bottomAnchor constraintEqualToAnchor:toolBarbottomAnchor],
        [stackView.heightAnchor constraintEqualToConstant:49],
    ]];
}



@end
