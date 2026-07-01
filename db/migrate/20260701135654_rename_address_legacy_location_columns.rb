# Adding belongs_to :city and belongs_to :state creates association writers
# (city=, state=) that shadow the existing string columns of the same name.
# Renaming them to city_name / state_name eliminates the collision and makes
# the dual-track intent explicit: city_id is the FK reference, city_name is the
# legacy freeform string from external APIs.
class RenameAddressLegacyLocationColumns < ActiveRecord::Migration[8.1]
  def change
    rename_column :addresses, :city,  :city_name
    rename_column :addresses, :state, :state_name
  end
end
