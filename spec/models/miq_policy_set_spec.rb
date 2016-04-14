describe MiqPolicySet do
  describe ".seed" do
    it "should contain policy sets" do
      MiqPolicy.seed
      MiqPolicySet.seed
      specifications = YAML.load_file(File.join(ApplicationRecord::FIXTURE_DIR, "miq_policy_sets.yml"))
      specifications_by_name = specifications.index_by { |h| h[:name] }

      count = 0
      MiqPolicySet.all.each do |mps|
        spec = specifications_by_name[mps[:name]]
        expect(mps).to have_attributes(spec.except(:miq_policies, :guid))
        expect(mps.miq_policies.size).to eq(spec[:miq_policies].size)
        count += 1
      end
      expect(count).to eq(specifications.size)
    end
  end
end
