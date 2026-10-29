class Movie < ApplicationRecord
  def self.all_ratings
    %w[G PG PG-13 R]
  end

  TMDB_SEARCH_URL = 'https://api.themoviedb.org/3/search/movie'.freeze

  def self.find_in_tmdb(search_params, api_key = ENV['TMDB_API_KEY'])
    query = { api_key: api_key, query: search_params[:title] }
    query[:year] = search_params[:release_year] if search_params[:release_year].present?
    query[:language] = 'en-US' if search_params[:language] == 'en'

    response = Faraday.get(TMDB_SEARCH_URL, query)
    results = JSON.parse(response.body).fetch('results', [])
    results.filter_map { |result| movie_from_tmdb(result) }
  end

  def self.movie_from_tmdb(result)
    release_date = result['release_date'].presence&.to_date
    return nil if already_saved?(result['title'], release_date)

    new(title: result['title'], rating: 'R', description: result['overview'],
        release_date: release_date)
  end

  def self.already_saved?(title, release_date)
    scope = where(title: title)
    scope = scope.where(release_date: release_date.all_day) if release_date
    scope.exists?
  end

  def self.with_ratings(ratings, sort_by)
    if ratings.nil?
      all.order sort_by
    else
      where(rating: ratings.map(&:upcase)).order sort_by
    end
  end
end
