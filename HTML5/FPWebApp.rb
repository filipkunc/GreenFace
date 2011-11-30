require 'rubygems'
require 'sinatra'
require 'json'
require 'base64'

class FPWebApp < Sinatra::Base
  set :root, File.dirname(__FILE__)

  get '/' do
		@levels = []
	
		dir = Dir.new(File.dirname(__FILE__) + "/public/Levels");
		dir.each do |entry|
      if File.extname(entry) == '.xml'
				@levels << File.basename(entry, '.xml')
      end
		end

    erb :home
  end

	get '/leveleditor' do
		levelParam = params["level"]
		redirect "/leveleditor.html?level=#{levelParam}.xml"
	end

	get '/game/level/*.xml' do |name|
		redirect "/game.html?level=#{name}.xml"
	end
	
	post '/Levels/*.xml' do |name|
		File.open(File.dirname(__FILE__) + "/public/Levels/#{name}.xml", 'w') { |f| f.write request.body.read }		
	end
	
	post '/Screenshots/*.xml' do |name|
		
		str = request.body.read
		
		imageHeader = "data:image/png;base64," 
		
		str = str[imageHeader.length..str.length]
		
		decoded = Base64.decode64(str)
		
		File.open(File.dirname(__FILE__) + "/public/Screenshots/#{name}.png", 'w') { |f| f.write decoded }
	end

end

FPWebApp.run!