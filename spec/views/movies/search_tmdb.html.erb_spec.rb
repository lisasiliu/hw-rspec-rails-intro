require 'rails_helper'

describe 'movies/search_tmdb', type: :view do
  let(:movies) do
    [Movie.new(title: 'Sydney 2000 Olympics Opening Ceremony', rating: 'R',
               description: 'Coverage of the ceremony.', release_date: Date.new(2000, 9, 15)),
     Movie.new(title: 'Sydney 2000 Olympics Closing Ceremony', rating: 'R',
               description: 'The closing ceremony.', release_date: Date.new(2000, 10, 1))]
  end

  it 'has a GET search form with the tmdb_form id' do
    render
    expect(rendered).to have_css("form#tmdb_form[action='#{search_tmdb_path}'][method='get']")
  end

  it 'links back to the movie list' do
    render
    expect(rendered).to have_link('Back to movie list', href: movies_path)
  end

  it 'does not show the results table before a search' do
    render
    expect(rendered).not_to have_css('table#search_movies')
  end

  context 'with search results' do
    before :each do
      assign(:movies, movies)
      render
    end
    it 'lists every movie in the search_movies table' do
      expect(rendered).to have_css('table#search_movies tbody tr', count: 2)
      expect(rendered).to have_text('Sydney 2000 Olympics Closing Ceremony')
    end
    it 'has an add movie form for each movie that POSTs to add_movie' do
      expect(rendered).to have_css("table#search_movies form[action='#{add_movie_path}'][method='post']",
                                   count: 2)
      expect(rendered).to have_css("input[type='hidden'][name='title'][value='Sydney 2000 Olympics Opening Ceremony']",
                                   visible: :all)
    end
  end

  context 'with a flash message' do
    it 'shows the message in a Bootstrap alert' do
      flash[:danger] = 'No movies found with given parameters!'
      render
      expect(rendered).to have_css('.alert.alert-danger', text: 'No movies found with given parameters!')
    end
  end
end
