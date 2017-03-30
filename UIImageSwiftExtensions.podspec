
Pod::Spec.new do |s|
  s.name             = "UIImageSwiftExtensions"
  s.version          = "3.1"
  s.summary          = "A Swift 3 port of Trevor Harmon UIImage's extensions (http://vocaro.com/trevor/blog/2009/10/12/resize-a-uiimage-the-right-way/)"
  s.description      = <<-DESC
                       A Swift 3 port of Trevor Harmon UIImage's extensions (see: http://vocaro.com/trevor/blog/2009/10/12/resize-a-uiimage-the-right-way/).
                       DESC
  s.homepage         = "https://github.com/giacgbj/UIImageSwiftExtensions"

  s.license          = 'MIT'
  s.author           = { "Giacomo Boccardo" => "gboccard@gmail.com" }
  s.source           = { :git => "https://github.com/giacgbj/UIImageSwiftExtensions.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/jhack'

  s.platform     = :ios, '8.0'
  
  s.requires_arc = true

  s.source_files = 'Source/*.swift'
end
