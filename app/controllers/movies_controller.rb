class MoviesController < ApplicationController

  def show
    session[:back] = true
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    if params[:sort]
      @sort= params[:sort]
      session[:sort] = @sort
    elsif session[:sort]
      @sort = session[:sort]
    end
    @all_ratings = Movie.get_all_ratings
    @where_statement = ""
    @not_first = params[:not_first]
    if session[:not_first]
      @not_first = session[:not_first]
    end
    if params[:ratings]
      @checked_ratings = params[:ratings]
      session[:checked_ratings] = @checked_ratings
    elsif !@not_first
      @not_first = true
      session[:not_first] = true
      @checked_ratings = {'G'=>1, 'PG'=>1, 'PG-13'=>1, 'R'=>1}
      session[:checked_ratings] = @checked_ratings
    elsif session[:back] == true && session[:checked_ratings]
      @checked_ratings = session[:checked_ratings]
    else
      @checked_ratings = nil
      session[:checked_ratings] = nil
    end
    where_maker
    session[:back] = false
    @movies = Movie.where(@where_statement).order(@sort).all
    end

  def new
    # default: render 'new' template
  end

  def where_maker
    if @checked_ratings
      @checked_ratings.keys.each do |rate|
        @where_statement += "rating = '#{rate}' or "
      end
      @where_statement = @where_statement.chop().chop().chop()
    else
      @where_statement = "rating = 'NONE EXISTENT'"
    end
  end

  def create
    session[:back] = true
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    session[:back] = true
    @movie = Movie.find params[:id]
  end

  def update
    session[:back] = true
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    session[:back] = true
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
