# encoding: BINARY
class PokePRNG

  def initialize(seed)
    @seed = seed
  end
  
  def next
    @seed = (0x41C64E6D * @seed + 0x6073) & 0xFFFFFFFF
    tree = @seed >> 16    
    return tree.to_i
  end
      
end

class String
  def padleft(pad)
    "0"*(pad-self.size)+self
  end
end

class PokeStruct

  def initialize(pkm)
    @ph = "LSS"
    @pba = "SSSSL"+("C"*16)+"L"
    @pbb = "SSSS"+("C"*8)+"LLCCSSS"
    @pbc = "H44CCLL"
    @pbd = "H32H6H6SSCCCCCC"
    @pbe = "CCSCCSSSSSSSH112H48"
    @pa = @ph+@pba+@pbb+@pbc+@pbd+@pbe
    @pkm = pkm.unpack @pa
  end
  
  def from_pokechar(arr)
    string = []
    (arr.size/4).times do |i|
      string[i] = ""        
      string[i] << arr[i*4+2] 
      string[i] << arr[i*4+3]
      string[i] << arr[i*4] 
      string[i] << arr[i*4+1]
      string[i] = @@pokechar[string[i].to_i(16)]
      if string[i].nil?
        string.delete_at i
        break
      end
    end
    return string
  end
  
  def to_pokechar(str)
    arr = []
    dict = @@pokechar.invert
    (str.size).times do |i|
      arr[i] = "0"+dict[str[i].chr].to_s(16)       
      arr[i] = arr[i][2].chr + arr[i][3].chr + arr[i][0].chr + arr[i][1].chr
    end
    arr << "ffff"
    return arr
  end

  def level
    poke = Pokemon.first(:id=>self.dex)
    chain = EvolutionChain.first(:id=>poke.chain)
    level = Experience.last(:growth=>chain.growth,:experience.lte=>self.exp).level
    return level
  end

  def level=(v)
    poke = Pokemon.first(:id=>self.dex)
    chain = EvolutionChain.first(:id=>poke.chain)
    self.exp = Experience.last(:growth=>chain.growth,:level=>v).experience
  end
    
  def blob    
    return @pkm.pack @pa
  end
  
  def pid
    return @pkm[0]
  end

  def pid=(v)
    @pkm[0] = v.to_i
  end

  def natid
    return (self.pid % 25)
  end

  def nature
    return Nature.first(:id=>self.natid)
  end

  def dex
    return @pkm[3]
  end
  
  def dex=(id)
    @pkm[3] = id.to_i
  end
  
  def name 
    return Pokemon.get(self.dex).name
  end
  
  def image
    return "i/pokemon/#{"shiny/" if self.shiny?}#{self.dex}.png"
  end
  
  def held
    return @pkm[4]
  end
  
  def helditem
    item = Item.get(self.held)
    if item.nil?
      return "Nothing"
    else
      return item.name
    end
  end

  def held=(id)
    @pkm[4] = id.to_i
  end
  
  def otid
    return @pkm[5]
  end

  def otid=(id)
    @pkm[5] = id.to_i
  end

  def otsid
    return @pkm[6]
  end

  def otsid=(id)
    @pkm[6] = id.to_i
  end
  
  def shiny?
    hb = self.pid >> 16
    lb = self.pid & 0xFFFF
    return ((hb ^ lb)^(self.otid^self.otsid)) < 8
  end
  
  def exp
    return @pkm[7]
  end
  
  def exp=(v)
    @pkm[7] = v.to_i
    return 1
  end
  
  def friendship
    return @pkm[8]
  end

  def friendship=(v)
    @pkm[8]=v.to_i
  end
  
  def ability
    return @pkm[9]
  end

  def ability=(v)
    @pkm[9]=v.to_i
  end
  
  def markings
    return @pkm[10].to_s(2)
  end
  
  def language
    return @pkm[11]
  end
  
  def evs
    ev = @pkm[12..17]
    ev[3],ev[5] = ev[5],ev[3]
    return ev
  end
  
  def evs=(v)
    v[5],v[3] = v[5],v[3]
    @pkm[12..17] = v[0..5]
  end
  
  def base(i)
    return PokemonStat.first(:pokemon_id=>self.dex,:stat_id=>i+1).base_stat
  end

  def maxhp
    return ((((ivs[0])+(2*base(0))+(evs[0]>>2))*level)/100)+10+level;
  end

  def bstat(i)
    stat = ((((ivs[i])+(2*base(i))+(evs[i]>>2))*level)/100)+5;
    stat *= 0.90 if nature.dstat == i
    stat *= 1.10 if nature.istat == i
    return stat
  end
  
  def cs
    return @pkm[18..23]
  end
  
  def ribbons
    return [@pkm[24],@pkm[37]]
  end
  
  def moves
      return @pkm[25..28]
  end

  def moves=(v)
    @pkm[25..28] = v[0..3]
  end
  
  def movespp
    return @pkm[29..33]
  end

  def movespp=(v)
    @pkm[29..33] = v[0..3]
  end
  
  def movesppu
    return @pkm[34..37]
  end

  def movesppu=(v)
    @pkm[34..37] = v[0..3]
  end

  def ivs
    iv = [] 
    riv = @pkm[37].to_s(2).padleft(32).reverse
    6.times do |i|
      iv << (riv[i*5..i*5+4]).to_i(2)
    end
    iv[3],iv[5] = iv[5],iv[3]
    return iv
  end
  
  def ivs=(v)
    riv = ""
    v[3],v[5] = v[5],v[3]
    6.times do |i|
      riv << v[i].to_s(2).padleft(5)
    end
    riv << self.egg?.to_s
    riv << self.nicknamed?.to_s
    @pkm[37] = riv.reverse.to_i(2)
  end
  
  def egg?
    f = @pkm[37].to_s(2).padleft(32).reverse
    return f[30].chr.to_i
  end

  def egg=(v)
    f = @pkm[37].to_s(2).padleft(32).reverse
    f[30] = "1" if v == true
    f[30] = "0" if v == false
    @pkm[37] = f.reverse.to_i(2)
  end
  
  def nicknamed?
    f = @pkm[37].to_s(2).padleft(32).reverse
    return f[31].chr.to_i
  end

  def nicknamed=(v)
    f = @pkm[37].to_s(2).padleft(32).reverse
    f[31] = "1" if v == true
    f[31] = "0" if v == false
    @pkm[37] = f.reverse.to_i(2)
  end

  def fenc
    f = @pkm[39].to_s(2).padleft(8).reverse
    return f[0].chr.to_i
  end

  def fenc=(v)
    f = @pkm[39].to_s(2).padleft(8).reverse
    f[0] = "1" if v == true
    f[0] = "0" if v == false
    @pkm[39] = f.reverse.to_i(2)
  end

  def sex
    f = @pkm[39].to_s(2).padleft(8).reverse
    return "Genderless" if f[2].chr == "1"
    return "Female" if f[1].chr == "1"
    return "Male"
  end

  def sex=(v)
    f = @pkm[39].to_s(2).padleft(8).reverse
    case v
    when 0 then
      f[1] = "0"
      f[2] = "0"
    when 1 then
      f[1] = "1"
      f[2] = "0"
    when 2 then
      f[1] = "0"
      f[2] = "1"
    else
      f[1] = "0"
      f[2] = "1"
    end
    @pkm[39] = f.reverse.to_i(2)
  end
  
  def nickname
    if self.nicknamed? == 1
      return self.from_pokechar(@pkm[44])
    end
    return self.name
  end
  
  def nickname=(str)
    self.nicknamed = true
    n = self.to_pokechar(str)
    (11-n.size).times do |i|
      n << "0000"
    end
    @pkm[44] = n.pack("H4"*11).unpack("H44")[0]
  end
  
  def trainer
    return self.from_pokechar(@pkm[49])
  end
 
  def inspect
    return @pkm.inspect
  end
  
end

class Monster
  include DataMapper::Resource
  property :id, Serial
  property :pkm, Object
  property :extra, Object, :default => open("./extra").read
  property :queue, Boolean, :field => "send", :default => false
  property :clone, Boolean, :default => false
  belongs_to :trainer
  
  def blobe=(blob)
    self.pkm = blob[0..235].unpack("LS*")
    self.decrypt
    self.extra = blob[236..291]
    return true
  end
  
  def structure
    return PokeStruct.new self.pkm.pack("LS*")
  end
  
  def structure=(struct)
    self.pkm = struct.blob.unpack("LS*")
  end
  
  def blob
    return self.pkm.pack("LS*")
  end
  
  def blob=(blob)
    self.pkm = blob[0..235].unpack("LS*")
    self.extra = blob[236..291] unless blob[236..291].nil?
    self.chksum
    return 1
  end      
  
  def blobe
    self.chksum
    return self.encrypt+self.extra
  end
  
  def chksum
    sum = 0   
    self.pkm[3..66].each do |word|
      sum += word
    end
    sum = sum.to_s(2)
    self.pkm[2] = sum[sum.size-16..sum.size].to_i(2)
    return true
  end 
  
  def decrypt
    self.pkm = self.shuffle(self.reciprocal_crypt(self.pkm),true) 
    return true
  end
  
  def encrypt
   shuffled = self.reciprocal_crypt(self.shuffle((self.pkm),false))
   return shuffled.pack("LS*")
  end

  def url
    return "/trainer/#{self.trainer.id}/pokemon/#{self.id}"
  end
  
  def reciprocal_crypt(words)
    p = PokePRNG.new words[2]
    data = words[0..2]
    words[3..66].each do |word|
      data << (word ^ p.next)
    end
    if words.size > 67
      p = PokePRNG.new words[0]
      words[67..words.size].each do |word|
       data << (word ^ p.next)
      end
    end
    return data
  end
  
  def shuffle(words,reversed)
    perm = Permutation.new(4)
    pid = words[0]
    shuffle_index = (pid >> 0xD & 0x1F) % 24
    perm.rank = shuffle_index
    shuffle_order = perm.value
    shuffle_order = perm.invert!.value if reversed == true
    shuffled = words[0..2]
    shuffle_order.each do |chunk|
      shuffled += words[(chunk*16+3)..(chunk*16+18)]
    end
    shuffled += words[67..words.size]
    return shuffled
  end
end

class User
  include DataMapper::Resource
  property :id, Serial
  property :fbid, Integer, :unique => true
  property :fbat, Object
  property :ctid, Integer
  property :name, String
  property :pass, BCryptHash, :default => "default"
  has n, :trainers  
  def current 
    return self.trainers.all(:id=>self.ctid).first
  end
end

class Trainer
  include DataMapper::Resource
  property :id, Serial
  property :tid, Integer
  property :tsid, Integer
  property :name, String
  property :complete, Boolean, :default => false
  property :reg, Boolean, :default => false
  has n, :monsters
  
  def profile
    return "/trainer/#{self.id}/profile"
  end
  
  belongs_to :user
end

