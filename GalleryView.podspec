Pod::Spec.new do |s|
    s.name             = "GalleryView"
    s.version          = "0.0.7"
    s.summary          = 'Grid View representation of your gallery.'
    s.license          = 'MIT'
    s.author           = {'Mohit' => 'mohit@appringer.com'}

    s.source           = { :git => 'https://github.com/App-Ringer/GalleryView-iOS.git', :tag => "#{s.version}" }

    s.homepage = "https://github.com/App-Ringer/GalleryView-iOS.git"


    s.ios.deployment_target = '13.0'
    s.requires_arc = true

    s.source_files = 'GalleryView-iOS', 'GalleryApp/**/*.{swift}'
    s.resources = "GalleryApp/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"

    s.frameworks = 'UIKit', 'Foundation'
    s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }
    s.swift_version = '5.0'
end
