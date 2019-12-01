Pod::Spec.new do |s|

  s.name         = "StructureKit"
  s.version      = "4.0"
  s.summary      = "Table and Collection View Structure objects"

  s.homepage     = "https://github.com/vitkuzmenko/StructureKit.git"

  s.license      = { :type => "Apache 2.0", :file => "LICENSE" }

  s.author             = { "Vitaliy" => "kuzmenko.v.u@gmail.com" }
  s.social_media_url   = "http://twitter.com/vitkuzmenko"

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'

  s.source       = { :git => s.homepage, :tag => s.version.to_s }

  s.source_files  = "Source/**/*.swift"
  
  s.requires_arc = 'true'

end
