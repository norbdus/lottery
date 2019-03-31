class Concurso < ApplicationRecord
  require 'csv'    

  def self.load_lottery
    csv_text = File.read('lotofacil_todos.csv')
    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      Concurso.create!(row.to_hash)
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

  def balls
    [self.bola1, self.bola2, self.bola3, self.bola4, self.bola5, self.bola6, self.bola7, self.bola8, self.bola9, self.bola10, self.bola11, self.bola12, self.bola13, self.bola14, self.bola15]
  end

  def self.hotballs
    last_games = Concurso.last(10)
    hash_balls = new_hash_balls
    last_games.each do |g|
      (1..25).each do |x|
        hash_balls["hits#{x}"] += 1 if g.balls.include?(x)
      end
    end
    Hash[hash_balls.sort]
  end

  def self.new_hash_balls
    hash_balls = {}
    (1..25).each do |x|
      hash_balls["hits#{x}"] = 0
    end
    hash_balls
  end
end
