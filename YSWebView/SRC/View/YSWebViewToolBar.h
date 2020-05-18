//
//  YSWebViewToolBar.h
//  YSCoreSDK
//
//  Created by FinderTiwk on 2020/5/4.
//  Copyright © 2020 Zhejiang Yushi Network Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSWebViewToolBar : UIView

// 返回按钮
@property (nonatomic,readonly) UIButton *backButton;
// 前进按钮
@property (nonatomic,readonly) UIButton *forwardButton;
// 刷新按钮
@property (nonatomic,readonly) UIButton *refreshButton;
// 关闭按钮
@property (nonatomic,readonly) UIButton *closeButton;

@end

