# Uncomment this line to define a global platform for your project
platform :ios, '9.0'
# Uncomment this line if you're using Swift
use_frameworks!
# ignore all warnings from all pods
inhibit_all_warnings!

def prod_pods
    plugin 'cocoapods-keys', {
        :project => "Listio",
        :keys => [
        "ListioAPISecret"
        ]}

    pod 'ObjectMapper+Realm'
    pod 'RealmSwift'
    pod 'ObjectMapper', '~> 3.1'
    pod 'JSONWebToken'
    pod 'Alamofire', '4.4'
    pod 'QRCodeReader.swift', :git=> "https://github.com/festrs/QRCodeReader.swift"
    pod 'StringScore_Swift'
    pod 'SVProgressHUD', '~> 2.1.2'
    pod 'SwiftLint'
    pod 'Floaty', '~> 4.0.0'
    pod 'Kingfisher', '~> 4.0'
    pod 'ALCameraViewController'
    pod 'DatePickerCell'
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'SnapKit', '~> 4.0.0'
end

target 'Prod' do
    prod_pods
end

target 'AppFramework' do
    prod_pods
end

target 'ListioTests' do
    prod_pods
end

swift_32 = ['QRCodeReader.swift']

post_install do |installer|
    installer.pods_project.targets.each do |target|
        swift_version = nil

        if swift_32.include?(target.name)
            swift_version = '3.2'
        end

        if swift_version
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = swift_version
            end
        end
    end
end
