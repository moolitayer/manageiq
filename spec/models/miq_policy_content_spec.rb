describe MiqPolicyContent do
  describe ".seed" do
    it "should contain conditions" do
      [MiqAction, MiqEventDefinition, MiqPolicy, MiqPolicyContent].each(&:seed)

      specifications = YAML.load_file(File.join(ApplicationRecord::FIXTURE_DIR, "miq_policy_contents.yml"))
      specifications_by_pkey = specifications.index_by do |h|
        "#{h[:miq_policy]}_#{h[:success_sequence]}_#{h[:failure_sequence]}"
      end

      count = 0
      MiqPolicyContent.all.each do |mpc|
        spec = specifications_by_pkey["#{mpc.miq_policy.name}_#{mpc.success_sequence}_#{mpc.failure_sequence}"]
        # Attributes
        expect(mpc.qualifier).to eq(spec[:qualifier])
        expect(mpc.success_sequence).to eq(spec[:success_sequence])
        expect(mpc.success_sequence).to eq(spec[:success_sequence])
        expect(mpc.failure_sequence).to eq(spec[:failure_sequence])
        expect(mpc.success_synchronous).to eq(spec[:success_synchronous])
        expect(mpc.failure_synchronous).to eq(spec[:failure_synchronous])
        # Associations
        expect(mpc.miq_policy.name).to eq(spec[:miq_policy])
        expect(mpc.miq_action.name).to eq(spec[:miq_action])
        expect(mpc.miq_event_definition.name).to eq(spec[:miq_event_definition])
        count += 1
      end
      expect(count).to eq(specifications.size)
    end
  end
end
