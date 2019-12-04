#
# Be sure to run `pod lib lint SDRemoteImageView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SDRemoteImageView'
  s.version          = '0.4.0'
  s.summary          = 'Fetch image from Remote server, downsample it, and display it'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'UIImageView subclass that fetches image from Remote server, downsample it, and display it'

  s.homepage         = 'https://github.com/e-sung/SDRemoteImageView'
  s.screenshots     = 'https://github.com/e-sung/SDRemoteImageView/blob/master/demo.gif?raw=true'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'e-sung' => 'dev.esung@gmail.com' }
  s.source           = { :git => 'https://github.com/e-sung/SDRemoteImageView.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/sungdooyoo'

  s.ios.deployment_target = '8.0'

  s.swift_versions = ['5.0', '5.1']
  s.source_files = 'SDRemoteImageView/Classes/**/*'
  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
end
