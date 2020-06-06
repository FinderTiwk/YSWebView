//
//  YSWebViewOption.h
//  YSCoreSDK
//
//  Created by FinderTiwk on 2020/5/3.
//  Copyright © 2020 Zhejiang Yushi Network Inc. All rights reserved.
//

#ifndef YSWebViewOption_h
#define YSWebViewOption_h

 
typedef struct{
    // 是否显示工具条
    unsigned short showToolBar:1;              /*!<  是否显示此框架自带的工具条 */
    
    unsigned short clearBackground:1;          /*!<  是否透明背景 */
    unsigned short lockRotation:1;             /*!<  是否追随手持方向 */
    unsigned short landscape:1;                /*!<  是否横屏显示, 如果设置了 `lockRotation` 为YES, 此选项无效 */
    
    unsigned short hiddenNavigationBar:1;      /*!<  是否隐藏导航栏, defalut 不隐藏 */
    unsigned short throughNavigationBar:1;     /*!<   是否穿透导航栏,  default NO */
    unsigned short lightNavigationBar:1;       /*!<   导航栏返回按钮是否白色 */
    unsigned short autoDetectTitle:1;          /*!<   是否自动检测Web Title, 如果控制器不设置title 设置了此选项后会自动根据Web的标题显示*/
    
    unsigned short showProgressBar:1;          /*!<  是否显示进度条 */
    
    unsigned short responseEntityKey:1;        /*!<  是否响应实体按键 (Android使用) */
    unsigned short closeWhenLoadFailure:1;     /*!<  加载失败时,是否自动关闭返回  */

    unsigned short transitionsStyle:1;         /*!<  加载失败时,是否自动关闭返回  */
    unsigned short reduceAnimation:1;          /*!<  加载失败时,是否自动关闭返回  */
    
    unsigned short hiddenStatusBar:1;          /*!< 是否陒状态栏  */
    unsigned short lightStatusBar:1;           /*!< 白色/黑色状态栏, default 白色 */
    
} YSWebViewOption;


static inline YSWebViewOption defaultYSWebViewOption(){
    //YSWebViewOption option; 直接定义结构体对象不初始化会有脏数据,使用 = {}给结构体每个成员赋默认值
    YSWebViewOption option = {};
    option.clearBackground = 1;
    option.hiddenNavigationBar = 1;
    option.closeWhenLoadFailure = 1;
    return option;
}


static inline short subBitInString(NSString *aString, int location){
    if (location < 0) return 0;
    return [[aString substringWithRange:NSMakeRange(location, 1)] integerValue];
}

static inline YSWebViewOption parseYSWebViewOption(NSString **urlString){
    
    YSWebViewOption option = defaultYSWebViewOption();
    
    NSURL *url = [NSURL URLWithString:*urlString];
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    NSString *optionString;
    for (NSURLQueryItem *item in urlComponents.queryItems) {
        if ([item.name isEqualToString:@"option"]) {
            optionString = item.value;
            break;
        }
        continue;
    }
    if (!optionString) return option;
    
    NSString *replaceString = [NSString stringWithFormat:@"option=%@",optionString];
    NSRange range = [*urlString rangeOfString:replaceString];
    if (range.location != NSNotFound) {
        *urlString = [*urlString stringByReplacingOccurrencesOfString:replaceString withString:@""];
        NSUInteger lenght = [*urlString length];
        if ([[*urlString substringFromIndex:(lenght -1)] isEqualToString:@"?"]) {
            *urlString = [*urlString stringByReplacingOccurrencesOfString:@"?" withString:@""];
        }
    }
    
    int length = (int)optionString.length;
    
    option.showToolBar = subBitInString(optionString,--length);
    
    option.clearBackground = subBitInString(optionString,--length);
    option.lockRotation    = subBitInString(optionString,--length);
    option.landscape       = subBitInString(optionString,--length);
    
    option.hiddenNavigationBar      = subBitInString(optionString,--length);
    option.throughNavigationBar     = subBitInString(optionString,--length);
    option.lightNavigationBar       = subBitInString(optionString,--length);
    
    option.autoDetectTitle      = subBitInString(optionString,--length);
    option.showProgressBar      = subBitInString(optionString,--length);
    option.responseEntityKey    = subBitInString(optionString,--length);
    option.closeWhenLoadFailure = subBitInString(optionString,--length);
    
    option.transitionsStyle = subBitInString(optionString,--length);
    option.reduceAnimation  = subBitInString(optionString,--length);
    option.hiddenStatusBar  = subBitInString(optionString,--length);
    option.lightStatusBar   = subBitInString(optionString,--length);

    return option;
}



static inline NSString *descForYSWebViewOption(YSWebViewOption option){
    
    NSMutableString *desc = [NSMutableString string];
    [desc appendFormat:@"%@", @(option.lightStatusBar)];
    [desc appendFormat:@"%@", @(option.hiddenStatusBar)];
    [desc appendFormat:@"%@", @(option.reduceAnimation)];
    [desc appendFormat:@"%@", @(option.transitionsStyle)];
    [desc appendFormat:@"%@", @(option.closeWhenLoadFailure)];
    [desc appendFormat:@"%@", @(option.responseEntityKey)];
    [desc appendFormat:@"%@", @(option.showProgressBar)];
    [desc appendFormat:@"%@", @(option.autoDetectTitle)];
    [desc appendFormat:@"%@", @(option.lightNavigationBar)];
    [desc appendFormat:@"%@", @(option.throughNavigationBar)];
    [desc appendFormat:@"%@", @(option.hiddenNavigationBar)];
    [desc appendFormat:@"%@", @(option.landscape)];
    [desc appendFormat:@"%@", @(option.lockRotation)];
    [desc appendFormat:@"%@", @(option.clearBackground)];
    [desc appendFormat:@"%@", @(option.showToolBar)];
     
    NSRange range = [desc rangeOfString:@"1"];
    if (range.location == NSNotFound) {
        return @"";
    }
    
    [desc deleteCharactersInRange:NSMakeRange(0, range.location)];
    
    return [desc copy];
}



#endif /* YSWebViewOption_h */
