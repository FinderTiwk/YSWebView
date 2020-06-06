//
//  YSWebViewKit.m
//  YSCoreSDK
//
//  Created by FinderTiwk on 2020/5/4.
//  Copyright © 2020 Zhejiang Yushi Network Inc. All rights reserved.
//

#import "YSWebViewKit.h"
#import <objc/message.h>

#import "YSWebViewController.h"
#import "YSWebViewBridgeAPIManager.h"


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - JSON Convert

NSString *ysWebview_collection2JsonString(id collection){
    
    NSString *jsonString = @"{}";
    if (!collection || ![NSJSONSerialization isValidJSONObject:collection]) {
        return jsonString;
    }
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:collection options:0 error:&error];
    if (error || !jsonData) {
        return jsonString;
    }

    jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //Tip: 解决苹果系统的一个BUG 集合转换成Json时会将'/'转换为'\/'
    //为了处理base64后'/'的问题 http://www.cnblogs.com/kongkaikai/p/5627205.html
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    return jsonString;
}


id ysWebview_jsonString2Collection(NSString *jsonString){
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (!jsonData) return nil;
    
    NSError *error;
    id collection = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (error) return nil;
    return collection;
    
}


@interface YSWebViewKit()<WKNavigationDelegate,WKUIDelegate>

@property (nonatomic,strong,readwrite) WKWebView *webView;
@property (nonatomic,strong) YSWebViewBridgeAPIManager *jsManager;
@property (nonatomic,assign) int callbackCounter;
@property (nonatomic,strong) NSMutableDictionary *callbackMap;

@end

@implementation YSWebViewKit

#pragma mark 清空缓存
+ (void)load{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSString *libraryPath;
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    if (array.count > 0 && array) {
        libraryPath = [array objectAtIndex:0];
    }
    NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
    NSError *errors;
    [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
    
    //清空所有缓存
    NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
    NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
    
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
        
    }];
}


+ (instancetype)webKitFor:(YSWebViewController *)webViewController{
    YSWebViewKit *kit = [YSWebViewKit new];
    
    YSWebViewBridgeAPIManager *jsManager = [YSWebViewBridgeAPIManager new];
    jsManager.webViewController = webViewController;
    
    kit.jsManager = jsManager;
    NSURL *url = [NSURL URLWithString:webViewController.urlString];
    kit->_webView = [kit webViewWithCookies:webViewController.cookies host:url.host];
    
    return kit;
}


- (WKWebView *)webViewWithCookies:(NSDictionary *)cookies host:(NSString *)host{
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    WKUserScript *bridgeScript = [[WKUserScript alloc] initWithSource:@"window._dswk=true;"
                                                  injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                               forMainFrameOnly:YES];
    [userContentController addUserScript:bridgeScript];
    
    if (cookies && host) {
        NSMutableString *cookieString = [[NSMutableString alloc] init];
        for (NSString *key in cookies) {
            [cookieString appendFormat:@"document.cookie = '%@=%@; path=/; domain=%@';", key, cookies[key], host];
        }
        WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:cookieString injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [userContentController addUserScript:cookieScript];
    }
    
    config.userContentController = userContentController;
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    webView.navigationDelegate = self;
    webView.UIDelegate = self;
    webView.translatesAutoresizingMaskIntoConstraints = NO;
    webView.scrollView.bounces = NO;
    webView.opaque = NO;
    webView.backgroundColor = [UIColor clearColor];
    webView.scrollView.backgroundColor = [UIColor clearColor];
    webView.scrollView.showsVerticalScrollIndicator = NO;
    webView.scrollView.showsHorizontalScrollIndicator = NO;
    if (@available(iOS 11.0, *)) {
        webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.jsManager.webViewController.automaticallyAdjustsScrollViewInsets = NO;
    }
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:webView name:UIKeyboardWillHideNotification object:nil];
    [center removeObserver:webView name:UIKeyboardWillShowNotification object:nil];
    [center removeObserver:webView name:UIKeyboardWillChangeFrameNotification object:nil];
    [center removeObserver:webView name:UIKeyboardDidChangeFrameNotification object:nil];
    return webView;
}



#pragma mark - API
- (void)notifyH5Register:(NSString *)functionName arguments:(NSArray *)args{
    [self notifyH5Register:functionName arguments:args callback:NULL];
}

- (void)notifyH5Register:(NSString *)functionName arguments:(NSArray *)args callback:(void(^)(id retValue))callback{
    
    id callbackId = @(++self.callbackCounter);
    NSString *payload = ysWebview_collection2JsonString(@{
        @"callbackId":callbackId,
        @"method":functionName,
        @"data":ysWebview_collection2JsonString(args)
    });
    if (callback) {
        if (!self.callbackMap) {
            self.callbackMap = [NSMutableDictionary dictionary];
        }
        self.callbackMap[callbackId] = callback;
    }
    NSString *javaScript = [NSString stringWithFormat:@"window._handleMessageFromNative(%@)",payload];
    [self.webView evaluateJavaScript:javaScript completionHandler:NULL];
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    
    static NSString * const DSBridgePrefix = @"_dsbridge=";
    if ([prompt hasPrefix:DSBridgePrefix]) {
        // 这里处理js调用native方法,核心思想
        NSString *methodName = [prompt substringFromIndex:DSBridgePrefix.length];
        NSString *result = nil;
        @try {
            result = YSWEBVIEW_LOOKUPIMP_AND_INVOKE(self, methodName, defaultText);
        } @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
        completionHandler(result);
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *input = ((UITextField *)alertController.textFields.firstObject).text;
        completionHandler(input);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(nil);
    }]];
    [self.jsManager.webViewController presentViewController:alertController animated:YES completion:NULL];
}


- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    
    [self alert:message confirm:^{
        completionHandler();
    } cancel:NULL];
}

//弹出确认框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    
    [self alert:message confirm:^{
        completionHandler(YES);
    } cancel:^{
        completionHandler(NO);
    }];
}

//是否打开新的WebView
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

//证书校验
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
    CFDataRef exceptions = SecTrustCopyExceptions(serverTrust);
    SecTrustSetExceptions(serverTrust, exceptions);
    CFRelease(exceptions);
    completionHandler(NSURLSessionAuthChallengeUseCredential,
                      [NSURLCredential credentialForTrust:serverTrust]);
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - WKNavigationDelegate
//开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    !self.startLoading?:self.startLoading(self.jsManager.webViewController);
}

//加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    !self.loadSuccess?:self.loadSuccess(self.jsManager.webViewController);
    if (self.jsManager.webViewController.transactionParams) {
        [self notifyH5Register:@"app_transaction" arguments:@[self.jsManager.webViewController.transactionParams]];
    }
}

//加载失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    // 这是上一个请求未完成就来下一个请求的错误，继续往下走，别出现错误提示
    if (error &&
        error.code == NSURLErrorCancelled) {
        return;
    }
    !self.loadFailure?:self.loadFailure(self.jsManager.webViewController,error);
}

//解决白屏: 当WKWebView 总体内存占用过大,页面即将白屏的时候
//Tip: https://juejin.im/entry/5880ac602f301e006980d1f5
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{
    [webView reload];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    
    if (((NSHTTPURLResponse *)navigationResponse.response).statusCode == 200) {
        decisionHandler (WKNavigationResponsePolicyAllow);
    }else {
        decisionHandler(WKNavigationResponsePolicyCancel);
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    NSURL *url = navigationAction.request.URL;
    NSString *absoluteString = (url) ? url.absoluteString : @"";
    if (!url ||  absoluteString.length == 0) {
        return;
    }
    
    UIApplication *app = [UIApplication sharedApplication];
    
    //alipay base64
    NSString *ap64 = @"YWxpcGF5";
    NSData *apData = [[NSData alloc]initWithBase64EncodedString:ap64 options:0];
    NSString *apPrefix = [[NSString alloc]initWithData:apData encoding:NSUTF8StringEncoding];
    // 支付宝支付
    if ([url.scheme hasPrefix:apPrefix]) {
        NSCParameterAssert(self.jsManager.webViewController.apWay);
        NSArray *urlBaseArr = [navigationAction.request.URL.absoluteString componentsSeparatedByString:@"?"];
        NSString *urlBaseStr = urlBaseArr.firstObject;
        NSString *urlNeedDecode = urlBaseArr.lastObject;
        NSString *decodeString =  ysWebview_decodeURL(urlNeedDecode);
        NSString *afterHandleStr = [decodeString stringByReplacingOccurrencesOfString:[apPrefix stringByAppendingString:@"s"] withString:self.jsManager.webViewController.apWay];
        NSString *finalStr = [NSString stringWithFormat:@"%@?%@",urlBaseStr, ysWebview_encodeURL(afterHandleStr)];
        NSURL *replacedURL = [NSURL URLWithString:finalStr];
        decisionHandler(WKNavigationActionPolicyCancel);
        if ([app canOpenURL:replacedURL]) {
            if (@available(iOS 10.0, *)) {
                [app openURL:replacedURL options:@{} completionHandler:^(BOOL success) {
                    [self.jsManager.webViewController close:nil];
                }];
            } else {
                [app openURL:replacedURL];
                [self.jsManager.webViewController close:nil];
            }
        }
        return;
    }
    
    //vx base64  https://wx.tenpay.com/cgi-bin/mmpayweb-bin/checkmweb
    NSString *vx64 = @"aHR0cHM6Ly93eC50ZW5wYXkuY29tL2NnaS1iaW4vbW1wYXl3ZWItYmluL2NoZWNrbXdlYg==";
    NSData *vxData = [[NSData alloc]initWithBase64EncodedString:vx64 options:0];
    NSString *vxPrefix = [[NSString alloc]initWithData:vxData encoding:NSUTF8StringEncoding];
    // 微信支付
    if ([absoluteString hasPrefix:vxPrefix]){
        if ([navigationAction.request.allHTTPHeaderFields valueForKey:@"referer"]) {
            decisionHandler(WKNavigationActionPolicyAllow);
            return;
        }
        NSCParameterAssert(self.jsManager.webViewController.vxWay);
        NSMutableURLRequest *vxRequest = [NSMutableURLRequest requestWithURL:url];
        NSString *referer = [NSString stringWithFormat:@"%@://",self.jsManager.webViewController.vxWay];
        [vxRequest addValue:referer forHTTPHeaderField:@"referer"];
        [webView loadRequest:vxRequest];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    
    NSString *itunesRegex = @"\\/\\/itunes\\.apple\\.com\\/";
    NSPredicate *itunesTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", itunesRegex];
    
    // itunes下载应用链接
    if ([itunesTest evaluateWithObject:itunesRegex]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        if ([app canOpenURL:url]) {
            if (@available(iOS 10.0, *)) {
                [app openURL:url options:@{} completionHandler:^(BOOL success) {}];
            } else {
                [app openURL:url];
            }
            return;
        }
    }
    
    //QQ,微信
    else if ([absoluteString hasPrefix:@"mqq"] ||
             [absoluteString hasPrefix:@"weixin"] ||
             [absoluteString hasPrefix:@"wechat"]) {
        !self.loadSuccess?:self.loadSuccess(self.jsManager.webViewController);
        decisionHandler(WKNavigationActionPolicyCancel);
        if ([app canOpenURL:url]) {
            if (@available(iOS 10.0, *)) {
                [app openURL:url options:@{} completionHandler:^(BOOL success) {
                    [self.jsManager.webViewController close:nil];
                }];
            } else {
                [app openURL:url];
                [self.jsManager.webViewController close:nil];
            }
        }
        return;
    }
    
    // fir.im 那种app下载
    else if ([[absoluteString lowercaseString] hasPrefix:@"itms-services://"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        if ([app canOpenURL:url]) {
            if (@available(iOS 10.0, *)) {
                [app openURL:url options:@{} completionHandler:^(BOOL success) {}];
            } else {
                [app openURL:url];
            }
            return;
        }
    }
    // 空白页面不加载
    else if ([absoluteString isEqualToString:@"about:blank"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}


#pragma mark - JS Inner
- (id)dsinit:(NSDictionary *)args{
    return nil;
}

- (id)returnValue:(NSDictionary *)args{
    id callbackKey = args[@"id"];
    if (!callbackKey) return nil;
    
    void (^callback)(NSString *  _Nullable) = self.callbackMap[callbackKey];
    if (callback) {
        callback(args[@"data"]);
        if([args[@"complete"] boolValue]){
            [ self.callbackMap removeObjectForKey:callbackKey];
        }
    }
    return nil;
}


#pragma mark - private
- (void)alert:(NSString *)message
      confirm:(void(^)(void))confirm
       cancel:(void(^)(void))cancel{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    if (cancel) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            cancel();
        }];
        [alert addAction:cancelAction];
    }
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        confirm();
    }];
    [alert addAction:confirmAction];
    
    [self.jsManager.webViewController presentViewController:alert animated:YES completion:NULL];
}



static inline NSString * ysWebview_decodeURL(NSString *urlString){
    NSMutableString *outputStr = [NSMutableString stringWithString:urlString];
    [outputStr replaceOccurrencesOfString:@"+" withString:@"" options:NSLiteralSearch range:NSMakeRange(0,[outputStr length])];
    return [outputStr stringByRemovingPercentEncoding];
}

static inline NSString * ysWebview_encodeURL(NSString *urlString){
    NSString *charactersToEscape = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
    NSCharacterSet *set = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    return [urlString stringByAddingPercentEncodingWithAllowedCharacters:set];
}



NSDictionary * ysWebview_formatRet(int code, id data){
    return @{@"code":@(code),@"data":data};
}



// 这里处理js调用native方法,核心思想
NSString * YSWEBVIEW_LOOKUPIMP_AND_INVOKE(YSWebViewKit *kit,NSString *methodName,NSString *jsonArgsString){
    NSString *nameSpace = @"";
    NSString *selName = methodName;
    NSRange range = [methodName rangeOfString:@"." options:NSBackwardsSearch];
    if (range.location != NSNotFound) {
        nameSpace = [methodName substringToIndex:range.location];
        selName =  [methodName substringFromIndex:range.location+1];
    }
    
    id receiver = [nameSpace isEqualToString:@"_dsb"] ? kit : kit.jsManager;
    
    NSDictionary *args = ysWebview_jsonString2Collection(jsonArgsString);
    id arg = args[@"data"] ? : nil;
    if(arg == [NSNull null]){
        arg = nil;
    }
    
    SEL syncSEL  = NSSelectorFromString([NSString stringWithFormat:@"%@:",selName]);
    SEL asyncSEL = NSSelectorFromString([NSString stringWithFormat:@"%@::",selName]);
    
    // 异步方法
    NSString * callbackID;
    if (args && (callbackID = args[@"_dscbstub"]) && [receiver respondsToSelector:asyncSEL]){
        
        void (^callback)(id,BOOL) = ^(id ret,BOOL complete){
            ret = ysWebview_collection2JsonString(ysWebview_formatRet(0, ret?:@""));
            ret = [ret stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            
            NSString *del = complete ? [@"delete window." stringByAppendingString:callbackID] : @"";
            NSString *javaScript = [NSString stringWithFormat:@"try {%@(JSON.parse(decodeURIComponent(\"%@\")).data);%@; } catch(e){};",callbackID,(ret == nil) ? @"" : ret,del];
            [kit.webView evaluateJavaScript:javaScript completionHandler:NULL];
        };
        
        void(*action)(id,SEL,id,id) = (void(*)(id,SEL,id,id))objc_msgSend;
        action(receiver,asyncSEL,arg,callback);
    }
    
    // 处理同步方法
    else if ([receiver respondsToSelector:syncSEL]) {
        id(*functionPtr)(id,SEL,id) = (id(*)(id,SEL,id))objc_msgSend;
        id ret = functionPtr(receiver,syncSEL,arg);
        NSDictionary *result = ysWebview_formatRet(0, ret ? : @"");
        return ysWebview_collection2JsonString(result);
    }
    
    // 没有实现对应的方法
    else{
        NSLog(@"Error! \n Method %@ is not invoked, since there is not a implementation for it",methodName);
    }
    
    return nil;
}



@end
