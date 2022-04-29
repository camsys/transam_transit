class RtaOrgCredential < ApplicationRecord

  belongs_to :organization

  validates :rta_client_id, presence: true
  validates :rta_client_secret, presence: true
  validates :rta_tenant_id, presence: true
  validates :name, presence: true, uniqueness: {scope: :organization}

  FORM_PARAMS = [
    :id,
    :rta_client_id,
    :rta_client_secret,
    :rta_tenant_id,
    :name,
    :_destroy
  ]

  def self.allowable_params
    FORM_PARAMS
  end
end
