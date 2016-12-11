class AddDatawarehouseToEventStreams < ActiveRecord::Migration[5.0]
  def change
    add_column :event_streams, :source_ems_id, :bigint, :after => :ems_id
  end
end
