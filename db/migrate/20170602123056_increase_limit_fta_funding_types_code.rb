class IncreaseLimitFtaFundingTypesCode < ActiveRecord::Migration[4.2]
  def change
    change_column :fta_funding_types, :code, :string, limit: 6
  end
end
