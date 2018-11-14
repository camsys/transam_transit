class AddStartOfNtdFiscalYearSystemConfig < ActiveRecord::Migration[5.2]
  def change
    add_column :system_configs, :start_of_ntd_fiscal_year, :string, limit: 5, after: :start_of_fiscal_year
  end
end
