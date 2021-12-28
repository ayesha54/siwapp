class CustomersController < ApplicationController
  include MetaAttributesControllerMixin
  include ApplicationHelper

  before_action :set_type
  before_action :set_customer, only: [:show, :edit, :update, :destroy]
  before_action :set_tags, only: [:index, :new, :create, :edit, :update, :destroy]
  before_action :template, only: [:new, :edit]

  # GET /customers
  def index
    # To redirect to the index with the current search params
    set_redirect_address(request.original_fullpath, "customers")
    @search = Customer.ransack(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @customers = @search.result
    @customers = @customers.tagged_with(params[:tag_list]) if params[:tag_list].present?

    respond_to do |format|
      format.html do
        @customers = @customers.paginate(page: params[:page],
                                         per_page: 20)
        render :index, layout: 'infinite-scrolling'
      end
      format.csv do
        set_csv_headers('customers.csv')
        self.response_body = Customer.csv @customers
      end
    end
  end

  # GET /customers/1
  def show
    redirect_to action: :edit
  end

  # GET /customers/new
  def new
    @customer = Customer.new
    @rooms = Room.all
    @beds = Bed.where(room_id: Room.first.id)
    @cost = @beds.first.price
    # @customer.customer_items << CustomerItem.new
  end

  # GET /customers/1/edit
  def edit
    @customer = Customer.where(id: params[:id]).first
    ci = CustomerItem.where(customer_id: params[:id]).first
    @rooms = Room.where(id: ci.room_id)
    @beds = Bed.where(room_id: ci.room_id)
    @cost = ci.net_amount
    @quan = ci.quantity
    render
  end

  def update_content
    ci = CustomerItem.where(customer_id: params[:id]).first
    respond_to do |format|
      msg = { :beds => ci.bed_id, :rooms => ci.room_id }
      format.json  { render :json => msg }
    end
  end

  # POST /customers
  # POST /customers.json
  def create
    @customer = Customer.where(name: params[:customer][:name]).first
    unless @customer 
      @customer = Customer.new
      @customer.name = params[:customer][:name]
      @customer.identification = params[:customer][:identification]
      @customer.email = params[:customer][:email]
      @customer.contact_person = params[:customer][:contact_person]
      @customer.invoicing_address = params[:customer][:invoicing_address]
      @customer.shipping_address = params[:customer][:shipping_address]
      @customer.save!
    end

    @customeritem = CustomerItem.new
    @customeritem.customer_id = @customer.id
    @customeritem.room_id = params[:customer][:customer_items][:room_id]
    @customeritem.bed_id = params[:customer][:customer_items][:bed_id].to_s.split("_")[0]
    @customeritem.quantity = params[:customer][:customer_items][:quantity]
    @customeritem.discount = params[:customer][:customer_items][:discount] || 0
    @customeritem.unitary_cost = params[:customer][:customer_items][:unitary_cost]
    @customeritem.net_amount = params[:customer][:customer_items][:net_amount]
    @customeritem.save!

    respond_to do |format|
      if @customer.save
        format.html { redirect_to redirect_address("customers"), notice: 'Customer was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /customers/1
  # PATCH/PUT /customers/1.json
  def update
    respond_to do |format|
      if @customer.update(customer_params)
        set_meta @customer
        # Redirect to index
        format.html { redirect_to redirect_address("customers"), notice: 'Customer was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /customers/1
  # DELETE /customers/1.json
  def destroy
    respond_to do |format|
      if @customer.destroy
        format.html { redirect_to redirect_address("customers"), notice: 'Customer was successfully destroyed.' }
      else
        format.html { render :edit }
      end
    end
  end

  # GET /customers/autocomplete.json
  # View to get the customer autocomplete feature editing invoices.
  def autocomplete
    @customers = Customer.order(:name).where("name ILIKE ? and active = ?", "%#{params[:term]}%", true)
    respond_to do |format|
      format.json
    end
  end

  def send_email
    @customer = Customer.find(params[:id])
    begin
      @customer.send_email
      redirect_back(fallback_location: root_path, notice: 'Email successfully sent.')
    rescue Exception => e
      redirect_back(fallback_location: root_path, alert: e.message)
    end
  end

  def print
    @customer = Customer.find(params[:id])
    html = render_to_string :inline => @customer.get_print_template.template,
      :locals => {:invoice => @customer, :settings => Settings}
    respond_to do |format|
      format.html { render inline: html }
      format.pdf do
        pdf = @customer.pdf(html)
        send_data(pdf,
          :filename    => "#{@customer}.pdf",
          :disposition => 'attachment'
        )
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def customer_params
      params.require(:customer).permit(:name, :identification, :email, :contact_person, :check_in, :check_out, :email_template_id, :print_template_id,
                                       :invoicing_address, :shipping_address, :active, tag_list: [],
                                       customer_items: [:room_id, :bed_id, :quantity, :discount,
                                          :description, :net_amount, :unitary_cost, :customer_id])
    end

    def set_tags
      @tags = tags_for('Customer')
    end

    def template
      @templates = Template.all
    end
end
