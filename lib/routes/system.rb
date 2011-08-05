get "/system/search/:model" do
  model = nil
  case params[:model]
    when "pokemon"
      model = "PokemonName"
  end
  return [nil].to_json if model.nil? 
  Kernel.const_get(model).all(:name.like=>"%#{params[:term]}%",:local_language_id=>9).to_json
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
