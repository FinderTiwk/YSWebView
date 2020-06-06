//
//  YSWebViewNavigationBarRestore.m
//  YSWebView
//
//  Created by FinderTiwk on 2020/6/5.
//  Copyright © 2020 FinderTiwk. All rights reserved.
//

#import "YSWebViewNavigationBarRestorer.h"

@implementation YSWebViewNavigationBarRestorer

+ (instancetype)restorerWith:(UINavigationBar *)navigationBar{
    YSWebViewNavigationBarRestorer *restorer = [YSWebViewNavigationBarRestorer new];
    restorer.translucent = navigationBar.translucent;
    restorer.backgroundImage = [navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
    restorer.ShadowImage = navigationBar.shadowImage;
    restorer.tintColor = navigationBar.tintColor;
    restorer.titleTextAttributes = navigationBar.titleTextAttributes;
    return restorer;
}

- (void)affectOn:(UINavigationBar *)navigationBar{
    navigationBar.translucent = self.translucent;
    [navigationBar setBackgroundImage:self.backgroundImage forBarMetrics:UIBarMetricsDefault];
    [navigationBar setShadowImage:self.ShadowImage];
    navigationBar.tintColor = self.tintColor;
    navigationBar.titleTextAttributes = self.titleTextAttributes;
}

@end
