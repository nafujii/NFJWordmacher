Pod::Spec.new do |s|
s.name         = 'NFJWordmatcher'
s.version      = '1.0.0'
s.license      = { :type => 'MIT' }
s.homepage     = 'https://github.com/naokif/NFJWordmatcher'
s.authors      = { 'Naoki Fujii' => 'dev@nfujii.com' }

# Source Info
s.platform     =  :ios, '7.0'
s.source       = { :git => 'https://github.com/naokif/NFJWordmatcher.git',
:tag => 'v1.0.0' }
s.source_files = 'NFJWordmatcher/*.{h,m}'
s.requires_arc = true
end