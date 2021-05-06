//
//  XXXWebView.m
//  XXXWebView
//
//  Created by Z on 2019/5/5.
//  Copyright © 2019 losht. All rights reserved.
//

#import "XXXWebView.h"
// https://github.com/topfunky/hpple/tree/master
#import "TFHpple.h"
#import <SDWebImage/SDWebImage.h>

#pragma mark -
#pragma mark - XXXCustomSchemeHanlder


@interface XXXCustomSchemeHanlder : NSObject <WKURLSchemeHandler>

@property (nonatomic, copy) NSDictionary<NSString *,NSString *> *imgUrlDict;
@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, copy) void(^updateImageBlock)(void);

@end


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
    
    NSString *customSchemeUrl = [NSString stringWithFormat:@"%@",urlSchemeTask.request.URL];
    NSString *oriSchemeUrl = self.imgUrlDict[customSchemeUrl];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        [self readImageForKey:oriSchemeUrl customSchemeUrl:customSchemeUrl webView:webView];
    });
}



- (void)readImageForKey:(NSString *)oriSchemeUrl customSchemeUrl:(NSString *)customSchemeUrl webView:(WKWebView *)webView {
    
    __weak typeof(self) weakSelf = self;
    NSURL *url = [NSURL URLWithString:oriSchemeUrl];
    [[SDWebImageManager sharedManager] loadImageWithURL:url options:SDWebImageRetryFailed progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        
        if (image || data) {
            NSData *imgData = data;
            
            if (!imgData) imgData = UIImageJPEGRepresentation(image, 1);
            
            [weakSelf callJsUpdateImage:webView imageData:imgData htmlImageUrlStr:customSchemeUrl];
        }
        if (error) {}
    }];
}




- (void)callJsUpdateImage:(WKWebView *)webView imageData:(NSData *)imageData htmlImageUrlStr:(NSString *)imageUrlString {
    
    __weak typeof(self) weakSelf = self;
    NSString *imageDataStr = [NSString stringWithFormat:@"data:image/png;base64,%@",[imageData xxx_base64EncodedString]];
    NSString *func = [NSString stringWithFormat:@"xxxUpdateImage('%@','%@')",imageUrlString,imageDataStr];

    [webView evaluateJavaScript:func completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        if (weakSelf.updateImageBlock) {
            weakSelf.updateImageBlock();
        }
    }];
}

- (void)webView:(nonnull WKWebView *)webView stopURLSchemeTask:(nonnull id<WKURLSchemeTask>)urlSchemeTask {
    
}

@end


#pragma mark -
#pragma mark - XXXWebView

@interface XXXWebView ()

@property (nonatomic, copy) NSString *xxxHtmlString;
@property (nonatomic, strong) NSMutableDictionary<NSString *,NSString *> *imageUrlDict;
@property (nonatomic, strong) XXXCustomSchemeHanlder *schemeHandler;
@end

@implementation XXXWebView


- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    self.imageUrlDict = @{}.mutableCopy;
    self.delayTime = 0.4;
  }
  return self;
}


@synthesize webView = _webView;
- (WKWebView *)webView {
    if (!_webView) {

        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        XXXCustomSchemeHanlder *schemeHandler = XXXCustomSchemeHanlder.new;
        self.schemeHandler = schemeHandler;
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
    if (self.isAsyncLoadImg) {
        [self changeImageScheme];
    }
    [self addHtmlLab];
    [self addGetAllImgScript];
    [self addImgClickScript];
    [self addUpdateImgScript];
}

- (void)startLoadHTMLString {
    
    if (!self.xxxHtmlString) {
        return;
    }
    self.schemeHandler.imgUrlDict = self.imageUrlDict;
    self.schemeHandler.placeholderImage = self.placeholderImage;
    [self.webView loadHTMLString:self.xxxHtmlString baseURL:nil];
}


- (void)changeImageScheme {
  
    NSData  *data = [self.xxxHtmlString dataUsingEncoding:NSUTF8StringEncoding];
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData:data];
    NSArray *list = [doc searchWithXPathQuery:@"//img"];
    for (TFHppleElement * element in list) {
        NSString *oriImageUrl = element.attributes[@"src"];
        NSString *oriImageUrlScheme = [NSURL URLWithString:oriImageUrl].scheme;
        NSString *newImageUrl = [oriImageUrl stringByReplacingOccurrencesOfString:oriImageUrlScheme withString:XXXCustomImageScheme];
        self.xxxHtmlString = [self.xxxHtmlString stringByReplacingOccurrencesOfString:oriImageUrl withString:newImageUrl];
        self.imageUrlDict[newImageUrl] = oriImageUrl;
    }
}

- (void)addHtmlLab {
    
    if (![self.xxxHtmlString containsString:@"<body>"]) {
        self.xxxHtmlString = [NSString stringWithFormat:@"<body><div>%@</div></body>",self.xxxHtmlString];
    }else{
        self.xxxHtmlString = [self.xxxHtmlString stringByReplacingOccurrencesOfString:@"<body>" withString:[NSString stringWithFormat:@"<body> <div>"]];
        self.xxxHtmlString = [self.xxxHtmlString stringByReplacingOccurrencesOfString:@"</body>" withString:[NSString stringWithFormat:@"<div> </body>"]];
    }
    
    if (![self.xxxHtmlString containsString:@"<html>"]) {
        self.xxxHtmlString = [NSString stringWithFormat:@"<html><head><meta charset=\"utf-8\" content='width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=no,minimum-scale=1.0'name='viewport'><style>img{width: 100%%;height: auto;}</style></head>%@</html>",self.xxxHtmlString];
    }
    
}

- (void)addGetAllImgScript {


    NSString *scriptLab1 = @"</script>";
    
    NSString *jsFunctionString = @"var allImgElmentList = new Array();var allImgSrcUrlList = new Array();!(function xxxGetAllImg() {var es = document.getElementsByTagName(\"img\");allImgElmentList = Array.from(es);for (let item of allImgElmentList) {allImgSrcUrlList.push(item.src)}})();";
    
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
    
    NSString *jsFunctionString = @"function xxxUpdateImage(url, imgData) {for (let item of allImgElmentList) {if (item.src == url) {item.src = imgData;break;}}};";
    
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
    NSString *jsFunctionString = [NSString stringWithFormat:@"function xxxIsATag(element) {if (element.constructor == HTMLAnchorElement) { var a = new Object(); a.isA = true; a.url = element; return a; } else if (element.parentElement != null) { return xxxIsATag(element.parentElement); } else { var a = new Object(); a.isA = false;a.url = \"\"; return a;}}; !(function xxxAddClick() { var list = allImgElmentList; list.forEach((element, index) => { element.onclick = function () { var imgSrc = element.src; var a = xxxIsATag(element); window.location.href = `%@://?isA=${a.isA}&aUrl=${a.url}&imgSrc=${imgSrc}&imgUrl=${allImgSrcUrlList[index]}`;};});})();",XXXCustomImageScheme];
  
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


- (void)getWebViewContentHeight:(void(^)(CGFloat height))compledBlock {
    if (!compledBlock) {
        return;
    }
    [self.webView evaluateJavaScript:@"document.body.children[0].offsetHeight" completionHandler:^(id _Nullable result,NSError * _Nullable error) {
        // 高度会有一点少  ，手动补上一些 margin
        CGFloat height = [result floatValue] + 20.0;
        compledBlock(height);
    }];
}


- (void)updateHeight {
    [self nowUpdateHeight];
    [self delayUpdateHeight];
}

- (void)nowUpdateHeight {
    __weak typeof(self) weakSelf = self;
    [self getWebViewContentHeight:^(CGFloat height) {
        if (weakSelf.loadOverHeight) {
            weakSelf.loadOverHeight(height);
        }
    }];
}

- (void)delayUpdateHeight {
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, self.delayTime * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [weakSelf nowUpdateHeight];
    });
}


- (BOOL)isCustomScheme:(WKNavigationAction *)navigationAction {
    NSURL *url = navigationAction.request.URL;
    NSString *scheme = [url scheme];
    if ([scheme isEqualToString:XXXCustomImageScheme]) {
        return YES;
    }
    return NO;
}

- (void)customScheme:(WKNavigationAction *)navigationAction imgClick:( void(^)(NSString *imgUrl,  UIImage * _Nullable image))imgClickBlock; {
  
    if (!imgClickBlock) {
        return ;
    }
  
    BOOL isClickImage = [self isCustomScheme:navigationAction];
  
    if (isClickImage) {
        NSURL *url = navigationAction.request.URL;
        NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
        NSString *imgUrl;
        UIImage *image;
      for (NSURLQueryItem *item in urlComponents.queryItems) {
          if ([item.name isEqualToString:@"imgSrc"]) {
              if (self.isAsyncLoadImg && ![item.value containsString:XXXCustomImageScheme]) {
                  NSString *base64String = [item.value stringByReplacingOccurrencesOfString:@"data:image/png;base64," withString:@""];
                  NSData *imgData = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
                  image = [UIImage imageWithData:imgData];
              }
            }else if ([item.name isEqualToString:@"imgUrl"]){
                if ([item.value containsString:XXXCustomImageScheme]) {
                    imgUrl = self.imageUrlDict[item.value];
                }else{
                    imgUrl = item.value;
                }
            }
        }
        imgClickBlock(imgUrl,image);
    }
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

- (NSString *)xxx_base64EncodedString {
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

