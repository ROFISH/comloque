class Admin::EmojisController < ApplicationController
  def index
    @emojis = Emoji.all
  end

  def new
    @emoji = Emoji.new
  end

  def create
    @emoji = Emoji.new(emoji_params)
    if @emoji.save
      redirect_to action:'index'
    else
      render action:'new'
    end
  end

  def show
    @emoji = Emoji.find(params[:id])
  end

  def edit
    @emoji = Emoji.find(params[:id])
    render action:'new'
  end

  def update
    @emoji = Emoji.find(params[:id])
    if @emoji.update_attributes(emoji_params)
      redirect_to action:'index'
    else
      render action:'new'
    end
  end

  def destroy
    @emoji = Emoji.find(params[:id])
    if @emoji.destroy
      flash[:notice] = "Delete successful"
    end

    redirect_to action:'index'
  end

private

  def emoji_params
    params[:emoji].permit(:name,:image)
  end
end
