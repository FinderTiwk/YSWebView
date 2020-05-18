//
//  YSWebViewAppearance.h
//  YSWebView
//
//  Created by FinderTiwk on 2020/5/15.
//  Copyright © 2020 FinderTiwk. All rights reserved.
//

@import UIKit;

@interface YSWebViewAppearance : NSObject

+ (instancetype)appearance;

@property (nonatomic,strong) UIColor *navigationBarBackgroundColor;

@property (nonatomic,strong) UIImage *navigationBarBackButtonImage;
@property (nonatomic,strong) UIFont *navigationBarTitleFont;
@property (nonatomic,strong) UIColor *navigationBarTitleColor;

@property (nonatomic,strong) UIImage *oppositeNavigationBarBackButtonImage;
@property (nonatomic,strong) UIFont *oppositeNavigationBarTitleFont;
@property (nonatomic,strong) UIColor *oppositeNavigationBarTitleColor;


@property (nonatomic,strong) UIColor *toolBarBackgroundColor;

@property (nonatomic,strong) UIImage *toolBarBackButtonImage;
@property (nonatomic,strong) UIImage *toolBarForwardButtonImage;
@property (nonatomic,strong) UIImage *toolBarRefreshButtonImage;
@property (nonatomic,strong) UIImage *toolBarCloseButtonImage;

@end

