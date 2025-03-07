Pod::Spec.new do |s|
  s.name = "talkplus-webrtc-ios"
  s.version = "1.0.0"
  s.summary = "WebRTC SDK for TalkPlus"
  s.license = {
    :type => 'MIT',
    :text => 'Neptune Company. All rights Reserved.'
  }
  s.author = "Neptune Company"
  s.homepage = "https://www.klat.kr"
  s.description = "WebRTC SDK for Klat"
  s.source = { :git => 'https://github.com/neptunez-dev/talkplus-webrtc-ios-release.git', :tag => s.version.to_s }
  s.ios.deployment_target = '12.0'
  s.ios.vendored_framework = 'ios/TalkPlusWebRTC.xcframework'
  s.dependency 'talkplus-ios', '1.0.2' 
  s.dependency 'WebRTC-lib', '123.0.0'
end
