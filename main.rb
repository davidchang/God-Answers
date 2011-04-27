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

helpers do
	include Rack::Utils
	alias_method :h, :escape_html
end

get '/' do
	@questions = Question.all
	@title = 'God Answers'
	erb :home
end

get '/askQuestion' do
	@title = 'God Answers | Ask a Question'
	erb :askQuestion
end

post '/askQuestion' do
	q = Question.new
	q.text = params[:question]
	if q.save
		redirect '/', :notice => 'Question successfully submitted. Awaiting approval.'
	else
		redirect '/askQuestion', :error => "You found a bug(!) trying to submit the following question: " + params[:question]
	end
end

post '/feedback' do
	answerid = params[:aid]
	type = params[:t]
	
	a = Answer.get(answerid)
	
	if a;
		if type == 'y'
			a.thumbsUp = a.thumbsUp + 1
		elsif type == 'n'
			a.thumbsDown = a.thumbsDown + 1
		end

		if a.save
			'1'
		else
			'0'
		end
	else;
		'0'
	end;
end

get '/:id' do
	@question = Question.get params[:id]
	@answers = Answer.all question_id: params[:id]
	@title = 'God Answers | ' + @question.text
	
	if @question
		erb :singleQuestion
	else
		redirect '/', :error => "Sorry, but the question requested does not exist."
	end
end

post '/:id' do
	a = Answer.new
	if params[:name]
		a.username = params[:name]
	end
	a.answer = params[:answer]
	a.question_id = params[:qid]
	if a.save
		redirect "/" + params[:id], :notice => 'Answer successfully submitted. Awaiting approval.'
	else
		redirect "/" + params[:id], :error => "You found a bug(!) trying to submit the following answer: " + params[:answer]
	end
end