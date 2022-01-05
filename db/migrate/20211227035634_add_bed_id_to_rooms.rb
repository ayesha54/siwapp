class AddBedIdToRooms < ActiveRecord::Migration[5.2]
  def change
    add_reference :rooms, :bed, foreign_key: true
  end
end
