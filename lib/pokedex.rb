class Pokemon
  include DataMapper::Resource
  def self.default_repository_name
    :pokedex
  end
  
  storage_names[:pokedex] = "pokemon"
  
  property :id, Serial
  property :identifier, String
  property :chain, Integer, :field => "evolution_chain_id"
  property :form, String, :field => "forme_name"
  
  def name
    return PokemonName.first(:id=>self.id,:local_language_id=>"9").name
  end
end

class PokemonStat
  include DataMapper::Resource
  def self.default_repository_name
    :pokedex
  end

  storage_names[:pokedex] = "pokemon_stats"

  property :pokemon_id, Integer, :key => true
  property :stat_id, Integer, :key => true
  property :base_stat, Integer
end

class PokemonName
  include DataMapper::Resource
  def self.default_repository_name
    :pokedex
  end

  storage_names[:pokedex] = "pokemon_names"

  property :id, Integer, :field => "pokemon_id", :key => true
  property :local_language_id, Integer, :key => true
  property :name, String
  
end

class NatureName
  include DataMapper::Resource
  def self.default_repository_name
    :pokedex
  end

  storage_names[:pokedex] = "nature_names"

  property :id, Integer, :field => "nature_id", :key => true
  property :local_language_id, Integer, :key => true
  property :name, String
  
end

class MoveName
  include DataMapper::Resource
  def self.default_repository_name
    :pokedex
  end

  storage_names[:pokedex] = "move_names"

  property :id, Integer, :field => "move_id", :key => true
  property :local_language_id, Integer, :key => true
  property :name, String
  
end

class Item
  include DataMapper::Resource
  def self.default_repository_name
      :pokedex
  end
  
  property :id, Serial
  property :identifier, String
  
  def name
    return ItemName.first(:id=>self.id,:local_language_id=>9).name
  end  
end

class ItemName
  include DataMapper::Resource
  def self.default_repository_name
    :pokedex
  end

  storage_names[:pokedex] = "item_names"

  property :id, Integer, :field => "item_id", :key => true
  property :local_language_id, Integer, :key => true
  property :name, String
  
end

class Move
  include DataMapper::Resource
  def self.default_repository_name
    :pokedex
  end
  
  property :id, Serial
  property :identifier, String
  
  def name
    return MoveName.first(:id=>self.id,:local_language_id=>9).name
  end
end

class Nature
  include DataMapper::Resource
  def self.default_repository_name
    :pokedex
  end

  storage_names[:pokedex] = "natures"

  property :id, Serial
  property :identifier, String
  property :statd, Integer, :field => "decreased_stat_id"
  property :stati, Integer, :field => "increased_stat_id"

  def name
    return NatureName.first(:id=>self.id,:local_language_id=>9).name
  end

  def dstat
    return self.statd-1
  end

  def istat
    return self.stati-1
  end
end

class EvolutionChain
  include DataMapper::Resource
  def self.default_repository_name
    :pokedex
  end

  storage_names[:pokedex] = "evolution_chains"
  property :id, Serial
  property :growth, Integer, :field => "growth_rate_id"

end

class GrowthRate
  include DataMapper::Resource
  def self.default_repository_name
    :pokedex
  end

  storage_names[:pokedex] = "growth_rates"

  property :id, Serial

end

class Experience
  include DataMapper::Resource
  def self.default_repository_name
    :pokedex
  end

  storage_names[:pokedex] = "experience"

  property :level, Integer, :key=>true
  property :experience, Integer, :key=>true
  property :growth, Integer, :field => "growth_rate_id"
end
