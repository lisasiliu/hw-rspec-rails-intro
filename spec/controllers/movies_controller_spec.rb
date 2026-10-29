require 'rails_helper'

describe MoviesController, type: :controller do
  describe 'searching TMDb' do
    it 'calls the model method that performs TMDb search' do
      fake_results = [double('movie1'), double('movie2')]
      expect(Movie).to receive(:find_in_tmdb).with('hardware').
        and_return(fake_results)
      get :search_tmdb, params: { search_terms: 'hardware' }
    end
    it 'selects the Search Results template for rendering'
    it 'makes the TMDb search results available to that template'
  end
end
