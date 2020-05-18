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
    
    NSBundle *resourceBundle = nil;
    if(!resourceBundle){
        NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
        NSString *resourcesBundleName = @"YSWebView.bundle";
        NSString *bundlePath = [[frameworkBundle bundlePath] stringByAppendingPathComponent:resourcesBundleName];
        resourceBundle = [NSBundle bundleWithPath:bundlePath];
    }
    
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Regular" size:18];
    CGFloat rgb = (51/255.0);
    
    _navigationBarBackgroundColor = [UIColor whiteColor];
    
    _navigationBarBackButtonImage = [UIImage imageNamed:@"ys_web_navbar_back_black" inBundle:resourceBundle compatibleWithTraitCollection:nil];
    _navigationBarTitleFont = font;
    _navigationBarTitleColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];
    
    _oppositeNavigationBarBackButtonImage = [UIImage imageNamed:@"ys_web_navbar_back_white" inBundle:resourceBundle compatibleWithTraitCollection:nil];
    _oppositeNavigationBarTitleFont = font;
    _oppositeNavigationBarTitleColor = [UIColor whiteColor];
    
    
    _toolBarBackgroundColor = [UIColor whiteColor];

    _toolBarBackButtonImage = [UIImage imageNamed:@"ys_web_toolbar_back" inBundle:resourceBundle compatibleWithTraitCollection:nil];
    _toolBarForwardButtonImage = [UIImage imageNamed:@"ys_web_toolbar_forward" inBundle:resourceBundle compatibleWithTraitCollection:nil];
    _toolBarRefreshButtonImage = [UIImage imageNamed:@"ys_web_toolbar_refresh" inBundle:resourceBundle compatibleWithTraitCollection:nil];
    _toolBarCloseButtonImage = [UIImage imageNamed:@"ys_web_toolbar_close" inBundle:resourceBundle compatibleWithTraitCollection:nil];
        
}


@end
