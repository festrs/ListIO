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
    pod 'ObjectMapper'
    pod 'JSONWebToken', :git => "https://github.com/kylef/JSONWebToken.swift.git", :branch => 'master'
    pod 'Alamofire', '4.4'
    pod 'QRCodeReader.swift', :git=> "https://github.com/festrs/QRCodeReader.swift"
    pod 'StringScore_Swift', :git => "https://github.com/yichizhang/StringScore_Swift.git"
    pod 'SVProgressHUD', '~> 2.1.2'
    pod 'SwiftLint'
    pod 'Floaty', '~> 3.0.0'
    pod 'Kingfisher', '~> 3.0'
    pod 'ALCameraViewController'
    pod 'DatePickerCell'
    pod 'Fabric'
    pod 'Crashlytics'
end

target 'Prod' do
    prod_pods
end

target 'Hml' do
    prod_pods
end

target 'ListioTests' do
    prod_pods
end

