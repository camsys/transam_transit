class TeamAliCode < ActiveRecord::Base
  # Add the nested set behavior to this model so it becomes a tree
  acts_as_nested_set

  # Allow selection of active instances
  scope :active, -> { where(:active => true) }

  scope :all_categories,  -> { where("code REGEXP '[1-4]{2}.[1-9]{2}.XX'") }
  scope :categories,      -> { where("code REGEXP '1[1-2].[1-9]X.XX'") }
  scope :bus_categories,  -> { where("code REGEXP '11.[1-9]X.XX'") }
  scope :rail_categories, -> { where("code REGEXP '12.[1-9]X.XX'") }
  scope :top_level_categories, -> { where("code REGEXP '[1-4]{2}.XX.XX'") }

  # Render the asset as a JSON object -- overrides the default json encoding
  def as_json(options={})
    super.merge(
    {
      :full_name => self.full_name,
      :description => self.description,
      :context => self.context,
      :scope => self.scope
    })
  end

  def full_name
    "#{code} #{name}"
  end

  def full_name_with_parent
    "#{code} #{parent.try(:name)} #{name}"
  end

  def description(join_str = '->')
    a = []
    a << context(join_str)
    a << "#{name} (#{code})"
    a.join(join_str)
  end

  def to_s
    code
  end

  def grandchildren
    children.map{ |c| c.children }.flatten.uniq
  end

  # Return the context for a code. The context is the predecessors as a string
  def context(join_str = '->')
    a = []
    x = self
    while x.parent
      x = x.parent
      a << x.name
    end
    a.reverse.join(join_str)
  end

  def scope
    elems = code.split('.')
    "#{elems[0]}#{elems[1].first}"
  end

  def type
    code.split('.')[0]
  end

  def category
    code.split('.')[1]
  end

  def sub_category
    code.split('.')[2]
  end

  def type_and_category
    elems = code.split('.')
    "#{elems[0]}.#{elems[1]}"
  end

  # Returns true if this is a bus code
  def bus_code?
    (code[1] == '1')
  end

  def rail_code?
    (code[1] == '2')
  end

  # Returns true if the ALI is a replacement code
  def replacement_code?
    ['12', '16'].include? category
  end

  # Returns true if the ALI is a rehabilitation code
  def rehabilitation_code?
    ['14', '15', '17', '24', '34', '44', '54', '64 '].include? category
  end

  # Returns true if the ALI is an expansion code
  def expansion_code?
    ['13', '18'].include? category
  end

  # Returns true if the ALI requires one or more vehicles to be deliverd
  # categories XX.12.XX, XX.13.XX, XX.16.XX, XX.18.XX
  def is_vehicle_delivery?
    ['12', '13', '16', '18'].include? category
  end

  def rolling_stock?
     ['111'].include? scope
  end

  def dotgrants_json
    {code: code}
  end
end
