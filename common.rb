require "gts.settings.rb"
unless File.basename($0) == "rake" then
  require "sinatra"
  require "koala"
  gem     "json", "~>1.4.6"
  require "./lib/facebook"
  require "./lib/routes/gts"
  require "./lib/routes/trainer"
  require "./lib/routes/system"
  require "haml"
  require "sass"
end

require "dm-core"
require "dm-migrations"
require "dm-types"
require "dm-validations"
require "dm-serializer"

require "extlib"
require "digest/sha1"
require "base64"
require "permutation"
require "ostruct"

require "./lib/gtscrypt"
require "./lib/models"
require "./lib/poketext"
require "./lib/pokedex"


DataMapper.setup(:default, GTS.gtsdb)
DataMapper.setup(:pokedex, GTS.pokedexdb)

DataMapper.auto_upgrade!
