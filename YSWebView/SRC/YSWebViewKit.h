//
//  YSWebViewKit.h
//  YSCoreSDK
//
//  Created by FinderTiwk on 2020/5/4.
//  Copyright © 2020 Zhejiang Yushi Network Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@class YSWebViewController;

@interface YSWebViewKit : NSObject

+ (instancetype)webKitFor:(YSWebViewController *)webViewController;

@property (nonatomic,readonly) WKWebView *webView;

#pragma mark - 事件回调
/*! 页面开始加载 */
@property (nonatomic,copy) void(^startLoading)(YSWebViewController *webViewController);
/*! 页面加载完成成功 */
@property (nonatomic,copy) void(^loadSuccess)(YSWebViewController *webViewController);
/*! 页面加载失败 */
@property (nonatomic,copy) void(^loadFailure)(YSWebViewController *webViewController,NSError *error);

#pragma mark - 与JS通信

// Native 调用 H5注册的方法
- (void)notifyH5Register:(NSString *)functionName arguments:(NSArray *)args;
- (void)notifyH5Register:(NSString *)functionName arguments:(NSArray *)args callback:(void(^)(id retValue))callback;

@end

