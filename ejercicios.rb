require 'set'

def contar_vocales(texto)
  s = texto.to_s.downcase
  conteo = { "a"=>0, "e"=>0, "i"=>0, "o"=>0, "u"=>0 }
  s.each_char { |ch| conteo[ch] += 1 if conteo.key?(ch) }
  conteo
end

def balanceado?(s)
  var=0
  s.each_char do |ch|
    if ch == "("
      var =+1
    elsif ch == ")"
      return false if var == 0
      var -=1
    end
  end
  var == 0
end

def balanceado_multi?(s)
  pares = { ')' => '(', ']' => '[', '}' => '{' }
  apertura = pares.values.to_set
  pila = []

  s.each_char do |ch|
    if apertura.include?(ch)
      pila << ch
    elsif pares.key?(ch)
      return false if pila.empty? || pila.pop != pares[ch]
    end
  end

  pila.empty?
end
