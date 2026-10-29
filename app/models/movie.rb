class Movie < ApplicationRecord
  def self.all_ratings
    %w[G PG PG-13 R]
  end

  def self.find_in_tmdb(string)
    Faraday.get(string)
  end

  def self.with_ratings(ratings, sort_by)
    if ratings.nil?
      all.order sort_by
    else
      where(rating: ratings.map(&:upcase)).order sort_by
    end
  end
end
