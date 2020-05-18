//
//  YSWebViewController.h
//  YSCoreSDK
//
//  Created by FinderTiwk on 2020/5/3.
//  Copyright © 2020 Zhejiang Yushi Network Inc. All rights reserved.
//

@import UIKit;

#import "YSWebViewOption.h"

// Web登录成功通知
FOUNDATION_EXPORT NSNotificationName const YSWebLoginSuccessNotification;
// Web退出登录, 切换账号通知
FOUNDATION_EXPORT NSNotificationName const YSWebLogoutNotification;
// Web支付成功通知
FOUNDATION_EXPORT NSNotificationName const YSWebTransactionSuccessNotification;
// Web要使用IAP支付的通知
FOUNDATION_EXPORT NSNotificationName const YSWebWillDoIAPNotification;


@interface YSWebViewController : UIViewController

// 加载url或者本地网页(二选一)
@property (nonatomic,copy) NSString *urlString;
@property (nonatomic,copy) NSString *htmlPath;

@property (nonatomic,weak) UIView *anchorWidget;
@property (nonatomic,strong) UIWindow *owner;
@property (nonatomic,assign) YSWebViewOption option;

@property (nonatomic,copy) NSString *versionString;
@property (nonatomic,copy) NSString *zfbScheme;
@property (nonatomic,copy) NSString *vxScheme;
@property (nonatomic,strong) NSDictionary *transactionParams;

@property (nonatomic,strong) NSDictionary *cookies;
@property (nonatomic,copy) NSDictionary *(^headerProvider)(void);
@property (nonatomic,copy) NSString *(^signProvider)(NSDictionary *params);

// 手动关闭容器
- (void)close:(NSError *)error;
// 页面关闭回调
@property (nonatomic,copy) void(^closeCallback)(NSError *error);

@end

