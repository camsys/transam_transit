class IncreaseLimitFtaFundingTypesCode < ActiveRecord::Migration
  def change
    change_column :fta_funding_types, :code, :string, limit: 6
  end
end
