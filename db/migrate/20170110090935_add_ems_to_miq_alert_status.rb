class AddEmsToMiqAlertStatus < ActiveRecord::Migration[5.0]
  class MiqAlertStatus < ActiveRecord::Base;
    belongs_to :resource, :polymorphic => true
  end

  class ExtManagementSystem < ActiveRecord::Base
    self.inheritance_column = :_type_disabled # disable STI
    has_many :vms, :class_name => "AddEmsToMiqAlertStatus::Vm"
  end

  class Vm < ActiveRecord::Base
    self.inheritance_column = :_type_disabled # disable STI
    belongs_to :ext_management_system, :class_name => "AddEmsToMiqAlertStatus::ExtManagementSystem",
               :foreign_key => :ems_id
    has_many :miq_alert_statuses, :class_name => "AddEmsToMiqAlertStatus::MiqAlertStatus", :as => :resource
  end

  def up
    add_column :miq_alert_statuses, :ems_id, :bigint
    say_with_time("add ems_id to miq alert statuses") do
      MiqAlertStatus.all.each do |mas|
        target = mas.resource_type.constantize.find(mas.resource_id)
        mas.update_attribute(:ems_id,  target.try(:ext_management_system))
      end
    end
  end

  def down
    remove_column :miq_alert_statuses, :ems_id
  end
end
