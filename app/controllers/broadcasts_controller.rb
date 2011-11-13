class BroadcastsController < ApplicationController
  before_filter :except => [:index, :show] { authenticate_admin(broadcasts_url) }
  
  def index
    @broadcasts = Broadcast.order('created_at DESC').page(params[:page]).per(5)
    
    respond_to do |format|
      format.html
    end
  end
  
  def show
    @broadcast = Broadcast.find(params[:id])
    
    respond_to do |format|
      format.html
    end
  end
  
  def new
    @broadcast = Broadcast.new
    
    respond_to do |format|
      format.html
    end
  end
  
  def create
    @attr = params[:broadcast]
    @attr.merge!(:author => current_user.id)
    @broadcast = Broadcast.new(params[:broadcast])
    
    respond_to do |format|
      if @broadcast.save
        format.html { redirect_to @broadcast }
      else
        format.html { render action: 'new' } 
      end
    end
  end
  
  def edit
    @broadcast = Broadcast.find(params[:id])
  end
  
  def update
    @attr = params[:broadcast]
    @broadcast = Broadcast.find(params[:id])
    
    respond_to do |format|
      if @broadcast.update_attributes(@attr)
        format.html { redirect_to @broadcast }
      else
        flash.now[:alert] = @broadcast.errors.full_messages
        format.html { render action: 'edit' }
      end
    end
  end
  
  def destroy
    @broadcast = Broadcast.find(params[:id])
    @broadcast.destroy
    
    respond_to do |format|
      format.html { redirect_to broadcasts_url }
    end
  end
  
  def blogs
    @broadcasts = Broadcast.unscoped.order('created_at DESC').page(params[:page]).per(5)
    
    respond_to do |format|
      format.html { render :index }
    end
  end
end
