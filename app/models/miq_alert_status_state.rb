class MiqAlertStatusState < ApplicationRecord
  belongs_to :miq_alert_status
  belongs_to :assignee, :class_name => 'User'
  ACTION_TYPES = %w(assign acknowledge comment unassign unacknowledge).freeze
  validates :action, :acceptance => { :accept => ACTION_TYPES }, :presence => true
  validates :user, :presence => true

  def to_json
    {
      :id                => id,
      :action            => action,
      :comment           => comment,
      :created_at        => created_at,
      :updated_at        => updated_at,
      :username          => user ? miq_alert_status_state.user.name : nil,
      :user_id           => user ? miq_alert_status_state.user.id : nil,
      :assignee_id       => assignee ? miq_alert_status_state.assignee.id : nil,
      :assignee_username => assignee ? miq_alert_status_state.assignee.name : nil
    }
  end
end
