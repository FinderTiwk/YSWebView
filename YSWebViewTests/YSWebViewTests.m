//
//  YSWebViewTests.m
//  YSWebViewTests
//
//  Created by FinderTiwk on 2020/5/6.
//  Copyright © 2020 FinderTiwk. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "YSWebViewOption.h"
#import "YSWebViewAppearance.h"


@interface YSWebViewTests : XCTestCase
@end


@implementation YSWebViewTests


- (void)setUp{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FOUNDATION_EXPORT const unsigned char YSWebViewVersionString[];
        printf("    __  ________       __     __  _    ___  \r\n");
        printf("    \\ \\/ / ___/ |     / /__  / /_| |  / (_)__ _      __  \r\n");
        printf("     \\  /\\__ \\| | /| / / _ \\/ __ \\ | / / / _ \\ | /| / /  \r\n");
        printf("     / /___/ /| |/ |/ /  __/ /_/ / |/ / /  __/ |/ |/ /  \r\n");
        printf("    /_//____/ |__/|__/\\___/_.___/|___/_/\\___/|__/|__/  \r\n");
        
        printf("Version: %s",YSWebViewVersionString);
        printf("\rCopyright © 2020 FinderTiwk. All rights reserved.\r");
        printf("############################################################\r\r\n");
    });
}


- (void)testDefaultYSWebViewOption{
    
    YSWebViewOption option = defaultYSWebViewOption();
    
    XCTAssertTrue(option.clearBackground,@"设置是否透明背景选项错误");
    XCTAssertTrue(option.hiddenNavigationBar,@"设置是否隐藏导航栏选项错误");
    XCTAssertTrue(option.closeWhenLoadFailure,@"设置是否隐藏导航栏选项错误");
    
    XCTAssertFalse(option.showToolBar,@"设置工具栏选项错误");
    XCTAssertFalse(option.lockRotation,@"设置是否禁止旋转选项错误");
    XCTAssertFalse(option.landscape,@"设置是否横屏选项错误");
    XCTAssertFalse(option.throughNavigationBar,@"设置是否穿透导航栏选项错误");
    XCTAssertFalse(option.transparentNavigationBar,@"设置导航栏透明选项错误");
    XCTAssertFalse(option.autoDetectTitle,@"设置自动检测标题选项错误");
    XCTAssertFalse(option.showProgressBar,@"设置显示进度条选项错误");
    XCTAssertFalse(option.responseEntityKey,@"设置是否响应实体按键选项错误");
    XCTAssertFalse(option.transitionsStyle,@"设置转场方式选项错误");
    XCTAssertFalse(option.reduceAnimation,@"设置过度动画选项错误");
    XCTAssertFalse(option.hiddenStatusBar,@"设置状态栏显示选项错误");
    XCTAssertFalse(option.lightStatusBar,@"设置状态栏样式选项错误");
}


- (void)testParseYSWebViewOption{
    
    NSString *urlString = @"https://www.baidu.com";
    
    {
        YSWebViewOption option = parseYSWebViewOption(&urlString);
        XCTAssertTrue(option.clearBackground,@"设置是否透明背景选项错误");
        XCTAssertTrue(option.hiddenNavigationBar,@"设置是否隐藏导航栏选项错误");
        XCTAssertTrue(option.closeWhenLoadFailure,@"设置是否隐藏导航栏选项错误");
        
        XCTAssertFalse(option.showToolBar,@"设置工具栏选项错误");
        XCTAssertFalse(option.lockRotation,@"设置是否禁止旋转选项错误");
        XCTAssertFalse(option.landscape,@"设置是否横屏选项错误");
        XCTAssertFalse(option.throughNavigationBar,@"设置是否穿透导航栏选项错误");
        XCTAssertFalse(option.transparentNavigationBar,@"设置导航栏透明选项错误");
        XCTAssertFalse(option.autoDetectTitle,@"设置自动检测标题选项错误");
        XCTAssertFalse(option.showProgressBar,@"设置显示进度条选项错误");
        XCTAssertFalse(option.responseEntityKey,@"设置是否响应实体按键选项错误");
        XCTAssertFalse(option.transitionsStyle,@"设置转场方式选项错误");
        XCTAssertFalse(option.reduceAnimation,@"设置过度动画选项错误");
        XCTAssertFalse(option.hiddenStatusBar,@"设置状态栏显示选项错误");
        XCTAssertFalse(option.lightStatusBar,@"设置状态栏样式选项错误");
    }
    

    
    {
        NSString *queryString = @"key=value";
        NSString *target = [urlString stringByAppendingFormat:@"?%@",queryString];
        YSWebViewOption option = parseYSWebViewOption(&target);
        XCTAssertTrue(option.clearBackground,@"设置是否透明背景选项错误");
        XCTAssertTrue(option.hiddenNavigationBar,@"设置是否隐藏导航栏选项错误");
        XCTAssertTrue(option.closeWhenLoadFailure,@"设置是否隐藏导航栏选项错误");
        
        XCTAssertFalse(option.showToolBar,@"设置工具栏选项错误");
        XCTAssertFalse(option.lockRotation,@"设置是否禁止旋转选项错误");
        XCTAssertFalse(option.landscape,@"设置是否横屏选项错误");
        XCTAssertFalse(option.throughNavigationBar,@"设置是否穿透导航栏选项错误");
        XCTAssertFalse(option.transparentNavigationBar,@"设置导航栏透明选项错误");
        XCTAssertFalse(option.autoDetectTitle,@"设置自动检测标题选项错误");
        XCTAssertFalse(option.showProgressBar,@"设置显示进度条选项错误");
        XCTAssertFalse(option.responseEntityKey,@"设置是否响应实体按键选项错误");
        XCTAssertFalse(option.transitionsStyle,@"设置转场方式选项错误");
        XCTAssertFalse(option.reduceAnimation,@"设置过度动画选项错误");
        XCTAssertFalse(option.hiddenStatusBar,@"设置状态栏显示选项错误");
        XCTAssertFalse(option.lightStatusBar,@"设置状态栏样式选项错误");
    }
    
    
    {
        NSString *queryString = @"option=110001010";
        NSString *target = [urlString stringByAppendingFormat:@"?%@",queryString];
        YSWebViewOption option = parseYSWebViewOption(&target);
        
        XCTAssertTrue([urlString isEqualToString:target],@"从原始请求url中去除option异常");
        XCTAssertFalse(option.showToolBar,@"设置工具栏选项错误");
        XCTAssertTrue(option.clearBackground,@"设置是否透明背景选项错误");
        XCTAssertFalse(option.lockRotation,@"设置是否禁止旋转选项错误");
        XCTAssertTrue(option.landscape,@"设置是否横屏选项错误");
        XCTAssertFalse(option.hiddenNavigationBar,@"设置是否隐藏导航栏选项错误");
        XCTAssertFalse(option.throughNavigationBar,@"设置是否穿透导航栏选项错误");
        XCTAssertFalse(option.transparentNavigationBar,@"设置导航栏透明选项错误");
        XCTAssertTrue(option.autoDetectTitle,@"设置自动检测标题选项错误");
        XCTAssertTrue(option.showProgressBar,@"设置显示进度条选项错误");
        XCTAssertFalse(option.responseEntityKey,@"设置是否响应实体按键选项错误");
        XCTAssertFalse(option.closeWhenLoadFailure,@"设置加载失败自动关闭选项错误");
        XCTAssertFalse(option.transitionsStyle,@"设置转场方式选项错误");
        XCTAssertFalse(option.reduceAnimation,@"设置过度动画选项错误");
        XCTAssertFalse(option.hiddenStatusBar,@"设置状态栏显示选项错误");
        XCTAssertFalse(option.lightStatusBar,@"设置状态栏样式选项错误");
    }
    
    
    {
        NSString *queryString = @"option=111010001011&key=value";
        NSString *target = [urlString stringByAppendingFormat:@"?%@",queryString];
        YSWebViewOption option = parseYSWebViewOption(&target);
        
        XCTAssertTrue([target isEqualToString:[target stringByReplacingOccurrencesOfString:@"option=111010001010" withString:@""]],@"从原始请求url中去除option异常");
        
        XCTAssertTrue(option.showToolBar,@"设置工具栏选项错误");
        XCTAssertTrue(option.clearBackground,@"设置是否透明背景选项错误");
        XCTAssertFalse(option.lockRotation,@"设置是否禁止旋转选项错误");
        XCTAssertTrue(option.landscape,@"设置是否横屏选项错误");
        XCTAssertFalse(option.hiddenNavigationBar,@"设置是否隐藏导航栏选项错误");
        XCTAssertFalse(option.throughNavigationBar,@"设置是否穿透导航栏选项错误");
        XCTAssertFalse(option.transparentNavigationBar,@"设置导航栏透明选项错误");
        XCTAssertTrue(option.autoDetectTitle,@"设置自动检测标题选项错误");
        XCTAssertFalse(option.showProgressBar,@"设置显示进度条选项错误");
        XCTAssertTrue(option.responseEntityKey,@"设置是否响应实体按键选项错误");
        XCTAssertTrue(option.closeWhenLoadFailure,@"设置加载失败自动关闭选项错误");
        XCTAssertTrue(option.transitionsStyle,@"设置转场方式选项错误");
        XCTAssertFalse(option.reduceAnimation,@"设置过度动画选项错误");
        XCTAssertFalse(option.hiddenStatusBar,@"设置状态栏显示选项错误");
        XCTAssertFalse(option.lightStatusBar,@"设置状态栏样式选项错误");
    }
}


- (void)testYSWebViewOptionDesc{
    
    {
        YSWebViewOption option = {};
        XCTAssertTrue([descForYSWebViewOption(option) isEqualToString:@""],@"web容器样式码不对");
    }
    
    
    {
        YSWebViewOption option = defaultYSWebViewOption();
        XCTAssertTrue([descForYSWebViewOption(option) isEqualToString:@"10000010010"],@"web容器样式码不对");
    }
    
    
    {
        YSWebViewOption option = {};
        option.clearBackground = 1;
        option.landscape = 1;
        option.autoDetectTitle = 1;
        option.showProgressBar = 1;
        XCTAssertTrue([descForYSWebViewOption(option) isEqualToString:@"110001010"],@"web容器样式码不对");
    }
    
}



- (void)testLoadResources{
    
    YSWebViewAppearance *appearance = [YSWebViewAppearance appearance];
    
    XCTAssertNotNil(appearance.navigationBarBackButtonImage,@"导航栏黑色返回按钮没有正确加载");
    XCTAssertNotNil(appearance.oppositeNavigationBarBackButtonImage,@"导航栏白色返回按钮没有正确加载");
    
    XCTAssertNotNil(appearance.toolBarCloseButtonImage,@"工具条返回按钮没有正确加载");
    XCTAssertNotNil(appearance.toolBarForwardButtonImage,@"工具条前进按钮没有正确加载");
    XCTAssertNotNil(appearance.toolBarRefreshButtonImage,@"工具条刷新按钮没有正确加载");
    XCTAssertNotNil(appearance.toolBarCloseButtonImage,@"工具条关闭按钮没有正确加载");
    
}
    
@end
