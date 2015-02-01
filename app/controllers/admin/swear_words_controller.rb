class Admin::SwearWordsController < ApplicationController
  def index
    @swear_words = SwearWord.all
  end

  def new
    @swear_word = SwearWord.new
  end

  def create
    @swear_word = SwearWord.new(swear_word_params)
    if @swear_word.save
      redirect_to action:'index'
    else
      render action:'new'
    end
  end

  def show
    @swear_word = SwearWord.find(params[:id])
  end

  def edit
    @swear_word = SwearWord.find(params[:id])
    render action:'new'
  end

  def update
    @swear_word = SwearWord.find(params[:id])
    if @swear_word.update_attributes(swear_word_params)
      redirect_to action:'index'
    else
      render action:'new'
    end
  end

  def destroy
    @swear_word = SwearWord.find(params[:id])
    if @swear_word.destroy
      flash[:notice] = "Delete successful"
    end

    redirect_to action:'index'
  end

private

  def swear_word_params
    params[:swear_word].permit(:word,:mask,:case_sensitive,:require_beginning_space,:require_ending_space)
  end
end
