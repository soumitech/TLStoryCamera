Pod::Spec.new do |s|

  s.name         = 'TLStoryCameraFramework'
  s.version      = '0.0.1'
  s.summary      = 'You can put up picture, text or doodle after shooting a video. just like the app Instagram and Weibo \'s story'
  s.license      = 'MIT'
  s.homepage     = 'https://github.com/soumitech/TLStoryCamera'
  s.author       = { 'Andrea Bizzotto' => 'bizz84@gmail.com' }
  s.ios.deployment_target = '8.0'
  s.source       = { :git => "https://github.com/soumitech/TLStoryCamera.git", :tag => s.version }
  s.source_files = 'TLStoryCameraFramework/TLStoryCameraFramework/**/*.{swift,h,m}'
  s.swift_version = '4.2'
  s.dependency 'GPUImage'
  s.dependency 'MBProgressHUD'
  s.resource = 'TLStoryCamera/TLStoryCameraResources.bundle'

end