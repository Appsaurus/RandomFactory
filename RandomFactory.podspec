Pod::Spec.new do |s|
  s.name             = "RandomFactory"
  s.summary          = "A short description of RandomFactory."
  s.version          = "1.0.3"
  s.homepage         = "github.com/Strobocop/RandomFactory"
  s.license          = 'MIT'
  s.author           = { "Brian Strobach" => "brian@appsaurus.io" }
  s.source           = {
    :git => "https://github.com/Appsaurus/RandomFactory.git",
    :tag => s.version.to_s
  }

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.12'
  s.tvos.deployment_target = '9.2'
  s.watchos.deployment_target = '3.0'

  s.requires_arc = true
  s.ios.source_files = 'Sources/{iOS,Shared}/**/*'
  s.tvos.source_files = 'Sources/{iOS,tvOS,Shared}/**/*'
  s.osx.source_files = 'Sources/{macOS,Shared}/**/*'
  s.watchos.source_files = 'Sources/{watchOS,Shared}/**/*'

  s.dependency 'Fakery'
  s.dependency 'Avatars'
  s.dependency 'PlaceholderImages'
  s.dependency 'CodableExtensions'

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.1' }
end
