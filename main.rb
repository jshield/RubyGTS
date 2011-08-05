#!/usr/bin/env ruby
require "openssl"
require "./common"
set :port, GTS.port
set :server, %w[unicorn mongrel thin webrick]
enable :sessions
include Koala

helpers do

  def pidgenhash(pid)
    return Digest::SHA1.hexdigest(pid) 
  end

  def saverawpkmr(pkm,b64=false)
    pkm = Base64.decode64(pkm.gsub("-","+").gsub("_","/")) if b64 == true
    pkme = GTSCrypt.new pkm
    data = pkme.decrypt
    return data[4..data.size].to_s
  end
  
  def auth
    redirect "/fb/login" if @user.nil?
  end
  
  def logout
    session['oauth'] = nil
    session['access_token'] = nil
    redirect '/fb/login'
  end
  
  def auth?
    return true unless @user.nil?
    return false
  end
  
end

before do
  if session['access_token']
    @graph = Facebook::GraphAPI.new(session['access_token'])
    @profile = @graph.get_object("me") rescue logout
    @user = User.first_or_create(:fbid => @profile["id"])
    @user.name = @profile["name"]
    @user.fbat = session['access_token']
    @user.save
    @trainer = @user.current unless @user.current.nil?
    end
  unless params[:t].nil?
    @trainer = Trainer.first(:tid=>params[:t]) if @trainer.nil?
  else
    @trainer = Trainer.first(:id=>session[:pid]) if @trainer.nil?
  end  
end

before "/pokemondpds/*" do
  session[:pid] = params[:pid] unless params[:pid].nil?
  @trainer = Trainer.first_or_create(:id=>session[:pid])
  @trainer.user_id = User.first(:name=>"Pokemon Keeper").id if @trainer.user_id.nil?   
  halt pidgenhash(session[:pid])[0,32] unless params[:hash]
  unless @trainer.user.fbat.nil?
    @graph = Facebook::GraphAPI.new(@trainer.user.fbat)
    @profile = @graph.get_object("me") 
  end
end

before "/syachi2ds/web/*" do
  session[:pid] = params[:pid] unless params[:pid].nil?
  @trainer = Trainer.first_or_create(:id=>session[:pid], :gen => 5)
  @trainer.user_id = User.first(:name=>"Pokemon Keeper").id if @trainer.user_id.nil?   
  halt pidgenhash(session[:pid])[0,32] unless params[:hash]  
  unless @trainer.user.fbat.nil?
    @graph = Facebook::GraphAPI.new(@trainer.user.fbat)
    @profile = @graph.get_object("me") 
  end
end

get "/css/:css" do
  sass params[:css].to_sym
end

get "/" do
  haml :index
end

get '/new' do
  haml :newindex
end