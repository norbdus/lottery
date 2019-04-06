class Concurso < ApplicationRecord
  require 'csv'    

  validates :concurso, uniqueness: true
  validates :concurso, :data_sorteio, :bola1, :bola2, :bola3, :bola4, :bola5, :bola6, :bola7, :bola8, :bola9, :bola10, :bola11, :bola12, :bola13, :bola14, :bola15, presence: true

  def self.load_lottery
    csv_text = File.read('lotofacil_todos.csv')
    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      Concurso.create!(row.to_hash)
    end
  end

  def self.update_games(update_count = 5)

    require 'nokogiri'
    last_game = Concurso.all.maximum(:concurso)
    document = Nokogiri::HTML(File.open('d_lotfac.htm'))
    table = document.at('table')
    result = table.search('td[rowspan]').collect{|x| x.children.text}
    arr = result.to_a.last(update_count * 31)
    arr.each_slice(31) do |c|
      Concurso.create!(Concurso.merge_attributes(c)) if Concurso.find_by(concurso: c[0].to_i).nil?
    end
  end

  def self.test_my_game(game, range_games = nil)
    range = (Concurso.first.concurso..Concurso.last.concurso)
    hits11 = 0
    hits12 = 0
    hits13 = 0
    hits14 = 0
    hits15 = 0
    zerohits  = 0
    range.each do |c|
      concurso = Concurso.find_by(concurso: c)
      case how_many_hits?(game, concurso)
        when 11
          hits11 += 1
        when 12
          hits12 += 1
        when 13
          hits13 += 1
        when 14
          hits14 += 1
        when 15
          hits15 += 1
        when 0
          zerohits += 1
        else
        nil
      end
    end
    {hits11: hits11, hits12: hits12, hits13: hits13, hits14: hits14, hits15: hits15, zerohits: zerohits}
  end

  def self.how_many_hits?(game, c)
    balls = c.balls
    hits = 0
    game.each do |b|
      hits += 1 if balls.include?(b)
    end
    hits
  end

  def self.how_many_cash?(game, c)
    hits = how_many_hits?(game, c)
    table_prices = { 15 => 2.0, 16 => 32.0, 17 => 272, 18 => 1632.0 }
    cash = 0.0
    if hits >= 11
      method = "valor_rateio_#{hits}_numeros"
      cash += c.try(method.to_sym)
      cash -= table_prices[game.size]
    else
      cash -= table_prices[game.size]
    end
    cash.to_f
  end

  def balls
    [self.bola1, self.bola2, self.bola3, self.bola4, self.bola5, self.bola6, self.bola7, self.bola8, self.bola9, self.bola10, self.bola11, self.bola12, self.bola13, self.bola14, self.bola15]
  end

  def self.hits_last_dozen
    last_games = Concurso.last(10)
    hash_balls = new_hash_balls
    last_games.each do |g|
      (1..25).each do |x|
        hash_balls["hits#{x}"] += 1 if g.balls.include?(x)
      end
    end
    Hash[hash_balls.sort]
  end

  def self.hits_last_games(qty_last_games = 10)
    counts = {}
    Concurso.last(qty_last_games).collect{|x| x.balls}.flatten.group_by(&:itself).each { |k,v| counts[k] = v.length }
    Hash[counts.sort]
  end

  def self.hotballs(qty_last_games = 10, qty = 5)
    hits_last_games(qty_last_games).sort_by {|_key, value| value}.last(qty).to_h
  end

  def self.coldballs(qty_last_games = 10, qty = 5)
    hits_last_games(qty_last_games).sort_by {|_key, value| value}.first(qty).to_h
  end

  def even_odd
    result = {even: 0, odd: 0}
    balls.each do |x|
      result[:even] += 1 if x.even?
      result[:odd] += 1 if x.odd?
    end
    result
  end

  def self.new_hash_balls
    hash_balls = {}
    (1..25).each do |x|
      hash_balls["hits#{x}"] = 0
    end
    hash_balls
  end

  def self.randon_game_with_params(qty = 15, qty_hot = nil, qty_cold = nil, qty_rep_last = nil, qty_odd = nil, qty_even = nil, ini_sum = nil, end_sum = nil)
    chosen = []
    chosen.concat hotballs(10,qty_hot)
    chosen.concat coldballs(10,qty_cold)
    last_repeat = Concurso.last.repeated.sample(qty_rep_last)
    chosen.concat(last_repeat - chosen)

    (1..qty).each do
      chosen << ((1..25).to_a - chosen).sample
      break if chosen.uniq.size == qty
    end
    chosen.uniq
  end

  def self.composition_game(game)
    qty_hot = [] 
    qty_cold = []
    qty_rep_last = []
    qty_odd = []
    qty_even = []
    sum_game = []
    game.each do |n|
      qty_hot << n if hotballs.include?(n)
      qty_cold << n if coldballs.include?(n)
      qty_rep_last << n if (Concurso.last.balls & game).include?(n)
    end

    game.each do |n|
      qty_odd << n if n.odd?
      qty_even << n if n.even?
    end

    sum_game << game.sum
    {qty_hot: qty_hot, qty_cold: qty_cold, qty_rep_last: qty_rep_last, qty_odd: qty_odd, qty_even: qty_even, sum_game: sum_game}
  end

  def composition_game
    qty_hot = [] 
    qty_cold = []
    qty_rep_last = []
    qty_odd = []
    qty_even = []
    sum_game = []
    self.balls.each do |n|
      qty_hot << n if Concurso.hotballs.include?(n)
      qty_cold << n if Concurso.coldballs.include?(n)
      qty_rep_last << n if (Concurso.find_by(concurso: self.concurso - 1).balls & self.balls).include?(n)
    end

    self.balls.each do |n|
      qty_odd << n if n.odd?
      qty_even << n if n.even?
    end

    sum_game << self.balls.sum
    {qty_hot: qty_hot, qty_cold: qty_cold, qty_rep_last: qty_rep_last, qty_odd: qty_odd, qty_even: qty_even, sum_game: sum_game}
  end

  def self.composition_game_colorize(game)
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil
    require 'colorize'
    colors = { qty_hot: :red, qty_cold: :blue }
    result = game.is_a?(Array) ? composition_game(game) : game.composition_game
    game = game.balls unless game.is_a?(Array)
    output = { red: [], blue: [], green: [], black: []}
    game.each do |number|
      if result[:qty_hot].include?(number)
        output[:red] << number
      end
      if result[:qty_cold].include?(number)
        output[:blue] << number
      end
      if result[:qty_rep_last].include?(number)
        output[:green] << number
      end
      if  !(result[:qty_hot].include?(number)) and 
          !(result[:qty_cold].include?(number)) and 
          !(result[:qty_rep_last].include?(number))
          output[:black] << number
      end

    end
    
    output[:green] = output[:green] - output[:red] 
    output[:green] = output[:green] - output[:blue]
    print " #{output[:red].join(' ')} ".colorize(:color => :white, :background => :red)
    print " #{output[:green].join(' ')} ".colorize(:color => :white, :background => :green)
    print " #{output[:black].join(' ')} ".colorize(:color => :white, :background => :black)
    print " #{output[:blue].join(' ')} ".colorize(:color => :white, :background => :blue)
    print "(#{result[:qty_even].try(:size)} Pares, #{result[:qty_odd].try(:size)} Impares) - Somatório: #{result[:sum_game]}"
    puts ''
    nil
  end

  def self.randon_game(qty = 15)
    chosen = []
    (1..qty).each do
      chosen << ((1..25).to_a - chosen).sample
    end
    chosen
  end

  def self.count_sequences(game)
    output = []
    aux = game.sort.first - 1 
    temp = []
    game.sort.each do |x|
      if aux == x.pred
        temp << x
      else
        output << temp
        temp = []
        temp << x
      end
      aux = x
    end
    output << temp
    puts output.to_s
    output_hash = {}
    (2..15).to_a.each do |x|
      count = output.map{|z| z.size == x}.count(true)
      output_hash[x] =  count unless count == 0
    end
    output_hash
  end

  def self.how_much_did_i_win?(game, last_months)
    concursos = Concurso.where('data_sorteio >= ?', Date.current - last_months.month)
    cash = []
    concursos.each do |x|
      cash << how_many_cash?(game, x)
    end
    cash.sum
  end

  def self.sum_per_concurso(last = 10)
    concursos = Concurso.last(last)
    result = {}
    concursos.each do |c|
      result[c.concurso] = c.balls.sum
    end
    result
  end

  def self.repeated_last_draw(last_num = 10)
    concursos = Concurso.last(last_num)
    result = {}
    concursos.each do |c|
      result[c.concurso] = c.repeated_sum
    end
    result
  end

  def repeated_sum
    rest = (Concurso.find_by(concurso: self.concurso - 1).balls - self.balls).size
    (15 - rest)
  end

  def repeated
    rest = Concurso.find_by(concurso: self.concurso - 1).balls & self.balls
    rest
  end

  private

#   def self.convert_html_to_csv
#     require 'nokogiri'
#     require 'pp'

#     doc = Nokogiri::HTML(<<EOT)
#         <table>
#         <tr>
#             <td>John Smith</td>
#             <td>I live here 123</td>
#             <td>phone ###</td>
#             <td>Birthday</td>
#             <td>Other Data</td>
#         </tr>
#         <tr>
#             <td>John Smyth</td>
#             <td>I live here 456</td>
#             <td>phone ###</td>
#             <td>Birthday</td>
#             <td>Other Data</td>
#         </tr>
#         </table>
#         EOT

#     data = []
#     doc.at('table').search('tr').each do |tr|
#         data << tr.search('td').map(&:text)
#     end

#     pp data
#   end

  def self.merge_attributes(array_values)
    if array_values.size == 31
      attrs = ["concurso", "data_sorteio", "bola1", "bola2", "bola3", "bola4", "bola5", "bola6", "bola7", "bola8", "bola9", "bola10", "bola11", "bola12", "bola13", "bola14", "bola15", "arrecadacao_total", "ganhadores_15_numeros", "ganhadores_14_numeros", "ganhadores_13_numeros", "ganhadores_12_numeros", "ganhadores_11_numeros", "valor_rateio_15_numeros", "valor_rateio_14_numeros", "valor_rateio_13_numeros", "valor_rateio_12_numeros", "valor_rateio_11_numeros", "acumulado_15_numeros", "estimativa_premio", "valor_acumulado_especial"]
      return Hash[attrs.zip(array_values.map {|i| i.include?(',') ? (i.split /, /) : i})]
    end
    false
  end
  
end
