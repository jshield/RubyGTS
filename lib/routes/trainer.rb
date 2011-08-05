get "/trainer/:t/pokemon/:p/send" do
  auth
  @pkm = @trainer.monsters.first(:id=>params[:p])
  redirect @trainer.profile if @pkm.nil?
  @pkm.queue = true
  @pkm.save
  redirect @pkm.url
end

get "/trainer/:t/pokemon/:p/give/:n" do
  auth
  @pkm = @trainer.monsters.first(:id=>params[:p])
  halt unless @trainer.id == @pkm.trainer.id
  redirect @trainer.profile if @pkm.nil?
  @pkm.trainer = Trainer.first(:id=>params[:n])
  @pkm.save
  redirect @pkm.url
end

get "/trainer/switch/:n" do
  auth
  @user.ctid = params[:n] unless @user.trainers.first(params[:n]).nil?
  @user.save
  redirect @user.current.profile
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
  redirect monster.url
end

get "/trainer/pokemon/:p/download" do
  auth
  @monster = Monster.get(params[:p])
  redirect @monster.url unless @monster.trainer.id == @trainer.id
  content_type "application/octet-stream"
  attachment "#{@monster.trainer.id}-#{@monster.structure.name}.pkm"
  @monster.blob[0..235]
end

get "/trainer/:t/profile" do
  @trainer = Trainer.first(:id=>params[:t])
  return haml :profile
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
  redirect @registrant.profile
end

get "/trainer/:t/pokemon/:p" do  
  @pkm = Trainer.first(:id=>params[:t]).monsters.first(:id=>params[:p])
#  if @pkm.trainer.id == @trainer.id
#    haml :pokeedit
#  else
    haml :pokemon
#  end
end

get "/trainer/:t/pokemon/:p/delete" do
  auth
  @pkm = @trainer.monsters.first(:id=>params[:p])
  if @trainer.id == @pkm.trainer.id
    @pkm.destroy
  end
  redirect @trainer.profile
end
