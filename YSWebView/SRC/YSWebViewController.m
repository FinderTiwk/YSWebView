//
//  YSWebViewController.m
//  YSCoreSDK
//
//  Created by FinderTiwk on 2020/5/3.
//  Copyright © 2020 Zhejiang Yushi Network Inc. All rights reserved.
//

#import "YSWebViewController.h"
#import "YSWebViewKit.h"

#import "YSWebViewToolBar.h"
#import "YSWebViewPlaceHolder.h"
#import "YSWebViewFakeNavigationBar.h"

// Web登录成功通知
NSNotificationName const YSWebLoginSuccessNotification = @"YSWebLoginSuccessNotification";
// Web退出登录, 切换账号通知
NSNotificationName const YSWebLogoutNotification = @"YSWebLogoutNotification";
// Web支付成功通知
NSNotificationName const YSWebTransactionSuccessNotification = @"YSWebTransactionSuccessNotification";
// Web要使用IAP支付的通知
NSNotificationName const YSWebWillDoIAPNotification = @"YSWebWillDoIAPNotification";


@interface YSWebViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic,assign) BOOL realNavigationBarHidden;

@property (nonatomic,assign) BOOL addTitleKVO;
@property (nonatomic,assign) BOOL addProgressKVO;
@property (nonatomic,assign) BOOL addToolbarKVO;

@property (nonatomic,strong) YSWebViewKit *webKit;
@property (nonatomic,strong) UIProgressView *progressView;

@property (nonatomic,weak) WKWebView *webView;
@property (nonatomic,weak) YSWebViewToolBar *toolbar;
@property (nonatomic,weak) YSWebViewPlaceHolder *placeHolderView;
@property (nonatomic,weak) YSWebViewFakeNavigationBar *fakeNavigationBar;

@end

@implementation YSWebViewController

#pragma mark - 状态栏
- (UIStatusBarStyle)preferredStatusBarStyle{
    if (self.option.lightStatusBar) {
        return UIStatusBarStyleLightContent;
    }
    if (@available(iOS 13.0, *)) {
        return UIStatusBarStyleDarkContent;
    } else {
        return UIStatusBarStyleDefault;
    }
}

- (BOOL)prefersStatusBarHidden{
    return self.option.hiddenStatusBar;
}

- (void)viewDidLoad{
    [super viewDidLoad];

    NSAssert(_urlString || _htmlPath, @"YSWebViewController urlString is nil");
    
    _realNavigationBarHidden = self.navigationController.navigationBar.hidden;
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    
    if (!self.option.hiddenNavigationBar || self.option.showToolBar) {
        self.view.backgroundColor = [UIColor whiteColor];
    }else{
        self.view.backgroundColor = self.option.clearBackground ? [UIColor clearColor] : [UIColor whiteColor];
    }
    
    [self registNotifications];
    self.webKit = [YSWebViewKit webKitFor:self];
    self.webView = self.webKit.webView;
    self.webView.hidden = YES;
    
    self.webKit.startLoading = ^(YSWebViewController *webViewController) {
        [webViewController.placeHolderView startLoading];
    };
    
    self.webKit.loadFailure = ^(YSWebViewController *webViewController, NSError *error) {
        
        if (webViewController.option.closeWhenLoadFailure) {
            [webViewController close:error];
        }else{
            webViewController.fakeNavigationBar.hidden = NO;
            webViewController.toolbar.hidden = NO;
            [webViewController.placeHolderView showStatus:error.localizedDescription duration:2];
        }
    };
    
    self.webKit.loadSuccess = ^(YSWebViewController *webViewController) {
        webViewController.webView.hidden = NO;
        webViewController.fakeNavigationBar.hidden = NO;
        webViewController.toolbar.hidden = NO;
        [webViewController.placeHolderView removeFromSuperview];
        webViewController.placeHolderView = nil;

        [webViewController changeOrientation];
    };
    
    [self setupUI];
    
    // loadRequest
    if (_urlString) {
        NSURL *url = [NSURL URLWithString:_urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.timeoutInterval = 30;
        [self.webView loadRequest:request];
    }
    else{
        NSString * htmlContent = [NSString stringWithContentsOfFile:_htmlPath
                                                           encoding:NSUTF8StringEncoding
                                                              error:nil];
        NSString *basePath = [_htmlPath stringByDeletingLastPathComponent];
        NSURL *baseURL = [NSURL fileURLWithPath:basePath];
        [_webView loadHTMLString:htmlContent
                         baseURL:baseURL];
    }
}


- (void)setupUI{
    NSLayoutYAxisAnchor *vcTopAnchor;
    NSLayoutXAxisAnchor *vcLeftAnchor;
    NSLayoutXAxisAnchor *vcRightAnchor;
    
    if (@available(iOS 11.0, *)) {
        vcTopAnchor = self.view.safeAreaLayoutGuide.topAnchor;
        
        // Fix landscape safe area display
        vcLeftAnchor = self.view.safeAreaLayoutGuide.leadingAnchor;
        {
            UIView *view = [[UIView alloc] init];
            view.translatesAutoresizingMaskIntoConstraints = NO;
            view.backgroundColor = [UIColor blackColor];
            [self.view addSubview:view];
            
            [NSLayoutConstraint activateConstraints:@[
                [view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
                [view.trailingAnchor constraintEqualToAnchor:vcLeftAnchor],
                [view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
                [view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
            ]];
        }
        
        vcRightAnchor = self.view.safeAreaLayoutGuide.trailingAnchor;
        {
            UIView *view = [[UIView alloc] init];
            view.translatesAutoresizingMaskIntoConstraints = NO;
            view.backgroundColor = [UIColor blackColor];
            [self.view addSubview:view];
            
            [NSLayoutConstraint activateConstraints:@[
                [view.leadingAnchor constraintEqualToAnchor:vcRightAnchor],
                [view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
                [view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
                [view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
            ]];
        }
    } else {
        vcTopAnchor = self.topLayoutGuide.bottomAnchor;
        vcLeftAnchor = self.view.leftAnchor;
        vcRightAnchor = self.view.rightAnchor;
    }
    
    NSLayoutYAxisAnchor *webViewTopAnchor = self.view.topAnchor;
    if (!self.option.hiddenNavigationBar) {
        // add navigationBar
        YSWebViewFakeNavigationBar *navigationBar = [[YSWebViewFakeNavigationBar alloc] init];
        navigationBar.hidden = YES;
        navigationBar.backButton.hidden = (self.navigationController.viewControllers.count == 1);
        [navigationBar.backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
        if (self.option.throughNavigationBar) {
            navigationBar.backgroundColor = [UIColor clearColor];
        }
        
        [self.view addSubview:navigationBar];
        
        [NSLayoutConstraint activateConstraints:@[
            [navigationBar.leadingAnchor constraintEqualToAnchor:vcLeftAnchor],
            [navigationBar.trailingAnchor constraintEqualToAnchor:vcRightAnchor],
            [navigationBar.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        ]];
        
        if (self.title) {
            navigationBar.titleLabel.text = self.title;
        }else{
            if (self.option.autoDetectTitle) {
                self.addTitleKVO = YES;
                [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
            }
        }
        
        navigationBar.style = self.option.transparentNavigationBar ? YSWebViewFakeNavigationBarStyleWhite : YSWebViewFakeNavigationBarStyleDark;
        
        self.fakeNavigationBar = navigationBar;
        if (!self.option.throughNavigationBar) {
            webViewTopAnchor = navigationBar.bottomAnchor;
        }
    }
    
    
    if (self.option.showProgressBar) {
        // add navigationBar
        self.addProgressKVO = YES;
        _progressView = [[UIProgressView alloc] init];
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
        _progressView.progress = 0;
        _progressView.trackTintColor = [UIColor clearColor];
        [self.view addSubview:_progressView];
        _progressView.progressTintColor = [UIColor colorWithRed:253/255.0 green:183/255.0 blue:28/255.0 alpha:1/1.0];
        [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
        
        [NSLayoutConstraint activateConstraints:@[
            [_progressView.leadingAnchor constraintEqualToAnchor:vcLeftAnchor],
            [_progressView.trailingAnchor constraintEqualToAnchor:vcRightAnchor],
            [_progressView.heightAnchor constraintEqualToConstant:2],
            [_progressView.bottomAnchor constraintEqualToAnchor:webViewTopAnchor],
        ]];
    }
    
    // add placeHolder
    {
        YSWebViewPlaceHolder *placeHolderView = [[YSWebViewPlaceHolder alloc] init];
        placeHolderView.hidden = YES;
        [self.view addSubview:placeHolderView];

        [NSLayoutConstraint activateConstraints:@[
            [placeHolderView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            [placeHolderView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        ]];
        self.placeHolderView = placeHolderView;
    }
    
    
    NSLayoutYAxisAnchor *webViewBottomAnchor = self.view.bottomAnchor;
    if (self.option.showToolBar) {
        // add toolBar
        
        self.addToolbarKVO = YES;
        [self.webView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];
        
        YSWebViewToolBar *toolbar = [[YSWebViewToolBar alloc] init];
        toolbar.hidden = YES;
        // KVO
        toolbar.backButton.enabled = [self.webView canGoBack];
        [self.webView addObserver:self forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionNew context:nil];
        [toolbar.backButton addTarget:self action:@selector(fallbackAction:) forControlEvents:UIControlEventTouchUpInside];
        
        toolbar.forwardButton.enabled = [self.webView canGoForward];
        [self.webView addObserver:self forKeyPath:@"canGoForward" options:NSKeyValueObservingOptionNew context:nil];
        [toolbar.forwardButton addTarget:self action:@selector(forwardAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.webView addObserver:self forKeyPath:@"canGoForward" options:NSKeyValueObservingOptionNew context:nil];
        [toolbar.refreshButton addTarget:self action:@selector(refreshAction:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [toolbar.closeButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:toolbar];
        self.toolbar = toolbar;
        
        [NSLayoutConstraint activateConstraints:@[
            [toolbar.leadingAnchor constraintEqualToAnchor:vcLeftAnchor],
            [toolbar.trailingAnchor constraintEqualToAnchor:vcRightAnchor],
            [toolbar.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        ]];
        webViewBottomAnchor = toolbar.topAnchor;
    }
    
    
    // add webView
    [self.view insertSubview:self.webView atIndex:0];
    [NSLayoutConstraint activateConstraints:@[
        [self.webView.leadingAnchor constraintEqualToAnchor:vcLeftAnchor],
        [self.webView.trailingAnchor constraintEqualToAnchor:vcRightAnchor],
        [self.webView.topAnchor constraintEqualToAnchor:webViewTopAnchor],
        [self.webView.bottomAnchor constraintEqualToAnchor:webViewBottomAnchor],
    ]];
}


- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self changeOrientation];
    } completion:NULL];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}



//- (BOOL)shouldAutorotate{
////    return !self.option.lockRotation;
//    return YES;
//}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
//    if (self.option.landscape) {
//        return UIInterfaceOrientationMaskLandscape;
//    }
//    return UIInterfaceOrientationMaskAll;
//}
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
//    if (self.option.landscape) {
//        return UIInterfaceOrientationLandscapeLeft|UIInterfaceOrientationLandscapeRight;
//    }
//    return UIInterfaceOrientationPortrait|UIInterfaceOrientationLandscapeLeft|UIInterfaceOrientationLandscapeRight;
//}
//



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Action

- (void)backAction:(UIButton *)sender{
    [self close:nil];
}

- (void)fallbackAction:(UIButton *)sender{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
}

- (void)forwardAction:(UIButton *)sender{
    if ([self.webView canGoForward]) {
        [self.webView goForward];
    }
}

- (void)refreshAction:(UIButton *)sender{
    [self.webView reload];
}

- (void)closeAction:(UIButton *)sender{
    [self close:nil];
}


- (void)dealloc{

    if (self.addTitleKVO) {
        [self.webView removeObserver:self forKeyPath:@"title"];
    }
    if (self.addProgressKVO) {
        [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    }
    
    if (self.addToolbarKVO) {
        [self.webView removeObserver:self forKeyPath:@"loading"];
        [self.webView removeObserver:self forKeyPath:@"canGoBack"];
        [self.webView removeObserver:self forKeyPath:@"canGoForward"];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - API

- (void)close:(NSError *)error{

    // 没有导航栏的情况
    if (!self.navigationController) {
        [self dismissViewControllerAnimated:!self.option.reduceAnimation completion:^{
            !self.closeCallback?:self.closeCallback(error);
        }];
    }
    
    
    if (self.navigationController.viewControllers.count == 1) {
        if (self.owner) {
            !_closeCallback?:_closeCallback(error);
            self.owner.hidden = YES;
            self.owner = nil;
        }else{
            [self dismissViewControllerAnimated:!self.option.reduceAnimation completion:^{
                !self.closeCallback?:self.closeCallback(error);
            }];
        }
    }
    
    else{
        [self.navigationController setNavigationBarHidden:self.realNavigationBarHidden animated:YES];
        !self.closeCallback?:self.closeCallback(error);
        [self.navigationController popViewControllerAnimated:YES];
        
//        [CATransaction begin];
//        [CATransaction setCompletionBlock:^{
//            !self.closeCallback?:self.closeCallback(error);
//        }];
//        [CATransaction commit];
    }
    
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - 通知

- (void)registNotifications{
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(notifyShowKeyBoard:)
                               name:UIKeyboardWillShowNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(notifyHideKeyBoard:)
                               name:UIKeyboardWillHideNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(notifiyPasteboard:)
                               name:UIApplicationDidBecomeActiveNotification
                             object:nil];
}


- (void)changeOrientation{
    NSUInteger index = 0;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown) {
        index = 1;
    }
    [self.webKit notifyH5Register:@"app_rotation" arguments:@[@(index)]];
}


- (void)notifyShowKeyBoard:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGFloat keyboardHeight = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    [self.webKit notifyH5Register:@"app_showKeyboard" arguments:@[@(YES),@(keyboardHeight)]];
}

- (void)notifyHideKeyBoard:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGFloat keyboardHeight = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    [self.webKit notifyH5Register:@"app_showKeyboard" arguments:@[@(NO),@(keyboardHeight)]];
}

- (void)notifiyPasteboard:(NSNotification *)notification {
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    if (pasteBoard.string) {
        [self.webKit notifyH5Register:@"app_pasteboadContent" arguments:@[pasteBoard.string]];
    }
    
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - KVO 监听加载进度
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if (object != self.webView) {
        return;
    }
    
    // 网页title
    if ([keyPath isEqualToString:@"title"]){
        self.fakeNavigationBar.titleLabel.text = self.webView.title;
    }
    
    // 进度
    else if ([keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat progress = self.webView.estimatedProgress;
        [self.progressView setAlpha:1.0f];
        [self.progressView setProgress:progress animated:YES];
        if(progress >= 1.0f) {
            [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    }
    
    //是否正在加载
    else if ([keyPath isEqualToString:@"loading"]){
        self.toolbar.refreshButton.enabled = !self.webView.isLoading;
    }
    
    //是否可以返回
    else if ([keyPath isEqualToString:@"canGoBack"]){
        self.toolbar.backButton.enabled = self.webView.canGoBack;
    }
    
    //是否可以前进
    else if ([keyPath isEqualToString:@"canGoForward"]){
        self.toolbar.forwardButton.enabled = self.webView.canGoForward;
    }
    else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
