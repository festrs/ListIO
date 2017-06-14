# Uncomment this line to define a global platform for your project
platform :ios, '9.0'
# Uncomment this line if you're using Swift
use_frameworks!

target 'Listio' do
    
    plugin 'cocoapods-keys', {
        :project => "Listio",
        :keys => [
        "ListioAPISecret"
        ]}
    
    pod 'JSONWebToken', :git => "https://github.com/kylef/JSONWebToken.swift.git", :branch => 'master'
	pod 'Alamofire', '~> 4.4'
	pod 'QRCodeReader.swift', '~> 7.3.0'
    pod 'DATAStack', '~> 6'
    pod 'Bugsnag', :git => "https://github.com/bugsnag/bugsnag-cocoa.git"
    pod 'StringScore_Swift', :git => "https://github.com/yichizhang/StringScore_Swift.git"
    pod 'Sync', '~> 2'
    pod 'AIFlatSwitch', '~> 1.0.1'
    pod 'SVProgressHUD', '~> 2.1.2'
    pod 'SwiftLint'
    pod 'Floaty', '~> 3.0.0'
    pod 'BarcodeScanner', :git => "https://github.com/festrs/BarcodeScanner.git"
end

target 'ListioTests' do
    pod 'JSONWebToken', :git => "https://github.com/kylef/JSONWebToken.swift.git", :branch => 'master'
    pod 'Alamofire', '~> 4.4'
    pod 'QRCodeReader.swift', '~> 7.3.0'
    pod 'DATAStack', '~> 6'
    pod 'Bugsnag', :git => "https://github.com/bugsnag/bugsnag-cocoa.git"
    pod 'StringScore_Swift', :git => "https://github.com/yichizhang/StringScore_Swift.git"
    pod 'Sync', '~> 2'
    pod 'AIFlatSwitch', '~> 1.0.1'
    pod 'MockUIAlertController', '~> 2.0'
end

