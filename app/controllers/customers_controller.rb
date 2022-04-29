class CustomersController < ApplicationController
  VALID_EMAIL_REGEX = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  skip_before_action :verify_authenticity_token, :only => [:import]
  include MetaAttributesControllerMixin
  include ApplicationHelper
  require 'rubyXL'
  require 'rubyXL/convenience_methods/cell'
  require 'rubyXL/convenience_methods/color'
  require 'rubyXL/convenience_methods/font'
  require 'rubyXL/convenience_methods/workbook'
  require 'rubyXL/convenience_methods/worksheet'

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
    @customer.customer_items << CustomerItem.new(customer: @customer)
    @templates = Template.where(template_type: "customer")
    render
  end

  # GET /customers/1/edit
  def edit
    @customer = Customer.where(id: params[:id]).first
    ci = CustomerItem.where(customer_id: params[:id])
    @rooms = Room.where(id: ci.pluck(:room_id))
    @beds = Bed.where(room_id: ci.pluck(:room_id))
    @templates = Template.where(template_type: "customer")
    render
  end

  def update_content
    ci = CustomerItem.where(customer_id: params[:id])
    meal = Customer.where(id: params[:id]).first.meal
    tax = []
    ci.each do |x|
      t = Tax.where(id: x.customer_item_tax.pluck(:tax_id))
      temp = []
      t.each do |tmp|
        temp << tmp.value_id
      end
      tax << temp
    end
    respond_to do |format|
      msg = { :data => ci, :tax => tax, :meal => meal}
      format.json  { render :json => msg }
    end
  end

  def update_cost
    b = Bed.where(id: params[:bed_id]).first
    respond_to do |format|
      msg = { :data => b.price }
      format.json  { render :json => msg }
    end
  end

  def is_valid_email? email
    email =~ VALID_EMAIL_REGEX
  end

  # POST /customers
  # POST /customers.json
  def create
    path = "/customers"
    if Customer.where(name: params[:customer][:name].strip).first
      flash[:alert] = "Customer name has already existed"
      path = "/customers/new"
    elsif !is_valid_email? params[:customer][:email]
      flash[:alert] = "Email is invalid"
      path = "/customers/new"
    elsif Customer.where(identification: params[:customer][:identification].strip).first
      flash[:alert] = "Customer identification has already existed"
      path = "/customers/new"
    else
      @customer = Customer.new
      @customer.name = params[:customer][:name]
      @customer.identification = params[:customer][:identification]
      @customer.email = params[:customer][:email]
      @customer.contact_person = params[:customer][:contact_person]
      @customer.invoicing_address = params[:customer][:invoicing_address]
      @customer.shipping_address = params[:customer][:shipping_address]
      @customer.print_template_id = params[:customer][:print_template_id].to_s.to_i
      @customer.email_template_id = params[:customer][:email_template_id].to_s.to_i
      @customer.check_in = params[:customer][:check_in]
      @customer.check_out = params[:customer][:check_out]
      tmp = ""
      params[:customer][:meal].each do |val|
        if val.present?
          meal = Meal.where(name: val).first
          unless meal
            Meal.create(name: val)
          end
          tmp += val + ","
        end
      end
      @customer.meal = tmp
      @customer.save!
      

      # params[:customer][:customer_tax][:tax].each do |val|
      #   if val.present?
      #     tax = CustomerTax.new
      #     tax.customer_id = @customer.id
      #     tax.tax_id = val.to_i
      #     tax.save!
      #   end
      # end

      items = params[:customer][:customer_items_attributes]
      tmparr = items.to_s.split('}, "')
      tmparr.each do |str|
        id = str.to_i
        @customeritem = CustomerItem.new
        @customeritem.customer_id = @customer.id
        @customeritem.room_id = params[:customer][:customer_items_attributes][id.to_s][:room_id]
        @customeritem.bed_id = params[:customer][:customer_items_attributes][id.to_s][:bed_id].to_s.split("_")[0]
        @customeritem.quantity = params[:customer][:customer_items_attributes][id.to_s][:quantity]
        @customeritem.discount = params[:customer][:customer_items_attributes][id.to_s][:discount] || 0
        @customeritem.unitary_cost = params[:customer][:customer_items_attributes][id.to_s][:unitary_cost]
        @customeritem.net_amount = params[:customer][:customer_items_attributes][id.to_s][:net_amount]
        @customeritem.room_number = params[:customer][:customer_items_attributes][id.to_s][:room_number]
        @customeritem.quantity_bed = params[:customer][:customer_items_attributes][id.to_s][:quantity_bed]
        @customeritem.bed_number = params[:customer][:customer_items_attributes][id.to_s][:bed_number]
        @customeritem.save!
        params[:customer][:customer_items_attributes][id.to_s][:tax_ids].each do |val|
          if val.present?
            c = CustomerItemTax.new
            c.customer_item_id = @customeritem.id
            c.tax_id = val.split('_')[0]
            c.save!
          end
        end
      end
      @customer.save
    end
    
    redirect_to path
  end

  # PATCH/PUT /customers/1
  # PATCH/PUT /customers/1.json
  def update
    @customer = Customer.where(id: params[:id]).first
    @customer.name = params[:customer][:name]
    @customer.identification = params[:customer][:identification]
    @customer.email = params[:customer][:email]
    @customer.contact_person = params[:customer][:contact_person]
    @customer.invoicing_address = params[:customer][:invoicing_address]
    @customer.shipping_address = params[:customer][:shipping_address]
    @customer.print_template_id = params[:customer][:print_template_id].to_s.to_i
    @customer.email_template_id = params[:customer][:email_template_id].to_s.to_i

    tmp = ""
    params[:customer][:meal].each do |val|
      if val.present?
        meal = Meal.where(name: val).first
        unless meal
          Meal.create(name: val)
        end
        tmp += val + ","
      end
    end
    @customer.meal = tmp
    @customer.save!

    # CustomerTax.where(customer_id: params[:id]).destroy_all
    # params[:customer][:customer_tax][:tax].each do |val|
    #   if val.present?
    #     tax = CustomerTax.new
    #     tax.customer_id = @customer.id
    #     tax.tax_id = val.to_i
    #     tax.save!
    #   end
    # end

    CustomerItem.where(customer_id: params[:id]).destroy_all

    items = params[:customer][:customer_items_attributes]
    tmparr = items.to_s.split('}, "')
    tmparr.each do |str|
      id = str.to_i
      @customeritem = CustomerItem.new
      @customeritem.customer_id = @customer.id
      @customeritem.room_id = params[:customer][:customer_items_attributes][id.to_s][:room_id]
      @customeritem.bed_id = params[:customer][:customer_items_attributes][id.to_s][:bed_id].to_s.split("_")[0]
      @customeritem.quantity = params[:customer][:customer_items_attributes][id.to_s][:quantity]
      @customeritem.discount = params[:customer][:customer_items_attributes][id.to_s][:discount] || 0
      @customeritem.unitary_cost = params[:customer][:customer_items_attributes][id.to_s][:unitary_cost]
      @customeritem.net_amount = params[:customer][:customer_items_attributes][id.to_s][:net_amount]
      @customeritem.room_number = params[:customer][:customer_items_attributes][id.to_s][:room_number]
      @customeritem.quantity_bed = params[:customer][:customer_items_attributes][id.to_s][:quantity_bed]
      @customeritem.bed_number = params[:customer][:customer_items_attributes][id.to_s][:bed_number]
      @customeritem.save!
      CustomerItemTax.where(customer_item_id: @customeritem.id).destroy_all
      params[:customer][:customer_items_attributes][id.to_s][:tax_ids].each do |val|
        if val.present?
          c = CustomerItemTax.new
          c.customer_item_id = @customeritem.id
          c.tax_id = val.split('_')[0]
          c.save!
        end
      end
    end

    PaymentsCustomer.where(customer_id: @customer.id).destroy_all
    pay = params[:customer][:payments_customer_attributes]
    if pay 
      tmparr = pay.to_s[2..-1].split('}, "')
      tmparr.each do |str|
        id = str.to_i
        pay_customer = PaymentsCustomer.new
        pay_customer.customer_id = @customer.id
        
        pay_customer.amount = params[:customer][:payments_customer_attributes][id.to_s][:amount]
        pay_customer.notes = params[:customer][:payments_customer_attributes][id.to_s][:notes]
        pay_customer.date = params[:customer][:payments_customer_attributes][id.to_s][:date]
        pay_customer.save!
      end
    end
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

  # def send_email
  #   @customer = Customer.find(params[:id])
  #   begin
  #     @customer.send_email
  #     redirect_back(fallback_location: root_path, notice: 'Email successfully sent.')
  #   rescue Exception => e
  #     redirect_back(fallback_location: root_path, alert: e.message)
  #   end
  # end

  def print
    @customer = Customer.find(params[:id])
    if @customer.customer_items.first
      @room = Room.where(id: @customer.customer_items.first.room_id).first
      @bed = Bed.where(id: @customer.customer_items.first.bed_id).first
      net = @bed.price * (@customer.check_out.mjd - @customer.check_in.mjd)
      html = render_to_string :inline => @customer.get_print_template.template,
        :locals => {:customer => @customer, :settings => Settings, :room => @room, :bed => @bed}
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
    else
      html = render_to_string :inline => @customer.get_print_template.template,
        :locals => {:customer => @customer, :settings => Settings, :sc => 0, :g => 0, :net => 0}
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
  end

  def excel_show

  end

  def import
    workbook = RubyXL::Parser.parse(params[:excel].path)
    worksheet = workbook.worksheets[0]
    worksheet.sheet_data.rows.each do |row|
      next if row[0].value == "INVOICE #"
      break if row[0].value.blank?
      c = Customer.new
      c.name = row[1].value
      logger.debug row[4].value.to_s[0..9]
      c.check_in = DateTime.strptime(row[4].value.to_s[0..9], '%Y-%m-%d')
      c.check_out = DateTime.strptime(row[5].value.to_s[0..9], '%Y-%m-%d')
      c.pay_method_1 = row[7].value
      c.pay_method_2 = row[9].value
      c.save

      ci = CustomerItem.new
      b = Bed.where(id: row[2].value).first
      if b == nil 
        count = row[2].value - Bed.count
        if Room.first == nil
          r = Room.new
          r.name = "tmp"
          r.save
        end
        count.times do 
          tmp = Bed.new
          tmp.price = 1
          tmp.room_id = 1
          tmp.name = "tmp"
          tmp.save
        end
        b = Bed.where(id: row[2].value).first
      end
      ci.bed_id = b.id
      ci.room_id = b.room_id
      ci.net_amount = row[6].value
      ci.extra = row[8].value
      ci.customer_id = c.id
      ci.quantity = c.check_out.mjd - c.check_in.mjd
      ci.quantity_bed = 1
      ci.unitary_cost = ci.net_amount/ci.quantity
      ci.discount = 0
      ci.save
    end
  end

  def excel
    @customer = Customer.where(id: params[:id])
    workbook = RubyXL::Parser.parse("app/assets/template/Template.xlsx")
    worksheet = workbook.worksheets[0]
    i = 1
    @customer.each do |c|
      sub = c.net_amount/1.232
      sc = sub*0.1
      gst = (sub+sc)*0.12
      worksheet.add_cell(i, 0, c.id)
      worksheet.add_cell(i, 1, c.name)
      worksheet.add_cell(i, 3, "Q#{current_quarter_months(c.check_in)}-#{c.check_in.year}")
      worksheet.add_cell(i, 4, c.check_in.to_s)
      worksheet.add_cell(i, 5, c.check_out.to_s)
      worksheet.add_cell(i, 6, c.net_amount)
      worksheet.add_cell(i, 8, 0)
      worksheet.add_cell(i, 10, c.net_amount)
      worksheet.add_cell(i, 11, sub)
      worksheet.add_cell(i, 12, sc)
      worksheet.add_cell(i, 13, gst)
      worksheet.add_cell(i, 14, gst+sc+sub)
      i = i + 1
    end
    workbook.write("app/assets/template/download/excel.xlsx")

	  respond_to do |format|
	    format.html
	    format.xls { send_file("app/assets/template/download/excel.xlsx",
                  :filename => "client-suggested-filename.xlsx",
                  :type => "mime/type") }
	  end
  end

  def get_by_identification
    mess = false
    c = Customer.where(identification: params[:id]).first
    mess = true if c != nil
    respond_to do |format|
      msg = { :data => c, :mess => mess}
      format.json  { render :json => msg }
    end
  end

  def current_quarter_months(date)
    (date.month/3.0).ceil
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
                                          :description, :net_amount, :unitary_cost, :customer_id, :_destroy])
    end

    def set_tags
      @tags = tags_for('Customer')
    end

    def template
      @templates = Template.all
    end
end
