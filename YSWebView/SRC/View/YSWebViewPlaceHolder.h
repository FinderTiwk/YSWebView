//
//  YSWebViewPlaceHolder.h
//  YSCoreSDK
//
//  Created by FinderTiwk on 2020/5/5.
//  Copyright © 2020 Zhejiang Yushi Network Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSWebViewPlaceHolder : UIView


- (void)startLoading;

- (void)showStatus:(NSString *)status duration:(NSTimeInterval)interval;


- (void)dismiss;


- (void)destory;

@end
