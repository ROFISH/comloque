class OpenReportsDrop < Liquid::Drop
  def initialize(user)
    @user = user
  end

  def open_reports
    return [] if !@user.try(:is_mod?)
    @_open_reports ||= Report.where(resolved_at:nil).select{|x| x.can_edit?(@user)}
  end

  # allows {% for reports in open_reports %}
  def each(*args,&block)
    open_reports.each(&block)
  end

  def count
    open_reports.length
  end
end
