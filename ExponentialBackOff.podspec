#
# Be sure to run `pod lib lint ExponentialBackOff.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "ExponentialBackOff"
  s.version          = "1.1.1"
  s.summary          = "A framework which implements the ExponentialBackOff algorithm which is usefull for Networking."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
This framework implements the ExponentialBackOff algorithm which you can use for Networking or other tasks which should be retried after some time without worrying about how long you have to wait for the next attempt.
Google mentioned this algorithm to be used to request a GCM token. In Java they implemented this in their java api repository but for iOS and OSX developers this is the right framework.
I tried to put more features into this pod than simple a lame algorithm without much more.
For example you just have to pass your code as a closure or by implementing a Protocol and passing the class to one of the methods. You don't have to worry about waiting the right amount of time or recalling your code, the Handler makes this automatically.
You also have the option to implement your own algorithm without worrying about how to handle the automatic reattempts.
                       DESC

  s.homepage         = "https://github.com/Ybrin/ExponentialBackOff"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Ybrin" => "koray@koska.at" }
  s.source           = { :git => "https://github.com/Ybrin/ExponentialBackOff.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  # s.ios.platform     = :ios, '8.0'
  # s.osx.platform     = :osx, '10.10'
  s.osx.deployment_target = "10.15"
  s.ios.deployment_target = "12.0"
  s.tvos.deployment_target = "12.0"
  # s.watchos.deployment_target = "2.0"
  s.requires_arc = true

  s.source_files = 'ExponentialBackOff/ExponentialBackOff/**/*'
  # s.resource_bundles = {
  #   'ExponentialBackOff' => ['Pod/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'AsyncSwift', :git => 'https://github.com/duemunk/Async.git'
end
