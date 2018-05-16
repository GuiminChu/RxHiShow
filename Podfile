source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'

target 'HiShow' do

    use_frameworks!

    # Pods for HiShow

    pod 'Moya/RxSwift', '~> 10.0.0-beta.1'
    pod 'RxCocoa', '~> 4.0.0-rc.0'
    pod 'Kingfisher', '~> 4.0'
    pod 'Navi', '~> 1.1'
    pod 'MJRefresh', '~> 3.1.14'
    pod 'SwiftyJSON'
    pod 'GDPerformanceView-Swift', '~> 1.2'
    pod 'Cache', '~> 4.0'

    target 'HiShowTests' do
        inherit! :search_paths
        # Pods for testing
    end

    target 'HiShowUITests' do
        inherit! :search_paths
        # Pods for testing
    end

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.0'
        end
    end
end
