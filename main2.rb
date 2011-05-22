require 'rubygems'
require 'sinatra'

require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-migrations'

require 'rack-flash'
require 'sinatra/redirect_with_flash'

enable :sessions
use Rack::Flash, :sweep => true

#DataMapper.setup :default, "sqlite://#{Dir.pwd}/database.db"
DataMapper.setup :default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/database.db"

helpers do
	include Rack::Utils
	alias_method :h, :escape_html
end

get '/' do
	'hello world'
end