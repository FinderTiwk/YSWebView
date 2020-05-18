Pod::Spec.new do |spec|
  spec.name         = "YSWebView"
  spec.version      = "0.0.1"
  spec.summary      = "YSWebView"
  spec.description  = <<-DESC
                      Hbrid解决方案
                      DESC
  spec.homepage     = "404.com"
  spec.license      = 'GPL'
  spec.author       = { "_Finder丶Tiwk" => "136652711@qq.com" }
  spec.source = { :git => 'git@github.com:FinderTiwk/YSWebView.git'}

  spec.platform = :ios, '9.0'
  spec.requires_arc = true

  spec.resource = 'YSWebView/YSWebView.bundle'
  spec.source_files = 'YSWebView/**/*.{h,m}'
  spec.public_header_files = 'YSWebView.h','SRC/YSWebViewOption.h','SRC/YSWebViewController.h','SRC/YSWebViewAppearance.h'

end


