require 'set'
require "date"

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

def pairs_with_sum(nums, target)
  vistos      = Set.new
  pares_vistos = Set.new
  res         = []

  nums.each do |x|
    y    = target - x
    par  = (x <= y) ? [ x, y ] : [ y, x ]
    (vistos.include?(y) && !pares_vistos.include?(par)) ? (res << par; pares_vistos << par) : nil
    vistos << x
  end

  res.sort_by { |a, b| [ a, b ] }
end

def merge_intervals(intervals)
  return [] if intervals.empty?

  sorted = intervals.sort_by { |a, b| [ a, b ] }
  res = [ sorted.first.dup ]

  sorted.drop(1).each do |s, e|
    last_e = res[-1]
    overlap = (s <= last_e)

    overlap ?
      (res[-1][1] = (e > last_e) ? e : last_e) :
      (res << [ s, e ])
  end

  res
end

def anagrama?(palabra1, palabra2)
  norm = ->(s) { s.downcase.gsub(/[^a-záéíóúüñ]/, "").chars.sort.join }
  norm.call(palabra1) == norm.call(palabra2) ? true : false
end

def first_non_repeated(s)
  conteo = Hash.new(0)
  s.each_char { |ch| conteo[ch] += 1 unless ch == ' ' }
  s.each_char { |ch| return ch if conteo[ch] == 1 }
  nil
end

def group_anagrams(words)
  grupos = Hash.new { |h, k| h[k] = [] }
  words.each { |w| grupos[w.chars.sort.join] << w }
  grupos.values
end



def age_calculator(date_str)
  day, month, year = date_str.split("/").map(&:to_i)
  full_date = Date.new(year, month, day)

  today = Date.today
  age = today.year - full_date.year
  age -= 1 if (hoy.month < full_date.month) || (today.month == full_date.month && today.day < full_date.day)

  birthday = Date.new(hoy.year, mes, dia)
  message = (today >= full_datel) ? "Your birth day already past this year" : "Your birthday its comming"

  {
    age: age,
    full_date: birthday.strftime("%A, %d of %B"),
    message: message
  }
end

def length_of_longest_substring(s)
  last_pos = {}
  left     = 0
  best     = 0

  s.each_char.with_index do |ch, right|
    left = last_pos[ch] + 1 if last_pos.key?(ch) && last_pos[ch] >= left
    last_pos[ch] = right
    len = right - left + 1
    best = (len > best) ? len : best
  end

  best
end
