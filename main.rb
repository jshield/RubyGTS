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
    @trainer = @user.trainers.first(:id=>@user.ctid) unless @user.ctid.nil?
    end
  if request.path_info =~ %r{/pokemondpds/}
    session[:pid] = params[:pid] unless params[:pid].nil?
    @trainer = Trainer.first_or_create(:id=>session[:pid])
    @trainer.user_id = User.first(:name=>"Pokemon Keeper").id if @trainer.user_id.nil?   
    halt pidgenhash(session[:pid])[0,32] unless params[:hash]
    unless @trainer.user.fbat.nil?
      @graph = Facebook::GraphAPI.new(@trainer.user.fbat)
      @profile = @graph.get_object("me") 
    end
  end
  unless params[:t].nil?
    @trainer = Trainer.first(:tid=>params[:t]) if @trainer.nil?
  else
    @trainer = Trainer.first(:id=>session[:pid]) if @trainer.nil?
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

get "/system/search/:model" do
  Kernel.const_get(params[:model].capitalize).all(:name.like=>"%#{params[:term]}%").to_json
end

get "/trainer/:t/profile" do
  @trainer = Trainer.first(:id=>params[:t])
  return haml :profile unless @trainer.name.nil?
  haml :fpupdate
end

get "/trainer/:t/profile/update" do
  auth
  haml :fpupdate
end

get "/trainer/register" do
  auth
  haml :trreg
end

post "/trainer/register" do
  auth
  @registrant = Trainer.first(:tid=>params[:tid])
  halt "Trainer Not Found" if @registrant.nil?
  halt "Trainer already registered" if @registrant.reg  
  @monster = @registrant.monsters.first
  halt "How the hell? It seems that you have not uploaded a pokemon yet you have trainer data on the server" if @monster.nil? 
  if @monster.structure.nature.name == params[:nature] && @monster.structure.level == params[:level].to_i
    @registrant.user = @user
    if @user.ctid.nil?
      @user.ctid = @registrant.id
      @user.save
    end
    @registrant.reg = true        
    @registrant.save   
  else
    halt "Pokemon data did not match"
  end
  @graph.put_wall_post("just registered #{@registrant.name} on the GTS Server","link"=>GTS.url+"trainer/#{registrant.id}/profile");
  redirect "/trainer/#{@registrant.id}/profile"
end

post "/trainer/:t/profile" do
  auth
  @trainer.name = params[:name]
  @trainer.pass = params[:pass] unless params[:pass].nil?
  @trainer.save
  redirect "/trainer/#{@trainer.id}/profile"
end

get "/trainer/:t/pokemon/:p" do  
  @pkm = Trainer.first(:id=>params[:t]).monsters.first(:id=>params[:p])
  if @pkm.trainer.id == @trainer.id
    haml :pokeedit
  else
    haml :pokemon
  end
end

get "/trainer/:t/pokemon/:p/delete" do
  auth
  @pkm = @trainer.monsters.first(:id=>params[:p])
  if @trainer.id == @pkm.trainer.id
    @pkm.destroy
  end
  redirect "/trainer/#{@trainer.id}/profile"
end

post "/system/pokemon/:p/ev" do
  auth
  monster = Monster.get(params[:p])
  halt unless @trainer.id == monster.trainer.id
  poke = monster.structure
  evs = poke.evs
  evs[params[:n].to_i] = params[:v].to_i unless params[:v].to_i > 255 or params[:v].to_i < 0
  poke.evs = evs
  monster.structure = poke
  monster.save
  total = 0
  evs.each do |ev|
    total += ev
  end
  total.to_s
end

post "/system/pokemon/:p/iv" do
  auth
  monster = Monster.get(params[:p])
  halt unless @trainer.id == monster.trainer.id
  poke = monster.structure
  ivs = poke.ivs
  ivs[params[:n].to_i] = params[:v].to_i unless params[:v].to_i > 31 or params[:v].to_i < 0
  poke.ivs = ivs
  monster.structure = poke
  monster.save
  total = 0
  ivs.each do |iv|
    total += iv
  end
  total.to_s
end

post "/system/pokemon/:p/move" do
  auth
  monster = Monster.get(params[:p])
  halt unless @trainer.id == monster.trainer.id
  poke = monster.structure
  moves = poke.moves
  moves[params[:n].to_i] = params[:v].to_i
  poke.moves = moves
  monster.structure = poke
  monster.save
end

post "/system/pokemon/:p/edit" do
  monster = Monster.get(params[:p])
  halt unless @trainer.id == monster.trainer.id
  poke = monster.structure
  begin
  m = poke.method(params[:m]+"=")
  rescue NameError
  halt "no such method called #{params[:m]}"
  end
  m.call(params[:v])
  monster.structure = poke
  monster.save
  "success"
end

get "/system/ui/auto/pokemon" do
  haml :pokenew
end

get "/trainer/:t/pokemon/:p/send" do
  auth
  @pkm = @trainer.monsters.first(:id=>params[:p])
  redirect "/trainer/#{@trainer.id}/profile" if @pkm.nil?
  @pkm.queue = true
  @pkm.save
  redirect "/trainer/#{@pkm.trainer.id}/pokemon/#{@pkm.id}"
end

get "/trainer/:t/pokemon/:p/give/:n" do
  auth
  @pkm = @trainer.monsters.first(:id=>params[:p])
  halt unless @trainer.id == @pkm.trainer.id
  redirect "/trainer/#{@trainer.id}/profile" if @pkm.nil?
  @pkm.trainer = Trainer.first(:id=>params[:n])
  @pkm.save
  redirect "/trainer/#{@pkm.trainer.id}/pokemon/#{@pkm.id}"
end

get "/trainer/switch/:n" do
  auth
  @user.ctid = params[:n] unless @user.trainers.first(params[:n]).nil?
end

get "/trainer/login" do
  haml :flogin
end

get "/trainer/logout" do
  session[:pid] = nil
  redirect "/"
end

get "/trainer/pokemon/upload" do
  haml :fpkmupload
end
 
post "/trainer/pokemon/upload" do
  auth
  monster = @trainer.monsters.new
  pkm = params[:file][:tempfile].read()
  pkm << open("./extra").read() if pkm.size == 236
  monster.blob = pkm
  monster.save
  redirect "/trainer/#{@trainer.id}/pokemon/#{monster.id}"
end

get "/trainer/pokemon/:p/download" do
  auth
  @monster = Monster.get(params[:p])
  redirect "/trainer/#{@monster.trainer.id}/pokemon/#{@monster.id}" unless @monster.trainer.id == @trainer.id
  content_type "application/octet-stream"
  attachment "#{@monster.trainer.id}-#{@monster.structure.name}.pkm"
  @monster.blob[0..235]
end
