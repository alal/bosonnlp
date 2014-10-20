require 'rake'

require_relative 'lib/bosonnlp/version'

Gem::Specification.new do |s|
  s.name = 'bosonnlp'
  s.version = Bosonnlp::VERSION
  s.date = '2014-10-07'
  s.authors = ['CC']
  s.email = 'chcoalc@gmail.com'
  s.homepage = 'http://github.com/alal/bosonnlp'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Bosonnlp Ruby SDK'
  s.description = 'bosonnlp.com'
  s.files = FileList['lib/*.rb', 'lib/bosonnlp/*.rb']
  s.require_path = 'lib'
  s.add_runtime_dependency 'httpclient', '~> 2.5', '>= 2.5.0'
  s.license = 'Apache'
  s.required_ruby_version = '>= 1.9'
end
