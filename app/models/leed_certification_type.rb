#------------------------------------------------------------------------------
#
# LeedCertificationType
#
# Lookup Table for LEED certification types.
#
#------------------------------------------------------------------------------

class LeedCertificationType < ActiveRecord::Base

  # All types that are available
  scope :active, -> { where(:active => true) }

  def to_s
    name
  end

  ######## API Serializer ##############
  def api_json(options={})
    {
      id: id,
      name: name,
      description: description
    }
  end

end
