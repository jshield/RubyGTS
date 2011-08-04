class GTSCrypt
  attr_accessor :data, :seed, :pkm, :oldseed

  def initialize(data, seed = 0x4a3b2c1d)
    @data = data
    obf_key_blob = @data[0..3]
    @pkm = @data[4..@data.size]
    obf_key, = obf_key_blob.unpack('N')
    @seed = obf_key ^ seed
    @seed = @seed | (@seed << 16)
    @oldseed = @seed    
  end
  
  def prng_next
    @seed = (@seed * 0x45 + 0x1111) & 0x7fffffff  # signed dword!
    rndn = ((@seed >> 16) & 0xff)
    return rndn
  end
  
  def decrypt
    @seed = @oldseed
    pkm = []
    i = 0
    @pkm.each_byte do |word|
       d = prng_next
       pkm[i] = ((word ^ d) & 0xff).chr
       i=i+1 
    end  
    return pkm
  end
end
