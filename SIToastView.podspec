Pod::Spec.new do |s|
  s.name     = 'SIToastView'
  s.version  = '0.1'
  s.platform = :ios
  s.license  = 'MIT'
  s.summary  = 'Another toast view.'
  s.homepage = 'https://github.com/Sumi-Interactive/SIToastView'
  s.author   = { 'Sumi Interactive' => 'developer@sumi-sumi.com' }
  s.source   = { :git => 'https://github.com/Sumi-Interactive/SIToastView.git',
                 :tag => '0.1' }

  s.description = 'Another toast view.'

  s.requires_arc = true
  s.framework    = 'QuartzCore'
  s.source_files = 'SIToastView/*.{h,m}'
  s.dependency 'SISecondaryWindowRootViewController', '~> 0.1'
end
