class LongestwordController < ApplicationController
  def game
    @generate_grid = generate_grid
    @start_time = Time.now
  end

  def score
    @attempt = params[:user_answer].upcase
    @translation = get_translation(@attempt)
    @start_time = params[:start_time].to_datetime
    @end_time = Time.now
    @grid = params[:grid].split(" ")
    @result_time = (@end_time - @start_time).round(2)
    @result = run_game(@attempt, @grid, @start_time, @end_time)
    @score_result = @result[:score].round(2)
    @message_result = @result[:message].upcase
  end

def generate_grid
 alphabet_grid = Array.new(9) { ('A'..'Z').to_a[rand(26)] }
 alphabet_grid.join(" ")
end

def included?(guess, grid)
  the_grid = grid.clone
  guess.chars.each do |letter|
    the_grid.delete_at(the_grid.index(letter)) if the_grid.include?(letter)
  end
   grid.size == guess.size + the_grid.size
end

def compute_score(attempt, time_taken)
  (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
end

def run_game(attempt, grid, start_time, end_time)
  result = { time: end_time - start_time }

  result[:translation] = get_translation(attempt)
  result[:score], result[:message] = score_and_message(
    attempt, result[:translation], grid, result[:time])

  result
end

def score_and_message(attempt, translation, grid, time)
  if translation
    if included?(attempt.upcase, grid)
      score = compute_score(attempt, time)
      [score, "well done"]
    else
      [0, "not in the grid"]
    end
  else
    [0, "not an english word"]
  end
end


def get_translation(word)
  response = open("http://api.wordreference.com/0.8/80143/json/enfr/#{word.downcase}")
  json = JSON.parse(response.read.to_s)
  json['term0']['PrincipalTranslations']['0']['FirstTranslation']['term'] unless json["Error"]
end
end
