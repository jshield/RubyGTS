require "./common"

namespace :db do
  task :bootstrap do
    puts "Creating Promotional Pokemon User Account"
    promo = User.first_or_create(:name=>"PROMO",:pass=>"J;<a7C")
    promo.save    
    puts "Creating Promotional Pokemon Trainer Account"
    trainer = promo.trainers.first_or_create(:name=>"PROMO")
    trainer.reg = true
    trainer.save
    Dir["./pkm/*.pkm"].each do |data|
      puts "Loading Pokemon from PKM #{data}"
      pkm = ""
      monster = trainer.monsters.new
      pkm << open(data).read()
      pkm << open("./extra").read() if pkm.size == 236
      monster.blob = pkm
      monster.save
    end
    puts "Creating Charon USER Account"
    pkmkeeper = User.first_or_create(:name=>"Pokemon Keeper",:pass=>"j;<a7C")
    pkmkeeper.save
  end
end
