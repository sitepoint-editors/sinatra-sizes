class String
  
  def caesar_shift(shift=1)
    letters = ("a".."z").to_a
    ciphertext = []
    self.downcase.scan( /./ ) do |char|
      if letters.include?(char)
        ciphertext << letters[(letters.index(char)+shift)%26]
      else
        ciphertext << char
      end
    end
    ciphertext.join.upcase
  end

end
