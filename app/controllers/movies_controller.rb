class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @movies = Movie.all
    @all_ratings = Movie.get_ratings
    @ratings_selected = []
    @filter_params = {}

    if(params[:ratings].nil? && params[:order].nil?)
      params[:ratings] ||= session[:ratings]
      params[:order] ||= session[:order]

      @all_ratings.each {|rating| params[:ratings][rating] = "1" } if params[:ratings].nil?

      flash.keep
      redirect_to movies_path(params)
    end

    if params[:ratings].nil?
      params[:ratings] = {}
      @all_ratings.each {|rating| params[:ratings][rating] = "1" }
    end

    @ratings_selected =  params[:ratings].keys
    session[:ratings] = params[:ratings]
    @filter_params.merge!({:ratings => params[:ratings]})

    @movies = @movies.where(rating: @ratings_selected) unless @ratings_selected.empty?

    unless "#{params[:order]}".blank?
      session[:order] = params[:order]
      @movies = @movies.order(params[:order])
      params["#{params[:order]}_header".to_sym] = "hilite"
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
