//
//  ViewController.m
//  YSWebViewDemo
//
//  Created by FinderTiwk on 2020/5/6.
//  Copyright © 2020 FinderTiwk. All rights reserved.
//

#import "ViewController.h"
#import <YSWebView/YSWebView.h>

@interface ViewController ()

@property (nonatomic,assign) YSWebViewOption option;

@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UITextView *optionStringTextView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    YSWebViewAppearance *appearance = [YSWebViewAppearance appearance];
    appearance.navigationBarBackgroundColor = [UIColor redColor];
    
    _optionStringTextView.textContainerInset = UIEdgeInsetsZero;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
    
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    navigationBar.barTintColor = [UIColor systemGreenColor];
    navigationBar.tintColor = [UIColor blackColor];
    [navigationBar setTitleTextAttributes:@{
        NSForegroundColorAttributeName : [UIColor whiteColor],
        NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Medium" size:18]
    }];
    
}


- (void)jumpTo:(NSString *)urlString htmlPath:(NSString *)htmlPath{
    
    YSWebViewController *webViewController = [YSWebViewController new];
    webViewController.urlString = urlString;
    webViewController.htmlFilePath = htmlPath;
    webViewController.option = self.option;
    
    NSDictionary *infoDict = [NSBundle mainBundle].infoDictionary;
    NSArray *urlTypes = infoDict[@"CFBundleURLTypes"];
    for (NSDictionary *dict in urlTypes) {
        if ([dict[@"CFBundleURLName"] isEqualToString:@"zfb"]) {
            webViewController.apWay = [dict[@"CFBundleURLSchemes"] firstObject];
        }
        if ([dict[@"CFBundleURLName"] isEqualToString:@"vx"]) {
            webViewController.vxWay = [dict[@"CFBundleURLSchemes"] firstObject];
        }
    }
    
    if (self.option.transitionsStyle) {
        webViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:webViewController animated:!self.option.reduceAnimation completion:NULL];
    }else{
        [self.navigationController pushViewController:webViewController animated:!self.option.reduceAnimation];
    }
}


#pragma mark - IBActions

- (IBAction)loadURLAction:(UIButton *)sender {
    NSString *urlString = (_urlTextField.text && _urlTextField.text.length > 0)?_urlTextField.text:_urlTextField.placeholder;
    [self jumpTo:urlString htmlPath:nil];
}

- (IBAction)loadLocalHTMLAction:(UIButton *)sender {
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    [self jumpTo:nil htmlPath:htmlPath];
}


- (IBAction)optionChangedAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    int flag = sender.selected ? 1: 0;
    
    YSWebViewOption option = self.option;
    
    switch (sender.tag) {
        case 1:
            option.showToolBar = flag;
            break;
        case 2:
            option.clearBackground = flag;
            break;
        case 3:
            option.lockRotation = flag;
            break;
        case 4:
            option.landscape = flag;
            break;
        case 5:
            option.hiddenNavigationBar = flag;
            break;
        case 6:
            option.throughNavigationBar = flag;
            break;
        case 7:
            option.lightNavigationBar = flag;
            break;
        case 8:
            option.autoDetectTitle = flag;
            break;
        case 9:
            option.showProgressBar = flag;
            break;
        case 10:
            option.responseEntityKey = flag;
            break;
        case 11:
            option.closeWhenLoadFailure = flag;
            break;
        case 12:
            option.transitionsStyle = flag;
            break;
        case 13:
            option.reduceAnimation = flag;
            break;
        case 14:
            option.hiddenStatusBar = flag;
            break;
        case 15:
            option.lightStatusBar = flag;
            break;

        default:
            break;
    }
    self.option = option;
    _optionStringTextView.text =  descForYSWebViewOption(self.option);
}


@end
