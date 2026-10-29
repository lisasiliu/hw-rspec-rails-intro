require 'rails_helper'

describe MoviesController, type: :controller do
  describe 'searching TMDb' do
    before :each do
      @fake_results = [double('movie1'), double('movie2')]
      @search_params = { title: 'hardware', release_year: '1990', language: 'en' }
    end
    it 'calls the model method that performs TMDb search' do
      expect(Movie).to receive(:find_in_tmdb).with(@search_params).
        and_return(@fake_results)
      get :search_tmdb, params: @search_params
    end
    describe 'after valid search' do
      before :each do
        allow(Movie).to receive(:find_in_tmdb).and_return(@fake_results)
        get :search_tmdb, params: @search_params
      end
      it 'selects the Search Results template for rendering' do
        expect(response).to render_template('search_tmdb')
      end
      it 'makes the TMDb search results available to that template' do
        expect(assigns(:movies)).to eq(@fake_results)
      end
      it 'does not show an error message' do
        expect(flash[:danger]).to be_nil
      end
    end
    describe 'when the release year is left blank' do
      it 'still searches TMDb' do
        expect(Movie).to receive(:find_in_tmdb).
          with({ title: 'hardware', release_year: '', language: 'all' }).
          and_return(@fake_results)
        get :search_tmdb, params: { title: 'hardware', release_year: '', language: 'all' }
      end
    end
    describe 'when the title is left blank' do
      it 'does not search TMDb' do
        expect(Movie).not_to receive(:find_in_tmdb)
        get :search_tmdb, params: { title: '', release_year: '1990', language: 'en' }
      end
      describe 'the response' do
        before :each do
          allow(Movie).to receive(:find_in_tmdb)
          get :search_tmdb, params: { title: '', release_year: '1990', language: 'en' }
        end
        it 'shows an error message' do
          expect(flash[:danger]).to eq('Please fill in all required fields!')
        end
        it 'selects the Search Results template for rendering' do
          expect(response).to render_template('search_tmdb')
        end
      end
    end
    describe 'when no movies match' do
      before :each do
        allow(Movie).to receive(:find_in_tmdb).and_return([])
        get :search_tmdb, params: @search_params
      end
      it 'shows a no-results message' do
        expect(flash[:danger]).to eq('No movies found with given parameters!')
      end
    end
    describe 'before the form has been submitted' do
      it 'shows the blank form without searching or showing an error' do
        expect(Movie).not_to receive(:find_in_tmdb)
        get :search_tmdb
        expect(response).to render_template('search_tmdb')
        expect(flash[:danger]).to be_nil
      end
    end
  end

  describe 'adding a movie found on TMDb' do
    let(:movie_params) do
      { title: 'Sydney 2000 Olympics Opening Ceremony', rating: 'R',
        description: 'Coverage of the opening ceremony.',
        release_date: '2000-09-15 00:00:00 UTC' }
    end
    it 'saves the movie to the database' do
      expect { post :add_movie, params: movie_params }.to change(Movie, :count).by(1)
      expect(Movie.last.title).to eq('Sydney 2000 Olympics Opening Ceremony')
    end
    it 'redirects back to the search page' do
      post :add_movie, params: movie_params
      expect(response).to redirect_to(search_tmdb_path)
    end
    it 'tells the user the movie was added' do
      post :add_movie, params: movie_params
      expect(flash[:success]).
        to eq('Sydney 2000 Olympics Opening Ceremony was successfully added to RottenPotatoes.')
    end
  end
end
