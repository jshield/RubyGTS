get "/pokemondpds/common/setProfile.asp" do
  return ("\x00"*8).to_s
end

get "/pokemondpds/worldexchange/info.asp" do
  return "\x01\x00"
end

get "/pokemondpds/worldexchange/result.asp" do
  data = "\x05\x00" 
  
  data = @trainer.monsters.first(:queue=>true).blobe unless @trainer.monsters.first(:queue=>true).nil? unless @trainer.nil?
  return data 
end

get "/pokemondpds/worldexchange/get.asp" do
  return @trainer.monsters.first(:queue=>true).blobe unless @trainer.monsters.first(:queue=>true).nil? unless @trainer.nil?
end

get "/pokemondpds/worldexchange/delete.asp" do
  data = @trainer.monsters.first(:queue=>true)
  data.queue = false
  data.save
  return "\x01\x00"
end

get "/pokemondpds/worldexchange/post.asp" do
  pkm = params[:data]
  monster = @trainer.monsters.new
  monster.blobe = saverawpkmr(pkm,true)
  if @trainer.complete == false
    @trainer.tsid = monster.structure.otsid
    @trainer.tid = monster.structure.otid
    @trainer.name = monster.structure.trainer
    @trainer.complete = true
    @trainer.save
  end
  monster.queue = true
  monster.save
  @struct = monster.structure
  @graph.put_wall_post("as Trainer #{@trainer.name} just uploaded #{@struct.nickname} the #{@struct.nature.name} #{@struct.name}","picture" =>GTS.url+@struct.image,"link" =>GTS.url+monster.url) unless @graph.nil?  
  return "\x01\x00"
end

get "/pokemondpds/worldexchange/post_finish.asp" do
  return "\x01\x00"
end    
