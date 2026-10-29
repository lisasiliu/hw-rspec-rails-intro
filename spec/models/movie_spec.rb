require 'spec_helper'
require 'rails_helper'

describe Movie do
  describe 'searching TMDB by keyword' do
    let(:tmdb_search_url) { 'https://api.themoviedb.org/3/search/movie' }

    it 'calls Faraday gem' do
      expect(Faraday).to receive(:get).and_call_original
      Movie.find_in_tmdb({ title: 'hacker', language: 'en' })
    end

    it 'calls TMDb with valid API key' do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('TMDB_API_KEY').and_return('env-test-key')
      Movie.find_in_tmdb({ title: 'hacker', language: 'en' })
      expect(a_request(:get, tmdb_search_url).
        with(query: hash_including('api_key' => 'env-test-key', 'query' => 'hacker'))).
        to have_been_made.once
    end

    it 'sends the API key passed as the second argument' do
      Movie.find_in_tmdb({ title: 'hacker' }, 'my-test-key')
      expect(a_request(:get, tmdb_search_url).
        with(query: hash_including('api_key' => 'my-test-key'))).to have_been_made.once
    end

    it 'includes the release year when given' do
      Movie.find_in_tmdb({ title: 'Olympics', release_year: '2000' }, 'k')
      expect(a_request(:get, tmdb_search_url).
        with(query: hash_including('year' => '2000'))).to have_been_made.once
    end

    it 'omits the release year when blank' do
      Movie.find_in_tmdb({ title: 'Olympics', release_year: '' }, 'k')
      expect(a_request(:get, tmdb_search_url).
        with(query: hash_excluding('year'))).to have_been_made.once
    end

    it 'sends an English language when English only is selected' do
      Movie.find_in_tmdb({ title: 'Olympics', language: 'en' }, 'k')
      expect(a_request(:get, tmdb_search_url).
        with(query: hash_including('language' => 'en-US'))).to have_been_made.once
    end

    it 'sends no language when all languages are selected' do
      Movie.find_in_tmdb({ title: 'Olympics', language: 'all' }, 'k')
      expect(a_request(:get, tmdb_search_url).
        with(query: hash_excluding('language'))).to have_been_made.once
    end

    it 'returns unsaved Movie objects built from the response' do
      movies = Movie.find_in_tmdb({ title: 'Olympics', release_year: '2000' }, 'k')
      expect(movies.size).to eq(2)
      expect(movies).to all(be_a_new(Movie))
      first = movies.first
      expect(first.title).to eq('Sydney 2000 Olympics Opening Ceremony')
      expect(first.rating).to eq('R')
      expect(first.release_date.to_date).to eq(Date.new(2000, 9, 15))
      expect(first.description).to start_with('Coverage of the glorious Olympic Opening Ceremony')
    end

    it 'leaves out movies that are already in the database' do
      Movie.create!(title: 'Sydney 2000 Olympics Opening Ceremony', rating: 'R',
                    release_date: Date.new(2000, 9, 15))
      movies = Movie.find_in_tmdb({ title: 'Olympics' }, 'k')
      expect(movies.map(&:title)).to eq(['Sydney 2000 Olympics Closing Ceremony'])
    end

    it 'returns an empty list when TMDb has no matches' do
      stub_request(:get, /api.themoviedb.org/).
        to_return(status: 200, body: JSON.generate({ page: 1, results: [], total_results: 0 }))
      expect(Movie.find_in_tmdb({ title: 'zzzzqqqq' }, 'k')).to eq([])
    end
  end
end
