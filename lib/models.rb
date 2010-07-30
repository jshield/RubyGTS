class PokePRNG

  def initialize(seed)
    @seed = seed
  end
  
  def next
    @seed = (0x41C64E6D * @seed + 0x6073) & 0xFFFFFFFF
    tree = @seed >> 16
#    puts tree
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
    
  def blob    
    return @pkm.pack @pa
  end
  
  def pid
    return @pkm[0]
  end
  
  def dex
    return @pkm[3]
  end
  
  def dex=(id)
    @pkm[3] = id
    return 1
  end
  
  def held
    return @pkm[4]
  end

  def held=(id)
    @pkm[4] = id
    return 1
  end
  
  def otid
    return @pkm[5]
  end

  def otsid
    return @pkm[6]
  end
  
  def exp
    return @pkm[7]
  end
  
  def exp=(v)
    @pkm[7] = v
    return 1
  end
  
  def friendship
    return @pkm[8]
  end
  
  def ability
    return @pkm[9]
  end
  
  def markings
    return @pkm[10].to_s(2)
  end
  
  def language
    return @pkm[11]
  end
  
  def evs
    return @pkm[12..17]
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
  
  def movespp
    return @pkm[29..33]
  end
  
  def movesppu
    return @pkm[34..37]
  end
  
  def ivs
    iv = []
    riv = @pkm[37].to_s(2).padleft(32)
    6.times do |i|
      iv << (riv[i*5..i*5+4]).to_i(2)
    end
    return iv
  end
  
  def egg
    c = @pkm[37].to_s(2).padleft(32)
    return c[30].chr.to_i
  end
  
  def nicknamed
    c = @pkm[37].to_s(2).padleft(32)
    return c[31].chr.to_i
  end
  
  def inspect
    return @pkm.inspect
  end
  
end

class Monster
  include DataMapper::Resource
  property :id, Serial
  property :pkm, Object
  property :extra, Object
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
    self.pkm = blob.unpack("LS*")
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

class Trainer
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  has n, :monsters
end
