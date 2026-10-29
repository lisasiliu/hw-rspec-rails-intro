Rottenpotatoes::Application.routes.draw do
  resources :movies
  get '/search', to: 'movies#search_tmdb', as: 'search_tmdb'
  # map '/' to be a redirect to '/movies'
  root to: redirect('/movies')
end
