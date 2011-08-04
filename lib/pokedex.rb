class Pokemon
  include DataMapper::Resource
  def self.default_repository_name
    :pokedex
  end
  
  storage_names[:pokedex] = "pokemon"
  
  property :id, Serial
  property :name, String
  property :chain, Integer, :field => "evolution_chain_id"
  property :form, String, :field => "forme_name"
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

class Item
  include DataMapper::Resource
  def self.default_repository_name
      :pokedex
  end
  
  property :id, Serial
  property :name, String
end

class Move
  include DataMapper::Resource
  def self.default_repository_name
    :pokedex
  end
  
  property :id, Serial
  property :name, String
end

class Nature
  include DataMapper::Resource
  def self.default_repository_name
    :pokedex
  end

  storage_names[:pokedex] = "natures"

  property :id, Serial
  property :name, String
  property :statd, Integer, :field => "decreased_stat_id"
  property :stati, Integer, :field => "increased_stat_id"

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