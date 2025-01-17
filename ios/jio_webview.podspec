#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint jio_webview.podspec` to validate before publishing.
# cocoapod - https://cocoapods.org/owners/95842
# pod - https://cocoapods.org/pods/jio_webview
#
Pod::Spec.new do |s|
  s.name             = 'jio_webview'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin project for webview using platform view.'
  s.description      = <<-DESC
Flutter plugin to display the native webView using native bridge method channel and platform view and allow controller to interact with webview and play with javascript.
                       DESC
  s.homepage         = 'https://github.com/jiocoders/jio_webview/'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Jiocoders' => 'jiocoders@gmail.com' }
#   s.source           = { :path => '.' }
  s.source           = { :git => 'https://github.com/jiocoders/jio_webview.git', :tag => s.version.to_s }
#   s.source_files = 'Classes/**/*'
  s.source_files  = 'lib/**/*.{dart}'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'jio_webview_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
