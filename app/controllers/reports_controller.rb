class ReportsController < ForumController
  before_filter :require_forum
  before_filter :require_topic!
  before_filter :require_message!

  before_filter :require_user!, only: [:new,:create]
  before_filter :require_report_not_exist, only: [:new,:create]

  before_filter :require_report_and_can_edit!, except:[:new,:create]
  before_filter :require_unresolved_report!, except:[:new,:create]

  def new
    @template_name = :report_message
  end

  def create
    @report = Report.create(user_id:@user.id,message_id:@message.id,reason:params[:report_reason])
    redirect_to controller: :forum, action: :topic, topic: @topic.permalink
  end

  def edit
    render rails:true
  end

  def update
    if params[:delete]
      @report.destroy
      flash[:notice] = "Deleted Report."
      redirect_to @topic.url
    else
      this_report_params = report_params
      this_report_params[:resolved_at] = Time.now if @report.resolved_at.blank?
      this_report_params[:mod_id] = @user.id if @report.mod_id.blank?
      if @report.update(this_report_params)
        flash[:notice] = "Resolved Report."
        redirect_to @topic.url
      else
        flash[:error] = "Error resolving report."
        render rails:true, action:"take_report"
      end
    end
  end

private
  def require_report_and_can_edit!
    @report = Report.find_by_message_id(@message.id)

    if !@report
      render text:"No such report.", layout:true, status: :not_found
      return
    end

    if !@report.can_edit?(@user)
      render text:"You cannot take this report.", layout:true, status: :forbidden
      return
    end
  end

  def require_unresolved_report!
    unless @report.resolved_at.blank?
      render text:"You cannot resolve an already resolved report.", layout:true, status: :forbidden
      return
    end
  end

  def require_report_not_exist
    render text:"This message has already been reported!", layout:true, status: :conflict if Report.where(message_id:@message.id).exists?
  end

  def report_params
    params[:report].permit(:delete_post,:lock_topic,:resolution,:mod_notes)
  end
end