class RemoveRoomIdFromBed < ActiveRecord::Migration[5.2]
  def change
    remove_reference :beds, :room, foreign_key: true
    remove_column :beds, :price, :decimal
  end
end
