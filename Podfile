# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

target 'RecipeApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for RecipeApp
  # Reactive Programming
  pod 'RxSwift', '~> 6.5.0'
  pod 'RxCocoa', '~> 6.5.0'
  
  # Dependency Injection
  pod 'Swinject', '~> 2.8.0'
  
  # Image Loading
  pod 'Kingfisher', '~> 7.0'
  
  # Networking
  pod 'Alamofire', '~> 5.6'

  target 'RecipeAppTests' do
    inherit! :search_paths
    # Pods for testing
    # Test dependencies
    pod 'RxTest', '~> 6.5.0'
    pod 'RxBlocking', '~> 6.5.0'
  end

  target 'RecipeAppUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
    end
  end
end

