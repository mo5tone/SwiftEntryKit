#
# Be sure to run `pod lib lint SwiftEntryKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name = 'SwiftEntryKit'
  s.version = '2.0.0' # x-release-please-version
  s.summary = 'A simple banner and pop-up displayer for iOS. Written in Swift.'
  s.platform = :ios
  s.ios.deployment_target = '15.0'
  s.swift_version = '5.10'
  s.requires_arc = true

s.description      = <<-DESC
SwiftEntryKit is a banner presenter library for iOS. It can be used to easily display pop-ups and notification-like views within your iOS apps. SwiftEntryKit is highly customizable but also offers a bunch of beautiful presets that can be themed with your app fonts and colors.

This podspec belongs to the community-maintained fork at https://github.com/mo5tone/SwiftEntryKit. Upstream is not published to CocoaPods trunk; consume this fork via `pod 'SwiftEntryKit', :git => 'https://github.com/mo5tone/SwiftEntryKit.git'`.
DESC
  s.homepage         = 'https://github.com/mo5tone/SwiftEntryKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Daniel Huri' => 'huri000@gmail.com', 'Jiefu Men' => 'menjiefu@gmail.com' }
  s.source           = { :git => 'https://github.com/mo5tone/SwiftEntryKit.git', :tag => s.version.to_s }
  s.source_files = 'Source/**/*'
  s.frameworks = 'UIKit'
end
