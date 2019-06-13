class FtaTypeAssetSubtypeReportRow < BasicReportRow

  attr_accessor :fta_type
  attr_accessor :asset_subtype
  
  def initialize(categorization)
    super(categorization)
    self.fta_type = categorization[0]
    self.asset_subtype = categorization[1]
  end

end
