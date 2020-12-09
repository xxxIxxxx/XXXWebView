//
//  XXXWebView.h
//  XXXWebView
//
//  Created by Z on 2019/5/5.
//  Copyright © 2019 losht. All rights reserved.
//

#import <UIKit/UIKit.h>
@import  WebKit;
NS_ASSUME_NONNULL_BEGIN

@interface XXXWebView : UIView


// https://wx2.sinaimg.cn/large/006CHHsBly1gkxrs94aokj31402eob2b.jpg

///图片域名     例如-> @"https://wx2.sinaimg.cn/"  参照上面图片地址
@property (nonatomic, copy) NSString *oriImageUrl;

///图片链接 Scheme   例如->   @"https" 参照上面图片地址
@property (nonatomic, copy) NSString *oriImageScheme;

/// 占位图
@property (nonatomic, strong) UIImage *placeholderImage;

/// html 标签
@property (nonatomic, copy) NSString *htmlString;

/// 给 img 添加点击事件
- (void)addImgClickScript;


///高度刷新回调  会回调多次。如果要求 webView 的高度等于内容高度可根据此高度改变 XXXWebView 高度
@property (nonatomic, copy) void(^loadOverHeight)(CGFloat height);


/// webView
@property (nonatomic, strong, readonly) WKWebView *webView;

/// 开始加载
- (void)startLoadHTMLString;


//MARK: 以下方法只能在 navigationDelegate 代理中使用
/*
 - (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {}
 */

/// 图片点击
/// @param navigationAction navigationAction
+(BOOL)isCustomScheme:(WKNavigationAction *)navigationAction;


/// 是否是 a 标签加载事件
/// @param navigationAction navigationAction
+(BOOL)isA:(WKNavigationAction *)navigationAction;


/// img 标签点击事件
/// @param navigationAction navigationAction
/// @param oriImageScheme oriImageScheme 同上边属性
/// @param imgClickBlock imgClickBlock  ｜  isA 是否是 a 标签 ｜ aUrl a 标签的链接  |（imgUrl 图片链接，image 图片 图片加载完成是 image 否则是 imgUrl）
+(void)customScheme:(WKNavigationAction *)navigationAction oriImageScheme:(NSString *)oriImageScheme imgClick:(void(^)(BOOL isA,NSString *aUrl,NSString *imgUrl,UIImage *image))imgClickBlock;

@end













#pragma mark -
#pragma mark - WKURLSchemeHandler

@interface XXXCustomSchemeHanlder : NSObject <WKURLSchemeHandler>

@property (nonatomic, copy) NSString *oriImageUrl;
@property (nonatomic, copy) NSString *oriImageScheme;
@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, copy) void(^updateImageBlock)(void);

@end

#pragma mark -
#pragma mark - Extension

@interface UIView (copy_YYAdd)

@property (nonatomic) CGFloat left;        ///< Shortcut for frame.origin.x.
@property (nonatomic) CGFloat top;         ///< Shortcut for frame.origin.y
@property (nonatomic) CGFloat right;       ///< Shortcut for frame.origin.x + frame.size.width
@property (nonatomic) CGFloat bottom;      ///< Shortcut for frame.origin.y + frame.size.height
@property (nonatomic) CGFloat width;       ///< Shortcut for frame.size.width.
@property (nonatomic) CGFloat height;      ///< Shortcut for frame.size.height.
@property (nonatomic) CGSize  size;        ///< Shortcut for frame.size.

@end



@interface NSData (xxx)
- (NSString *)base64EncodedString;
@end


NS_ASSUME_NONNULL_END
