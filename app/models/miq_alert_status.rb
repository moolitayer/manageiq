class MiqAlertStatus < ApplicationRecord
  belongs_to :miq_alert
  belongs_to :resource, :polymorphic => true
  has_many :miq_alert_status_states
  SEVERITY_LEVELS = %w(error warning info).freeze

  include ActionView::Helpers::UrlHelper

  def to_json
    {
      "id"            => id,
      "evaluated_on"  => evaluated_on,
      "html"          => miq_alert.html,
      "resource_type" => resource_type,
      "resource_id"   => resource_id,
      "resource_name" => resource.name,
      "show_link"     => resource_link,
      "image_link"    => resource_image,
      "description"   => miq_alert.description,
      "severity"      => miq_alert.severity,
      "states"        => alert_states_history
    }
  end

  def alert_states_history
    miq_alert_status_states.includes(:user, :assignee).map(&:to_json).compact
  end

  def resource_link
    "#{resource.class.name.demodulize.underscore}/show/#{resource_id}"
  end

  def resource_image
    resource.class.name.demodulize.underscore
  end
end
