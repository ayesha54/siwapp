class ItemsController < ApplicationController

	# GET /items/amount
  #
  # Calculates the net amount for an item
  def amount
    unitary_cost = params[:unitary_cost].present? ? params[:unitary_cost] : 0
    quantity     = params[:quantity].present? ? params[:quantity] : 0
    discount     = params[:discount].present? ? params[:discount] : 0
    item = Item.new(
      unitary_cost: unitary_cost,
      quantity: quantity,
      discount: discount
    )
    @amount = item.net_amount

    respond_to do |format|
      format.json
    end
  end
end
