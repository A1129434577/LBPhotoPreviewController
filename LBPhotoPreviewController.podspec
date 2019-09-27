Pod::Spec.new do |spec|
  spec.name         = "LBPhotoPreviewController"
  spec.version      = "0.0.1"
  spec.summary      = "支持本地图片和网络图片的图片浏览器。"
  spec.description  = "一个既支持本地图片也支持网络图片，代码极简单，极易集成的图片浏览器。。"
  spec.homepage     = "https://github.com/A1129434577/LBPhotoPreviewController"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "刘彬" => "1129434577@qq.com" }
  spec.platform     = :ios
  spec.ios.deployment_target = '8.0'
  spec.source       = { :git => 'https://github.com/A1129434577/LBPhotoPreviewController.git', :tag => spec.version.to_s }
  spec.dependency     "SDWebImage"
  spec.dependency     "LBReusableScrollView"
  spec.source_files = "LBPhotoPreviewController/**/*.{h,m}"
  spec.resource      = "LBPhotoPreviewController/**/*.png"
  spec.requires_arc = true
end
#--use-libraries
