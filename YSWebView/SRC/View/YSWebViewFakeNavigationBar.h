//
//  YSWebViewFakeNavigationBar.h
//  YSCoreSDK
//
//  Created by FinderTiwk on 2020/5/4.
//  Copyright © 2020 Zhejiang Yushi Network Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger,YSWebViewFakeNavigationBarStyle) {
    // 黑色返回按钮和标题
    YSWebViewFakeNavigationBarStyleDark,
    // 白色返回按钮和标题
    YSWebViewFakeNavigationBarStyleWhite,
};


@interface YSWebViewFakeNavigationBar : UIView

// default : YSWebViewFakeNavigationBarStyleDark
@property (nonatomic,assign) YSWebViewFakeNavigationBarStyle style;

// 标题
@property (nonatomic,readonly) UILabel *titleLabel;
// 返回按钮
@property (nonatomic,readonly) UIButton *backButton;

@end
