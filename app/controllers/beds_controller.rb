class BedsController < ApplicationController
  # GET method to get all Beds from database   
  def index   
    @beds = Bed.all.paginate(page: params[:page], per_page: 20)
  end   
   
  # GET method to get a Bed by id   
  def show   
    @bed = Bed.find(params[:id])   
  end   
   
  # GET method for the new Bed form   
  def new   
    @bed = Bed.new   
  end   
   
  # POST method for processing form data   
  def create   
    @bed = Bed.new(bed_params)   
    if @bed.save!
      flash[:notice] = 'Bed added!'   
      redirect_to bed_path
    else   
      flash[:error] = 'Failed to edit Bed!'   
      render :new   
    end   
  end   
   
   # GET method for editing a Bed based on id   
  def edit   
    @bed = Bed.find(params[:id])   
  end   
   
  # PUT method for updating in database a Bed based on id   
  def update   
    bed = Bed.find(params[:id])   
    if bed.update_attributes(bed_params)   
      flash[:notice] = 'Bed updated!'   
      redirect_to beds_path
    else   
      flash[:error] = 'Failed to edit Bed!'   
      render :edit   
    end   
  end   
   
  # DELETE method for deleting a Bed from database based on id   
  def destroy   
    bed = Bed.find(params[:id])
    @room_count = Room.where(bed_id: bed.id).count
    if @room_count <= 0 && bed.delete
      flash[:notice] = 'Bed deleted!'
      redirect_to beds_path
    else   
      flash[:error] = 'Failed to delete this Bed!'   
      redirect_to beds_path   
    end   
  end

  # we used strong parameters for the validation of params   
  def bed_params   
    params.require(:bed).permit(:name, :price, :room_id)   
  end
end
