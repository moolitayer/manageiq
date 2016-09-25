class DatawarehouseServerController < ApplicationController
  include EmsCommon

  before_action :check_privileges
  before_action :get_session_data
  after_action :cleanup_action
  after_action :set_session_data

  def show_list
    process_show_list
  end

  def index
    redirect_to :action => 'show_list'
  end

  def show
    return unless init_show
    drop_breadcrumb({:name => display_name,
                     :url  => show_list_link(@record, :page => @current_page, :refresh => 'y')
                    }, true)
    case @display
      when 'main'                          then show_main
      when 'download_pdf', 'summary_only'  then show_download
      when 'timeline'                      then show_timeline
      when 'performance'                   then show_performance

    end
  end

  def init_show(model_class = self.class.model)
    @ems = @record = identify_record(params[:id], model_class)
    return false if record_no_longer_exists?(@record)
    @lastaction = 'show'
    @gtl_url = '/show'
    @display = params[:display] || 'main' unless control_selected?
    true
  end


  def button
    puts "[Datawarehouse] Button pressed"
  end

  private ############################

  # More generic then needed to generalize
  def display_name(display = nil)
    if display.blank?
      ui_lookup(:tables => @record.class.base_class.name)
    else
      ui_lookup(:tables => display)
    end
  end
end
