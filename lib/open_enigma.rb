require "open_enigma/version"

module OpenEnigma
  class Error < StandardError; end
  # Your code goes here...

  def self.run(plain_text, rand_num, plug_hash)
    Enigma.new(plain_text, rand_num, plug_hash).run
  end

  class Enigma
    def initialize(plain_text, rand_num, plug_hash)
      @plain_text = plain_text
      @rand_num = rand_num
      @plug_hash = plug_hash
    end
  
    def run
      alphabet = ('a'..'z').to_a
      alphabet_1 = alphabet.shuffle(random: Random.new(@rand_num))
      alphabet_2 = alphabet.shuffle(random: Random.new(@rand_num + 1))
      alphabet_3 = alphabet.shuffle(random: Random.new(@rand_num + 2))
      scrambler_1 = alphabet.zip(alphabet_1).to_h
      scrambler_2 = alphabet.zip(alphabet_2).to_h
      scrambler_3 = alphabet.zip(alphabet_3).to_h
      reflector_alphabet_1 = ('a'..'m').to_a.shuffle(random: Random.new(@rand_num))
      reflector_alphabet_2 = ('n'..'z').to_a.shuffle(random: Random.new(@rand_num))
      reflector = reflector_alphabet_1.zip(reflector_alphabet_2).to_h
  
      count = 0
      cryptogram = ''
      text_array = @plain_text.chars
      text_array.each do |char|
        result = plug_board(char, @plug_hash)
        result = scrambler(scrambler_1, result)
        result = scrambler(scrambler_2, result)
        result = scrambler(scrambler_3, result)
        result = reflector(reflector, result)
        result = scrambler(scrambler_3.invert, result)
        result = scrambler(scrambler_2.invert, result)
        result = scrambler(scrambler_1.invert, result)
        result = plug_board(result, @plug_hash)
        cryptogram += result
        if count % 676 == 0 && count >= 676
          # scrambler_2, scrambler_1を1回転
          scrambler_2_array =  scrambler_2.values.unshift(scrambler_2.values.last)
          scrambler_2_array.pop
          scrambler_2 = alphabet.zip(scrambler_2_array).to_h
          scrambler_1_array =  scrambler_1.values.unshift(scrambler_1.values.last)
          scrambler_1_array.pop
          scrambler_1 = alphabet.zip(scrambler_1_array).to_h
        elsif count % 26 == 0 && count >= 26
          # scrambler_2を1回転
          scrambler_2_array =  scrambler_2.values.unshift(scrambler_2.values.last)
          scrambler_2_array.pop
          scrambler_2 = alphabet.zip(scrambler_2_array).to_h
        end
        # scrambler_3を1回転
        scrambler_3_array =  scrambler_3.values.unshift(scrambler_3.values.last)
        scrambler_3_array.pop
        scrambler_3 = alphabet.zip(scrambler_3_array).to_h
        count += 1
      end
      cryptogram
    end
  
    private
  
    def plug_board(char, hash)
      hash.keys.each do |key|
        result = hash[key] if char == key
      end
      hash.values.each do |value|
        result = hash.invert[value] if char == value
      end
      result = char
    end
  
    def scrambler(scrambler_hash, char)
      scrambler_hash[char]
    end
  
    def reflector(reflector_hash, char)
      if reflector_hash[char].nil?
        reflector_hash.invert[char]
      else
        reflector_hash[char]
      end
    end
  end
end
