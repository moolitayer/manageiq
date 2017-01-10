require_migration

describe AddEmsToMiqAlertStatus do
  let(:vm_stub) { migration_stub(:Vm) }
  let(:miq_alert_status_stub) { migration_stub(:MiqAlertStatus) }
  let(:ext_management_system_stub) { migration_stub(:ExtManagementSystem) }

  migration_context :up do
    it 'it sets ems_id for vms' do
      ext = ext_management_system_stub.create!(:id => 99)
      vm = vm_stub.create!(:ext_management_system => ext)
      puts "vm_id: #{vm.id}"
      miq_alert_status = miq_alert_status_stub.create!(:resource_id => vm.id, :resource_type => 'Vm')
      migrate
      expect(miq_alert_status.reload.ems_id).to eq(99)
    end
  end
end
