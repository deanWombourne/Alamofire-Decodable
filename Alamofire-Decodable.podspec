#
# Be sure to run `pod lib lint Alamofire-Decodable.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Alamofire-Decodable'
  s.version          = '1.0.1'
  s.summary          = 'A trivial method added to alamofire to automagically decode responses using Decodable'
  s.description      = <<-DESC

This pod adds the `responseDecodable` method to Alamofire's Request object to return model objects instead of just json.'. This pod basically just removes some boilerplate from your apps.

                       DESC

  s.homepage         = 'https://github.com/deanWombourne/Alamofire-Decodable'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Sam Dean' => 'deanWombourne@gmail.com' }
  s.source           = { :git => 'https://github.com/deanWombourne/Alamofire-Decodable.git', :tag => 'v' + s.version.to_s }
  s.social_media_url = 'https://twitter.com/deanWombourne'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Alamofire-Decodable/Classes/**/*'
  
  s.dependency 'Alamofire', '~> 3.3'
  s.dependency 'Decodable', '~> 0.4.2'

end
