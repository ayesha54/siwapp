class InvoicesController < CommonsController
  VALID_EMAIL_REGEX = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  def show
    # Shows the template in an iframe
    if @invoice.get_status != :paid
      # Redirect to edit if invoice not closed
      redirect_to action: :edit
    else
      render
    end
  end

  def import
    workbook = RubyXL::Parser.parse(params[:excel].path)
    worksheet = workbook.worksheets[0]
    if Series.first == nil
      s = Series.new
      s.name = 'tmp'
      s.value = 1
      s.save
    end
    if Category.first == nil
      r = Category.new
      r.name = "tmp"
      r.save
    end
    worksheet.sheet_data.rows.each do |row|
      next if row[0].value == "INVOICE #"
      break if row[0].value.blank?
      c = Invoice.new
      c.name = row[1].value
      c.issue_date = DateTime.strptime(row[4].value.to_s[0..9], '%Y-%m-%d')
      c.due_date = DateTime.strptime(row[5].value.to_s[0..9], '%Y-%m-%d')
      c.pay_method_1 = row[7].value
      c.pay_method_2 = row[9].value
      c.identification = 1
      c.series_id = 1
      c.net_amount = row[6].value
      c.gross_amount = row[6].value
      c.save

      ci = Item.new
      b = Inventory.new
      logger.debug row[6].value/(c.due_date.mjd - c.issue_date.mjd)
      b.price = row[6].value.to_f/(c.due_date.mjd - c.issue_date.mjd).to_f
      b.category_id = 1
      b.name = "tmp"
      b.save
      ci.inventory_id = b.id
      ci.category_id = b.category_id
      ci.net_amount = row[6].value
      ci.extra = row[8].value
      ci.common_id = c.id
      ci.quantity = c.due_date.mjd - c.issue_date.mjd
      ci.unitary_cost = row[6].value/ci.quantity
      ci.discount = 0
      ci.save

      pay_invoice = Payment.new
      pay_invoice.invoice_id = c.id
        
      pay_invoice.amount = row[6].value
      pay_invoice.date = c.due_date
      pay_invoice.save!
    end
    redirect_to "/invoices"
  end

  def update
    @invoice = Invoice.where(id: params[:id]).first
    @invoice.name = params[:invoice][:name]
    @invoice.identification = params[:invoice][:identification]
    @invoice.contact_person = params[:invoice][:contact_person]
    @invoice.email = params[:invoice][:email]
    @invoice.invoicing_address = params[:invoice][:invoicing_address]
    @invoice.shipping_address = params[:invoice][:shipping_address]
    @invoice.terms = params[:invoice][:terms]
    @invoice.notes = params[:invoice][:notes]
    @invoice.currency = params[:invoice][:currency]
    @invoice.series_id = params[:invoice][:series_id]
    @invoice.issue_date = params[:invoice][:issue_date]
    @invoice.due_date = params[:invoice][:due_date]
    @invoice.email_template_id = params[:invoice][:email_template_id]
    @invoice.print_template_id = params[:invoice][:print_template_id]
    @invoice.save!

    Item.where(common_id: params[:id]).destroy_all
    items = params[:invoice][:items_attributes]
    tmparr = items.to_s.split('}, "')
    total = 0
    tmparr.each do |str|
      id = str.to_i
      item = Item.new
      item.common_id = @invoice.id
      item.category_id = params[:invoice][:items_attributes][id.to_s][:category_id]
      item.inventory_id = params[:invoice][:items_attributes][id.to_s][:inventory_id].to_s.split("_")[1]
      item.quantity = params[:invoice][:items_attributes][id.to_s][:quantity]
      item.unitary_cost = params[:invoice][:items_attributes][id.to_s][:unitary_cost]
      item.discount = params[:invoice][:items_attributes][id.to_s][:discount]
      item.net_amount = params[:invoice][:items_attributes][id.to_s][:net_amount]
      total += item.net_amount.to_i
      item.save!
      params[:invoice][:items_attributes][id.to_s][:tax_ids].each do |val|
        if val.present?
          c = ItemsTax.new
          c.item_id = item.id
          c.tax_id = val.split('_')[0]
          c.save!
        end
      end
    end
    @invoice.gross_amount = total
    @invoice.save!

    Payment.where(invoice_id: @invoice.id).destroy_all
    pay = params[:invoice][:payments_attributes]
    if pay 
      tmparr = pay.to_s[2..-1].split('}, "')
      tmparr.each do |str|
        id = str.to_i
        pay_invoice = Payment.new
        pay_invoice.invoice_id = @invoice.id
        
        pay_invoice.amount = params[:invoice][:payments_attributes][id.to_s][:amount]
        pay_invoice.notes = params[:invoice][:payments_attributes][id.to_s][:notes]
        pay_invoice.date = params[:invoice][:payments_attributes][id.to_s][:date]
        pay_invoice.save!
      end
    end

    redirect_to redirect_address("invoices")
  end

  def update_content
    logger.debug(params[:id])
    item = Item.where(common_id: params[:id])
    inven = []
    item.each do |i|
      inven << Inventory.where(id: i.inventory_id).first.value_id
    end
    respond_to do |format|
      msg = { :data => inven}
      format.json  { render :json => msg }
    end
  end

  def edit
    @invoice = Invoice.where(id: params[:id]).first
    ids = Item.where(common_id: @invoice.id).pluck(:inventory_id)
    ids2 = Item.where(common_id: @invoice.id).pluck(:category_id)
    @templates = Template.where(template_type: "invoice")
    @inventories = Inventory.where(id: ids)
    # @category = Category.where(id: ids2)
    # logger.debug "qwe123 #{@category}"
    # @invoice.items = nil
    # Item.where(common_id: @invoice.id).each do |item|
    #   @invoice.items << item
    # end
    # put an empty item
    # @invoice.items << Item.new(common: @invoice, taxes: Tax.default)
    render
  end

  def is_valid_email? email
    email =~ VALID_EMAIL_REGEX
  end

  def create
    path = "/invoices"
    if Invoice.where(name: params[:invoice][:name]).first
      flash[:alert] = "Invoice name has already existed"
      path = "/invoices/new"
    elsif !is_valid_email? params[:invoice][:email]
      flash[:alert] = "Email is invalid"
      path = "/invoices/new"
    else
      @invoice = Invoice.new
      @invoice.name = params[:invoice][:name]
      @invoice.identification = params[:invoice][:identification]
      @invoice.contact_person = params[:invoice][:contact_person]
      @invoice.email = params[:invoice][:email]
      @invoice.invoicing_address = params[:invoice][:invoicing_address]
      @invoice.shipping_address = params[:invoice][:shipping_address]
      @invoice.terms = params[:invoice][:terms]
      @invoice.notes = params[:invoice][:notes]
      @invoice.currency = params[:invoice][:currency]
      @invoice.series_id = params[:invoice][:series_id]
      @invoice.issue_date = params[:invoice][:issue_date]
      @invoice.due_date = params[:invoice][:due_date]
      @invoice.email_template_id = params[:invoice][:email_template_id]
      @invoice.print_template_id = params[:invoice][:print_template_id]
      @invoice.save!

      items = params[:invoice][:items_attributes]
      tmparr = items.to_s.split('}, "')
      total = 0
      tmparr.each do |str|
        id = str.to_i
        item = Item.new
        item.common_id = @invoice.id
        item.category_id = params[:invoice][:items_attributes][id.to_s][:category_id]
        item.inventory_id = params[:invoice][:items_attributes][id.to_s][:inventory_id].to_s.split("_")[1]
        item.quantity = params[:invoice][:items_attributes][id.to_s][:quantity]
        item.unitary_cost = params[:invoice][:items_attributes][id.to_s][:unitary_cost]
        item.discount = params[:invoice][:items_attributes][id.to_s][:discount]
        item.net_amount = params[:invoice][:items_attributes][id.to_s][:net_amount]
        total += item.net_amount.to_i
        item.save!
        params[:invoice][:items_attributes][id.to_s][:tax_ids].each do |val|
          if val.present?
            c = ItemsTax.new
            c.item_id = item.id
            c.tax_id = val.split('_')[0]
            c.save!
          end
        end
      end
      @invoice.gross_amount = total
      @invoice.save!
    end
    
    redirect_to path
  end

  # GET /invoices/new
  def new
    @inventories = Inventory.all
    @invoice = Invoice.new
    # put an empty item
    @templates = Template.where(template_type: "invoice")
    @invoice.items << Item.new(common: @invoice, taxes: Tax.default)
    render
  end

  # GET /invoices/autocomplete.json
  # View to get the item autocomplete feature.
  def autocomplete
    @items = Item.autocomplete_by_description(params[:term])
    respond_to do |format|
      format.json
    end
  end

  # GET /invoices/chart_data.json
  # Returns a json with dates as keys and sums of the invoices
  # as values. Uses the same parameters as search.
  def chart_data
    date_from = (params[:q].nil? or params[:q][:issue_date_gteq].empty?) ? 30.days.ago.to_date : Date.parse(params[:q][:issue_date_gteq])
    date_to = (params[:q].nil? or params[:q][:issue_date_lteq].empty?) ? Date.current : Date.parse(params[:q][:issue_date_lteq])

    scope = @search.result.where(draft: false, failed: false).\
      where("issue_date >= :date_from AND issue_date <= :date_to",
            {date_from: date_from, date_to: date_to})
    scope = scope.tagged_with(params[:tags].split(/\s*,\s*/)) if params[:tags].present?
    scope = scope.select('issue_date, sum(gross_amount) as total').group('issue_date')

    # build all keys with 0 values for all
    @date_totals = {}

    (date_from..date_to).each do |day|
      @date_totals[day.to_formatted_s(:db)] = 0
    end

    scope.each do |inv|
      @date_totals[inv.issue_date.to_formatted_s(:db)] = inv.total
    end

    render
  end

  def send_email
    @invoice = Invoice.find(params[:id])
    begin
      @invoice.send_email
      redirect_back(fallback_location: root_path, notice: 'Email successfully sent.')
    rescue Exception => e
      redirect_back(fallback_location: root_path, alert: e.message)
    end
  end

  def excel
    @invoice = Invoice.where(id: params[:id])
	  respond_to do |format|
	    format.html
	    format.xls { send_data @invoice.to_xls(col_sep: "\t") }
	  end
  end

  # Renders a common's template in html and pdf formats
  def print
    @invoice = Invoice.find(params[:id])
    html = render_to_string :inline => @invoice.get_print_template.template,
      :locals => {:invoice => @invoice, :settings => Settings}
    respond_to do |format|
      format.html { render inline: html }
      format.pdf do
        pdf = @invoice.pdf(html)
        send_data(pdf,
          :filename    => "#{@invoice}.pdf",
          :disposition => 'attachment'
        )
      end
    end
  end

  # Bulk actions for the invoices listing
  def bulk
    ids = params["#{model.name.underscore}_ids"]
    if ids.is_a?(Array) && ids.length > 0
      invoices = Invoice.where(id: params["#{model.name.underscore}_ids"])
      case params['bulk_action']
      when 'delete'
        invoices.destroy_all
        flash[:info] = "Successfully deleted #{ids.length} invoices."
      when 'send_email'
        begin
          invoices.each {|inv| inv.send_email}
          flash[:info] = "Successfully sent #{ids.length} emails."
        rescue Exception => e
          flash[:alert] = e.message
        end
      when 'set_paid'
        total = invoices.inject(0) do |n, inv|
          inv.set_paid! ? n + 1 : n
        end
        flash[:info] = "Successfully set as paid #{total} invoices."
      when 'pdf'
        html = ''
        invoices.each do |inv|
          @invoice = inv
          html += render_to_string \
              :inline => inv.get_print_template.template,
              :locals => {:invoice => @invoice,
                          :settings => Settings}
          html += '<div class="page-break" style="page-break-after:always;"></div>'
        end
        send_data(@invoice.pdf(html),
          :filename => "invoices.pdf",
          :disposition => 'attachment'
        )
        return
      when 'duplicate'
        invoices.each do |inv|
          inv.duplicate
        end
        flash[:info] = "Successfully copy #{invoices.length} invoices."
      else
        flash[:info] = "Unknown action."
      end
    end
    redirect_to action: :index
  end

  protected

  def set_listing(instances)
    @invoices = instances
  end

  def set_instance(instance)
    @invoice = instance
  end

  def get_instance
    @invoice
  end

  def invoice_params
    common_params + [
      :number,
      :issue_date,
      :due_date,

      :email_template_id,
      :print_template_id,

      :failed,

      payments_attributes: [
        :id,
        :date,
        :amount,
        :notes,
        :_destroy
      ]
    ]
  end
end
