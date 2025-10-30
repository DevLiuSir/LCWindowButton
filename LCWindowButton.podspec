Pod::Spec.new do |spec|

  spec.name           = "LCWindowButton"
  
  spec.version        = "1.0.2"
  
  spec.summary        = "Customize the frame of NSWindow's zoom in, close, zoom out, and full screen buttons!"
  
  spec.description    = <<-DESC
              A framework for customizing NSWindow's zoom in, close, zoom out, and full screen buttons!
                   DESC

  spec.homepage       = "https://github.com/DevLiuSir/LCWindowButton"
  
  spec.license        = { :type => "MIT", :file => "LICENSE" }
  
  spec.author         = { "Marvin" => "93428739@qq.com" }
  
  spec.swift_versions = ['5.0']

  spec.platform       = :osx

  spec.osx.deployment_target  = "10.15"

  spec.source         = { :git => "https://github.com/DevLiuSir/LCWindowButton.git", :tag => "#{spec.version}" }

  spec.source_files   = "Sources/LCWindowButton/**/*.{h,m,swift}"

end
