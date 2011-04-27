require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-migrations'

DataMapper.setup :default, "sqlite://#{Dir.pwd}/database.db"

class Question
	include DataMapper::Resource
	
	property :id, Serial
	property :text, String, length: 1..140, required: true
	property :approved, Boolean, default: false
	
	property :created_at, DateTime
	property :updated_at, DateTime
	
	has n, :answers
end

class Answer
	include DataMapper::Resource
	
	property :id, Serial
	property :username, String, length: 0..20
	property :answer, String, length: 1..140, required: true
	property :thumbsUp, Integer, default: 0
	property :thumbsDown, Integer, default: 0
	property :approved, Boolean, default: false
	
	property :created_at, DateTime
	property :updated_at, DateTime
	
	belongs_to :question
	
	def getRating
		thumbsUp - thumbsDown
	end
end

DataMapper.auto_upgrade!