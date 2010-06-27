begin
  require 'spec'
rescue LoadError
  require 'rubygems' unless ENV['NO_RUBYGEMS']
  gem 'rspec'
  require 'spec'
end

require 'logger'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'resin'
