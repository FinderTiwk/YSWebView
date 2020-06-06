//
//  YSWebViewNavigationBarRestore.h
//  YSWebView
//
//  Created by FinderTiwk on 2020/6/5.
//  Copyright © 2020 FinderTiwk. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface YSWebViewNavigationBarRestorer : NSObject

@property (nonatomic,assign) BOOL translucent;
@property (nonatomic,strong) UIImage *backgroundImage;
@property (nonatomic,strong) UIImage *ShadowImage;
@property (nonatomic,strong) UIColor *tintColor;
@property (nonatomic,strong) NSDictionary<NSAttributedStringKey, id> *titleTextAttributes;


+ (instancetype)restorerWith:(UINavigationBar *)navigationBar;

- (void)affectOn:(UINavigationBar *)navigationBar;

@end

