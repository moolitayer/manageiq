class MiqPolicyContent < ApplicationRecord
  belongs_to :miq_policy
  belongs_to :miq_event_definition
  belongs_to :miq_action

  def self.seed
    fixture_file = File.join(FIXTURE_DIR, "miq_policy_contents.yml")
    content_fixtures = File.exist?(fixture_file) ? YAML.load_file(fixture_file) : []

    content_fixtures.each do |content_fixture|
      content_fixture.merge!(find_associations(content_fixture))
      rec = find_by_pkey(content_fixture)
      if rec.nil?
        create_seed_record(content_fixture[:miq_policy].try(:name), content_fixture)
      else
        update_seed_record(rec, content_fixture[:miq_policy].try(:name), content_fixture)
      end
    end
  end

  def self.find_associations(h)
    {
      :miq_policy           => MiqPolicy.find_by_name(h[:miq_policy]),
      :miq_action           => MiqAction.find_by_name(h[:miq_action]),
      :miq_event_definition => MiqEventDefinition.find_by_name(h[:miq_event_definition])
    }
  end

  def self.create_seed_record(policy_name, content)
    _log.info("Creating #{name}: [#{policy_name}, #{content[:success_sequence]}, #{content[:failure_sequence]}]")
    MiqPolicyContent.create!(content)
  end

  def self.update_seed_record(rec, policy_name, content)
    rec.attributes = content
    if rec.changed?
      _log.info("Updating #{name}: [#{policy_name}, #{rec.id}] ")
      rec.save
    end
  end

  def self.find_by_pkey(content_fixture)
    relation = MiqPolicyContent.where(
      :miq_policy       => content_fixture[:miq_policy],
      :success_sequence => content_fixture[:success_sequence],
      :failure_sequence => content_fixture[:failure_sequence]
    )
    relation.empty? ? nil : relation.first
  end

  def get_action(qualifier = nil)
    action = miq_action

    # set a default value of true for the synchronous flag if it's nil
    self.success_synchronous  = true if success_synchronous.nil?
    self.failure_synchronous  = true if failure_synchronous.nil?
    action.synchronous        = true if action.synchronous.nil?

    case qualifier.to_s
    when 'success'
      action.sequence    = success_sequence
      action.synchronous = success_synchronous
    when 'failure'
      action.sequence    = failure_sequence
      action.synchronous = failure_synchronous
    end
    action
  end

  def export_to_array
    h = attributes
    ["id", "created_on", "updated_on", "miq_policy_id", "miq_event_definition_id", "miq_action_id"].each { |k| h.delete(k) }
    h.delete_if { |_k, v| v.nil? }
    h["MiqEventDefinition"]  = miq_event_definition.export_to_array.first["MiqEventDefinition"]
    h["MiqAction"] = miq_action.export_to_array.first["MiqAction"] if miq_action
    [self.class.to_s => h]
  end
end
