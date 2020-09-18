class AddTwoThousandTwentyToNtdInfrastructure < ActiveRecord::Migration[5.2]
  def change
    add_column :ntd_infrastructures, :two_thousand_twenty, :string, after: :two_thousand_ten
  end
end
