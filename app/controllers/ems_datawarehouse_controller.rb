class EmsDatawarehouseController < ApplicationController
  include EmsCommon

  before_action :check_privileges
  before_action :get_session_data
  after_action :cleanup_action
  after_action :set_session_data

  def self.model
    ManageIQ::Providers::DatawarehouseManager
  end

  def self.table_name
    @table_name ||= "ems_datawarehouse"
  end

  def index
    redirect_to :action => 'show_list'
  end

  def show_link(ems, options = {})
    ems_datawarehouse_path(ems.id, options)
  end

  def ems_path(*args)
    ems_datawarehouse_path(*args)
  end

  def new_ems_path
    new_ems_datawarehouse_path
  end

  def listicon_image(item, _view)
    icon = item.decorate.try(:listicon_image)
  end

  def restful?
    true
  end
  public :restful?
end
