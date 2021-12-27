class RoomsController < ApplicationController

  def index   
    @rooms = Room.all.paginate(page: params[:page], per_page: 20)
  end   
   
  # GET method to get a Room by id   
  def show   
    @room = Room.find(params[:id])   
  end   
   
  # GET method for the new Room form   
  def new   
    @room = Room.new   
  end   
   
  # POST method for processing form data   
  def create   
    @room = Room.new(room_params)   
    if @room.save   
      flash[:notice] = 'Room added!'   
      redirect_to rooms_path
    else   
      flash[:error] = 'Failed to edit Room!'   
      render :new   
    end   
  end   
   
   # GET method for editing a Room based on id   
  def edit   
    @room = Room.find(params[:id])   
  end   
   
  # PUT method for updating in database a Room based on id   
  def update   
    @room = Room.find(params[:id])   
    if @room.update_attributes(room_params)   
      flash[:notice] = 'Room updated!'   
      redirect_to rooms_path
    else
      flash[:error] = 'Failed to edit Room!'   
      render :edit   
    end   
  end

  def update_Room
    @rooms = Room.where("bed_id = ?", params[:bed_id])
    @select_id = params[:select_id]
    respond_to do |format|
      format.js
    end
  end
   
  # DELETE method for deleting a Room from database based on id   
  def destroy   
    room = Room.find(params[:id])   
    respond_to do |format|  
      if room.destroy
        format.html {redirect_to rooms_path, notice: 'Room was successfully destroyed.' }
      else
        format.html { render :edit }
      end
    end
  end

  # we used strong parameters for the validation of params   
  def room_params   
    params.require(:room).permit(:name)   
  end
end
