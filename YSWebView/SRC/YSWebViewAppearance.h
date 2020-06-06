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

@property (nonatomic,strong) UIImage *navigationBarLightBackButtonImage;
@property (nonatomic,strong) UIFont *navigationBarLightTitleFont;
@property (nonatomic,strong) UIColor *navigationBarLightTitleColor;

@property (nonatomic,strong) UIImage *navigationBarDarkBackButtonImage;
@property (nonatomic,strong) UIFont *navigationBarDarkTitleFont;
@property (nonatomic,strong) UIColor *navigationBarDarkTitleColor;

@property (nonatomic,strong) UIColor *progressBarColor;
@property (nonatomic,strong) UIColor *toolBarBackgroundColor;

@property (nonatomic,strong) UIImage *toolBarBackButtonImage;
@property (nonatomic,strong) UIImage *toolBarForwardButtonImage;
@property (nonatomic,strong) UIImage *toolBarRefreshButtonImage;
@property (nonatomic,strong) UIImage *toolBarCloseButtonImage;

@property (nonatomic,readonly) UIImage *navigationBarBackgroundClearImage;

@end

