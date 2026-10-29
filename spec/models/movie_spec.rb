require 'rails_helper'

describe Movie do
  describe 'searching TMDB by keyword' do
    it 'calls Faraday gem with NYU domain' do
      expect(Faraday).to receive(:get).with('https://nyu.edu')
      Movie.find_in_tmdb('https://nyu.edu')
    end
  end
end
