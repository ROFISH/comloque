module DevelopmentHelper
  extend ActiveSupport::Concern

  # included do
  #   has_many :taggings, as: :taggable
  #   has_many :tags, through: :taggings

  #   class_attribute :tag_limit
  # end

  # def tags_string
  #   tags.map(&:name).join(', ')
  # end

  # def tags_string=(tag_string)
  #   tag_names = tag_string.to_s.split(', ')

  #   tag_names.each do |tag_name|
  #     tags.build(name: tag_name)
  #   end
  # end

  # # methods defined here are going to extend the class, not the instance of it
  # module ClassMethods

  #   def tag_limit(value)
  #     self.tag_limit_value = value
  #   end

  # end

  included do
    before_action :check_for_empty_users
  end

  def check_for_empty_users
    # $has_users just means we only check once per reboot
    if $has_users.blank? && User.count <= 0
      if params[:name] &&
         params[:name].length > 1 &&
         params[:email] &&
         params[:email] =~ /\@/

        user = User.create(name:params[:name],email:params[:email],superuser:'administrator')
        reset_session
        session[:user_id] = user.id
        redirect_to '/'
      else
        render 'lolempty', rails:true, layout:'application'
      end
      #return true
    else
      $has_users = true
    end
  end
end
