
Pod::Spec.new do |s|
  s.name             = "UIImage-Swift-Extensions"
  s.version          = "1.0"
  s.summary          = "A Swift port of Trevor Harmon UIImage's extensions (http://vocaro.com/trevor/blog/2009/10/12/resize-a-uiimage-the-right-way/)"
  s.description      = <<-DESC
                       A Swift port of Trevor Harmon UIImage's extensions (see: http://vocaro.com/trevor/blog/2009/10/12/resize-a-uiimage-the-right-way/)
                       DESC
  s.homepage         = "https://github.com/giacgbj/UIImage-Swift-Extensions"

  s.license          = 'MIT'
  s.author           = { "Giacomo Boccardo" => "gboccard@gmail.com" }
  s.source           = { :git => "https://github.com/giacgbj/UIImage-Swift-Extensions.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/jhack'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = '*.swift'
end
