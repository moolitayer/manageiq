class MiqAlertStatus < ApplicationRecord
  belongs_to :miq_alert
  belongs_to :resource, :polymorphic => true
  belongs_to :ext_management_system
end
