
Pod::Spec.new do |s|
  s.name         = "RNUserNotification"
  s.version      = "1.0.0"
  s.summary      = "RNUserNotification"
  s.description  = <<-DESC
                  RNUserNotification
                   DESC
  s.homepage     = ""
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "author" => "dev@clozr.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/clozr/react-native-user-notification.git", :tag => "master" }
  s.source_files  = "RNUserNotification/**/*.{h,m}"
  s.requires_arc = true


  s.dependency "React"
  #s.dependency "others"

end

  
