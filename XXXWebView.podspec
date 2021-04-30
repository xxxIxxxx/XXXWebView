Pod::Spec.new do |s|
  s.name = "XXXWebView"
  s.version = "1.1.0"
  s.summary = "异步加载 html 标签内的图片"
  s.homepage = "https://github.com/xxxIxxxx/XXXWebView"
  s.license = "MIT"
  s.authors = { "i2yf" => "i2yf@foxmail.com" }
  s.platform = :ios
  s.platform = :ios, "11.0"
  s.source = { :git => "https://github.com/xxxIxxxx/XXXWebView.git", :tag => s.version }
  s.source_files = "XXXWebViewDemo/XXXWebView/*.{h,m}"
  s.requires_arc = true
  s.dependency "SDWebImage"
end
