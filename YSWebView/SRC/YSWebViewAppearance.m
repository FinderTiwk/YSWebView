//
//  YSWebViewAppearance.m
//  YSWebView
//
//  Created by FinderTiwk on 2020/5/15.
//  Copyright © 2020 FinderTiwk. All rights reserved.
//

#import "YSWebViewAppearance.h"

@implementation YSWebViewAppearance


+ (instancetype)appearance{
    static YSWebViewAppearance *__appearance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __appearance = [YSWebViewAppearance new];
        [__appearance defaultResources];
    });
    
    return __appearance;;
}


- (void)defaultResources{
    
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
    NSString *resourcesBundleName = @"YSWebView.bundle";
    NSString *bundlePath = [[frameworkBundle bundlePath] stringByAppendingPathComponent:resourcesBundleName];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:bundlePath];
    
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Regular" size:18];
    
    _navigationBarBackgroundColor = [UIColor whiteColor];
    
    _navigationBarDarkBackButtonImage = [UIImage imageNamed:@"ys_web_navbar_back_black" inBundle:resourceBundle compatibleWithTraitCollection:nil];
    _navigationBarDarkTitleFont = font;
    _navigationBarDarkTitleColor = [UIColor blackColor];
    
    _navigationBarLightBackButtonImage = [UIImage imageNamed:@"ys_web_navbar_back_white" inBundle:resourceBundle compatibleWithTraitCollection:nil];
    _navigationBarLightTitleFont = font;
    _navigationBarLightTitleColor = [UIColor whiteColor];
    
    _progressBarColor = [UIColor systemBlueColor];;
    _toolBarBackgroundColor = [UIColor whiteColor];

    _toolBarBackButtonImage = [UIImage imageNamed:@"ys_web_toolbar_back" inBundle:resourceBundle compatibleWithTraitCollection:nil];
    _toolBarForwardButtonImage = [UIImage imageNamed:@"ys_web_toolbar_forward" inBundle:resourceBundle compatibleWithTraitCollection:nil];
    _toolBarRefreshButtonImage = [UIImage imageNamed:@"ys_web_toolbar_refresh" inBundle:resourceBundle compatibleWithTraitCollection:nil];
    _toolBarCloseButtonImage = [UIImage imageNamed:@"ys_web_toolbar_close" inBundle:resourceBundle compatibleWithTraitCollection:nil];
    
    
    _navigationBarBackgroundClearImage = [UIImage imageNamed:@"ys_web_navbar_background_clear" inBundle:resourceBundle compatibleWithTraitCollection:nil];
}


@end
