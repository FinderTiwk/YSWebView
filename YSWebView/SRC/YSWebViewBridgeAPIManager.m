//
//  YSWebViewBridgeAPIManager.m
//  GameBoxSDK
//
//  Created by FinderTiwk on 2019/6/13.
//  Copyright © 2019 FinderTiwk. All rights reserved.
//

#import "YSWebViewBridgeAPIManager.h"
#import <Photos/Photos.h>

typedef void (^YSBridgeCallback)(id result,BOOL complete);

@interface YSWebViewBridgeAPIManager ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic,copy) YSBridgeCallback imagePickerCallback;
@end

@implementation YSWebViewBridgeAPIManager

#pragma mark - API

//测试
- (id)test:(NSString *)message{
    [self showAlert:message];
    return nil;
}

#pragma mark - 状态栏控制
- (id)web_showStatusBar:(NSNumber *)show{
    YSWebViewOption option = self.webViewController.option;
    option.hiddenStatusBar = ([show boolValue] ? 0 :1);
    self.webViewController.option = option;
    [self.webViewController setNeedsStatusBarAppearanceUpdate];
    return nil;
}

- (id)web_changeStatusBarStyle:(NSNumber *)style{
    YSWebViewOption option = self.webViewController.option;
    option.lightStatusBar = ([style unsignedIntValue] == 1) ? 1 :0;
    self.webViewController.option = option;
    [self.webViewController setNeedsStatusBarAppearanceUpdate];
    return nil;
}

#pragma mark - 打开系统设置
- (id)web_hiddenKeyboard:(id)any{
    [self.webViewController.view endEditing:YES];
    return nil;
}

- (void)web_openExternalURL:(NSString *)urlString :(YSBridgeCallback)completionHandler{
    NSURL *url = [NSURL URLWithString:urlString];
    UIApplication *app = [UIApplication sharedApplication];
    if ([app canOpenURL:url]) {
        if (@available(iOS 10.0, *)) {
            [app openURL:url options:@{} completionHandler:^(BOOL success) {
                completionHandler(@(success),YES);
            }];
        } else {
            completionHandler(@([app openURL:url]),YES);
        }
    }else{
        completionHandler(@(NO),YES);
    }
}

- (id)web_openSystemSetting:(id)any{
    NSURL *settingURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    UIApplication *app = [UIApplication sharedApplication];
    if ([app canOpenURL:settingURL]) {
        if (@available(iOS 10.0, *)) {
            [app openURL:settingURL options:@{} completionHandler:NULL];
        } else {
            [app openURL:settingURL];
        }
    }
    return nil;
}

- (id)web_killApplication:(id)any{
    exit(0);
    return nil;
}

#pragma mark - Key:Value 存取
- (id)web_saveKeyValue:(NSDictionary *)item{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.yswebView"];
    for (NSString *key in item.allKeys) {
        [userDefaults setObject:item[key] forKey:key];
    }
    [userDefaults synchronize];
    return nil;
}

- (id)web_getValueForKey:(NSString *)key{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.yswebView"];
    id value = [userDefaults objectForKey:key];
    
    return value?:@"";
}

- (id)web_deleteKeyValue:(NSString *)key{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.yswebView"];
    [userDefaults removeObjectForKey:key];
    [userDefaults synchronize];
    return nil;
}

- (void)web_getWidgetFrame:(id)any :(YSBridgeCallback)completionHandler{
    CGSize size = self.webViewController.anchorWidget.bounds.size;
    CGPoint point = [self.webViewController.anchorWidget convertPoint:CGPointZero toView:self.webViewController.view];
    NSDictionary *result = @{@"x":@(point.x),
                             @"y":@(point.y),
                             @"w":@(size.width),
                             @"h":@(size.height)};
    completionHandler(result,YES);
}

- (id)web_getContainerBounds:(id)any{
    CGSize size = self.webViewController.view.bounds.size;
    return @{@"x":@(0.0),
             @"y":@(0.0),
             @"w":@(size.width),
             @"h":@(size.height)};
}

#pragma mark - 图片处理
- (void)web_pickImage:(id)any :(YSBridgeCallback)completionHandler{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.modalPresentationStyle = UIModalPresentationFullScreen;
    _imagePickerCallback = completionHandler;
    [self.webViewController presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    _imagePickerCallback = NULL;
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSData *imagedata = UIImagePNGRepresentation(image);
    NSString *image64String = [imagedata base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    [picker dismissViewControllerAnimated:YES completion:^{
        self.imagePickerCallback(image64String,YES);
    }];
}

- (void)web_saveImage:(NSString *)base64String :(YSBridgeCallback)completionHandler{
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    UIImage *image = [UIImage imageWithData:data];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (void *)CFBridgingRetain(completionHandler));
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
    NSString *result = error?@"1":@"0";
    ((__bridge YSBridgeCallback)contextInfo)(result,YES);
    if (!error) return;
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if(status != PHAuthorizationStatusAuthorized){
            [self showAlert:@"请到系统设置里打开相册"];
        }
    }];
}

#pragma mark - 文本处理
- (void)web_copyText:(NSString *)text :(YSBridgeCallback)completionHandler{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = text;
    completionHandler(@(YES),YES);
}


#pragma mark - 窗口相关
- (id)web_openNewWindow:(NSString *)urlString{
    
    YSWebViewOption option = parseYSWebViewOption(&urlString);
    YSWebViewController *dest = [[YSWebViewController alloc] init];
    dest.urlString = urlString;
    dest.option = option;
    
    if (option.transitionsStyle ||
        !self.webViewController.navigationController) {
        
        dest.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.webViewController presentViewController:dest animated:!option.reduceAnimation completion:NULL];
        return nil;
    }
    
    [self.webViewController.navigationController pushViewController:dest animated:!option.reduceAnimation];
    return nil;
}

- (id)web_closeWindow:(id)any{
    [self.webViewController close:0];
    return nil;
}

- (id)web_loginSuccess:(NSDictionary *)params{
    [[NSNotificationCenter defaultCenter] postNotificationName:YSWebLoginSuccessNotification object:params];
    return nil;
}

- (id)web_logout:(id)any{
    [[NSNotificationCenter defaultCenter] postNotificationName:YSWebLogoutNotification object:nil];
    return nil;
}

- (id)web_transactionSuccess:(NSDictionary *)params{
    [[NSNotificationCenter defaultCenter] postNotificationName:YSWebTransactionSuccessNotification object:params];
    return nil;
}

- (id)web_willDoIAP:(NSDictionary *)params{
    [[NSNotificationCenter defaultCenter] postNotificationName:YSWebWillDoIAPNotification object:params];
    return nil;
}


- (id)web_genSign:(NSDictionary *)params{
    if (self.webViewController.signProvider) {
        return self.webViewController.signProvider(params);
    }
    return nil;
}

- (id)web_getNativeHeader:(id)any{
    if (self.webViewController.headerProvider) {
        return self.webViewController.headerProvider();
    }
    return nil;
}

- (id)web_getNativeVersion:(id)any{
    return self.webViewController.versionString;
}


#pragma mark - Private
- (void)showAlert:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:NULL];
    [alert addAction:confirmAction];
    [self.webViewController presentViewController:alert animated:YES completion:NULL];
}


@end
