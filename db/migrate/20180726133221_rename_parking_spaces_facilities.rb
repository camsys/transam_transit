class RenameParkingSpacesFacilities < ActiveRecord::Migration[5.2]
  def change

    rename_column :facilities, :num_public_parking, :num_parking_spaces_public
    rename_column :facilities, :num_private_parking, :num_parking_spaces_private

  end
end
