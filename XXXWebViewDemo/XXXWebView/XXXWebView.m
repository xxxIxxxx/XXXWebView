//
//  XXXWebView.m
//  XXXWebView
//
//  Created by Z on 2019/5/5.
//  Copyright © 2019 losht. All rights reserved.
//

#import "XXXWebView.h"
#import <SDWebImage/SDWebImage.h>
@interface XXXWebView ()



@property (nonatomic, copy) NSString *xxxCustomImageUrl;

@property (nonatomic, copy) NSString *xxxHtmlString;

@end

@implementation XXXWebView


//第二次获取高度延迟时间 不建议太小 否则可能获取高度不对
#define DelayTime 0.4

#define XXXCustomImageScheme @"xxxixxxx"

- (NSString *)xxxCustomImageUrl {
    return  [self.oriImageUrl stringByReplacingOccurrencesOfString:self.oriImageScheme withString:XXXCustomImageScheme];
}

#pragma mark -
@synthesize webView = _webView;
- (WKWebView *)webView {
    if (!_webView) {
        
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        XXXCustomSchemeHanlder *schemeHandler = XXXCustomSchemeHanlder.new;
        
        schemeHandler.oriImageScheme = self.oriImageScheme;
        schemeHandler.oriImageUrl = self.oriImageUrl;
        schemeHandler.placeholderImage = self.placeholderImage;
        
        __weak typeof(self) weakSelf = self;
        schemeHandler.updateImageBlock = ^ {
            [weakSelf updateHeight];
        };
        [config setURLSchemeHandler:schemeHandler forURLScheme:XXXCustomImageScheme];
        WKWebView  *webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height) configuration:config];
        _webView = webView;
        [self addSubview:webView];
        
    }
    return _webView;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.webView.frame = CGRectMake(0, 0, self.width, self.height);
}

- (void)setHtmlString:(NSString *)htmlString {
    _htmlString = htmlString;
    self.xxxHtmlString = htmlString;
    [self changeImageScheme];
    [self addHtmlLab];
    [self addGetAllImgScript];
    [self addUpdateImgScript];
}

- (void)startLoadHTMLString {
    
    if (!self.xxxHtmlString) {
        return;
    }
    
    [self.webView loadHTMLString:self.xxxHtmlString baseURL:nil];
}


- (void)changeImageScheme {

    self.xxxHtmlString = [self.xxxHtmlString stringByReplacingOccurrencesOfString:self.oriImageUrl withString:self.xxxCustomImageUrl];
}

- (void)addHtmlLab {
    
    if (![self.xxxHtmlString containsString:@"</html>"]) {
        self.xxxHtmlString = [NSString stringWithFormat:@"<html><head><meta charset=\"utf-8\"><meta content='width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=no,minimum-scale=1.0'name='viewport'><style>div {margin-left: 10px;margin-right:10px;}img{width:%fpx;height: auto;}</style></head><body><div>%@</div></body></html>",UIScreen.mainScreen.bounds.size.width - 50,self.xxxHtmlString];
    }
}

- (void)addGetAllImgScript {


    NSString *scriptLab1 = @"</script>";
    
    NSString *jsFunctionString = @"function xxxGetAllImg() {\
    var es = document.getElementsByTagName(\"img\");\
    return Array.from(es);}var allimgList = xxxGetAllImg();";
    
    
    if ([self.xxxHtmlString containsString:scriptLab1]) {
     
        NSString *scriptString = [NSString stringWithFormat:@"%@%@",jsFunctionString,scriptLab1];
        self.xxxHtmlString = [self.xxxHtmlString stringByReplacingOccurrencesOfString:scriptLab1 withString:scriptString];
        
    }else {
        NSString *scriptLab0 = @"<script>";
        NSString *htmlLab = @"</html>";
        
        NSString *scriptString = [NSString stringWithFormat:@"%@%@%@%@",scriptLab0,jsFunctionString,scriptLab1,htmlLab];
        self.xxxHtmlString = [self.xxxHtmlString stringByReplacingOccurrencesOfString:htmlLab withString:scriptString];
    }
    
}


- (void)addUpdateImgScript {
    
    
    NSString *scriptLab1 = @"</script>";
    
    NSString *jsFunctionString = @"function xxxUpdateImage(url, imgData) {\
    var list = allimgList;\
    for (let item of list) {\
      if (item.src == url) {\
        item.src = imgData;break;}}} ";
    
  
    if ([self.xxxHtmlString containsString:scriptLab1]) {
     
        NSString *scriptString = [NSString stringWithFormat:@"%@%@",jsFunctionString,scriptLab1];
        self.xxxHtmlString = [self.xxxHtmlString stringByReplacingOccurrencesOfString:scriptLab1 withString:scriptString];
        
    }else {
        NSString *scriptLab0 = @"<script>";
        NSString *htmlLab = @"</html>";
        NSString *scriptString = [NSString stringWithFormat:@"%@%@%@%@",scriptLab0,jsFunctionString,scriptLab1,htmlLab];
        self.xxxHtmlString = [self.xxxHtmlString stringByReplacingOccurrencesOfString:htmlLab withString:scriptString];
    }
}


- (void)addImgClickScript {
    
    NSString *scriptLab1 = @"</script>";
    NSString *jsFunctionString = [NSString stringWithFormat:@"function xxxIsATag(element) {if (element.constructor == HTMLAnchorElement) {var a = new Object();a.isA = true;a.url = element;return a;} else if (element.parentElement != null) {return xxxIsATag(element.parentElement);} else {var a = new Object();a.isA = false;a.url = '';return a;}}!function xxxAddClick() {var list = allimgList;list.forEach(element => {console.log(element);element.onclick = function () {var imgSrc = element.src;var a = xxxIsATag(element);window.location.href = `%@://?isA=${a.isA}&aUrl=${a.url}&imgSrc=${imgSrc}`;}});}();",XXXCustomImageScheme];
  
    if ([self.xxxHtmlString containsString:scriptLab1]) {
     
        NSString *scriptString = [NSString stringWithFormat:@"%@%@",jsFunctionString,scriptLab1];
        self.xxxHtmlString = [self.xxxHtmlString stringByReplacingOccurrencesOfString:scriptLab1 withString:scriptString];
        
    }else {
        NSString *scriptLab0 = @"<script>";
        NSString *htmlLab = @"</html>";
        NSString *scriptString = [NSString stringWithFormat:@"%@%@%@%@",scriptLab0,jsFunctionString,scriptLab1,htmlLab];
        self.xxxHtmlString = [self.xxxHtmlString stringByReplacingOccurrencesOfString:htmlLab withString:scriptString];
    }
}

- (void)updateHeight {
    [self nowUpdateHeight];
    [self delayUpdateHeight];
}

- (void)nowUpdateHeight {
    
    __weak typeof(self) weakSelf = self;
    [self.webView evaluateJavaScript:@"document.body.offsetHeight" completionHandler:^(id _Nullable result,NSError * _Nullable error) {
        
        // 高度会有一点少 ，手动补上一些
        CGFloat height = [result floatValue] + 10.0;
        if (weakSelf.loadOverHeight) {
            weakSelf.loadOverHeight(height);
        }
    }];
}

- (void)delayUpdateHeight {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, DelayTime * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self nowUpdateHeight];
    });
}


+(BOOL)isCustomScheme:(WKNavigationAction *)navigationAction {
    NSURL *url = navigationAction.request.URL;
    NSString *scheme = [url scheme];
    if ([scheme isEqualToString:XXXCustomImageScheme]) {
        return YES;
    }
    return NO;
}

+(BOOL)isA:(WKNavigationAction *)navigationAction {
    NSURL *url = navigationAction.request.URL;
    NSString *scheme = [url scheme];
    if ([scheme isEqualToString:XXXCustomImageScheme]) {
        NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
        for (NSURLQueryItem *item in urlComponents.queryItems) {
            if ([item.name isEqualToString:@"isA"]) {
                return ![item.value isEqualToString:@"false"];
            }
        }
    }
    return NO;
}



+(void)customScheme:(WKNavigationAction *)navigationAction oriImageScheme:(NSString *)oriImageScheme imgClick:(void(^)(BOOL isA,NSString *aUrl,NSString *imgUrl,UIImage *image))imgClickBlock {
    
    if (!imgClickBlock) {
        return;
    }
    
    NSURL *url = navigationAction.request.URL;
    NSString *scheme = [url scheme];
    if ([scheme isEqualToString:XXXCustomImageScheme]) {
        NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
        BOOL isA = NO;
        NSString *aUrl;
        NSString *imgUrl;
        UIImage *image;
        for (NSURLQueryItem *item in urlComponents.queryItems) {
            if ([item.name isEqualToString:@"isA"]) {
                isA = ![item.value isEqualToString:@"false"];
            }
            if ([item.name isEqualToString:@"aUrl"]) {
                aUrl = item.value;
            }
            if ([item.name isEqualToString:@"imgSrc"]) {
                if ([item.value containsString:XXXCustomImageScheme]) {
                    imgUrl = [item.value stringByReplacingOccurrencesOfString:XXXCustomImageScheme withString:oriImageScheme];
                    
                }else{
                    NSString *base64String = [item.value stringByReplacingOccurrencesOfString:@"data:image/png;base64," withString:@""];
                    NSData *imgData = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
                    image = [UIImage imageWithData:imgData];
                }
            }
        }
        imgClickBlock(isA,aUrl,imgUrl,image);
    }
}



@end

#pragma mark -
#pragma mark - XXXCustomSchemeHanlder

@implementation XXXCustomSchemeHanlder


- (void)webView:(nonnull WKWebView *)webView startURLSchemeTask:(nonnull id<WKURLSchemeTask>)urlSchemeTask {
    
    UIImage *image = self.placeholderImage;
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    NSURLResponse *response = [[NSURLResponse alloc] initWithURL:urlSchemeTask.request.URL MIMEType:@"image/jpeg" expectedContentLength:data.length textEncodingName:nil];
    [urlSchemeTask didReceiveResponse:response];
    [urlSchemeTask didReceiveData:data];
    [urlSchemeTask didFinish];
    
    if (self.updateImageBlock) {
        self.updateImageBlock();
    }
    
    NSString *htmlImageUrlStr = [NSString stringWithFormat:@"%@",urlSchemeTask.request.URL];
    NSString *dloadImageUrlStr = [htmlImageUrlStr stringByReplacingOccurrencesOfString:XXXCustomImageScheme withString:self.oriImageScheme];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        [self readImageForKey:dloadImageUrlStr htmlImageUrlStr:htmlImageUrlStr webView:webView];
    });
}



- (void)readImageForKey:(NSString *)dloadImageUrlStr htmlImageUrlStr:(NSString *)htmlImageUrlStr webView:(WKWebView *)webView {
    
    __weak typeof(self) weakSelf = self;
    NSURL *url = [NSURL URLWithString:dloadImageUrlStr];
    [[SDWebImageManager sharedManager] loadImageWithURL:url options:SDWebImageRetryFailed progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        
        if (image || data) {
            NSData *imgData = data;
            
            if (!imgData) imgData = UIImageJPEGRepresentation(image, 1);
            
            [weakSelf callJsUpdateImage:webView imageData:imgData htmlImageUrlStr:htmlImageUrlStr];
        }
        if (error) {}
    }];
}




- (void)callJsUpdateImage:(WKWebView *)webView imageData:(NSData *)imageData htmlImageUrlStr:(NSString *)imageUrlString {
    
    __weak typeof(self) weakSelf = self;
    NSString *imageDataStr = [NSString stringWithFormat:@"data:image/png;base64,%@",[imageData base64EncodedString]];
    NSString *func = [NSString stringWithFormat:@"xxxUpdateImage('%@','%@')",imageUrlString,imageDataStr];
    [webView evaluateJavaScript:func completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        if (weakSelf.updateImageBlock && !error) {
            weakSelf.updateImageBlock();
        }
    }];
}

- (void)webView:(nonnull WKWebView *)webView stopURLSchemeTask:(nonnull id<WKURLSchemeTask>)urlSchemeTask {
    
}

@end











#pragma mark -
#pragma mark - Extension

@implementation UIView (copy_YYAdd)


- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}


- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

@end

@implementation NSData (xxx)

- (NSString *)base64EncodedString {
    NSUInteger length = self.length;
    if (length == 0)
        return @"";
    
    NSUInteger out_length = ((length + 2) / 3) * 4;
    uint8_t *output = malloc(((out_length + 2) / 3) * 4);
    if (output == NULL)
        return nil;
    
    const char *input = self.bytes;
    NSInteger i, value;
    for (i = 0; i < length; i += 3) {
        value = 0;
        for (NSInteger j = i; j < i + 3; j++) {
            value <<= 8;
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        NSInteger index = (i / 3) * 4;
        output[index + 0] = base64EncodingTable[(value >> 18) & 0x3F];
        output[index + 1] = base64EncodingTable[(value >> 12) & 0x3F];
        output[index + 2] = ((i + 1) < length)
        ? base64EncodingTable[(value >> 6) & 0x3F]
        : '=';
        output[index + 3] = ((i + 2) < length)
        ? base64EncodingTable[(value >> 0) & 0x3F]
        : '=';
    }
    
    NSString *base64 = [[NSString alloc] initWithBytes:output
                                                length:out_length
                                              encoding:NSASCIIStringEncoding];
    free(output);
    return base64;
}

static const char base64EncodingTable[64]
= "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";


@end