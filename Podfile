use_frameworks!
platform :osx, '10.12'
inhibit_all_warnings!

target 'vMysqlMonitoring' do
  pod 'MySqlSwiftNative', '~> 1.0.6'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    puts "#{target.name}"
  end
end