class InventoriesController < ApplicationController

  DISPLAY_PER_PAGE = 10

  def index   
    @inventories = Inventory.all.paginate(page: params[:page], per_page: DISPLAY_PER_PAGE)
    @total_page = (Inventory.count.to_f / DISPLAY_PER_PAGE.to_f).ceil
    @page = params[:page].to_i
  end   
   
  # GET method to get a Inventory by id   
  def show   
    @inventory = Inventory.find(params[:id])   
  end   
   
  # GET method for the new Inventory form   
  def new   
    @inventory = Inventory.new   
  end   
   
  # POST method for processing form data   
  def create   
    @inventory = Inventory.new(inventory_params)   
    if @inventory.save   
      flash[:notice] = 'Inventory added!'   
      redirect_to inventories_path
    else   
      flash[:error] = 'Failed to edit Inventory!'   
      render :new   
    end   
  end   
   
   # GET method for editing a Inventory based on id   
  def edit   
    @inventory = Inventory.find(params[:id])   
  end   
   
  # PUT method for updating in database a Inventory based on id   
  def update   
    @inventory = Inventory.find(params[:id])   
    if @inventory.update_attributes(inventory_params)   
      flash[:notice] = 'Inventory updated!'   
      redirect_to inventories_path
    else
      flash[:error] = 'Failed to edit Inventory!'   
      render :edit   
    end   
  end

  def update_inventory
    @inventories = Inventory.where("category_id = ?", params[:category_id])
    @select_id = params[:select_id]
    puts "============#{@select_id}"
    respond_to do |format|
      format.js
    end
  end
   
  # DELETE method for deleting a Inventory from database based on id   
  def destroy   
    @inventory = Inventory.find(params[:id])   
    respond_to do |format|  
      if @inventory.destroy
        format.html {redirect_to inventories_path, notice: 'Inventory was successfully destroyed.' }
      else
        format.html { render :edit }
      end
    end
  end

  # we used strong parameters for the validation of params   
  def inventory_params   
    params.require(:inventory).permit(:name, :price, :category_id)   
  end
end
