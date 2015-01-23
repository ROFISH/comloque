class User < ActiveRecord::Base
  has_many :moderatorships
  has_many :moderated_forums, through: :moderatorships, source: :forum
  LIQUEFIABLE_ATTRIBUTES = %i(name).freeze
  include Liquefiable

  def is_admin?
    superuser == 'administrator'
  end

  def is_mod_of?(fid)
    !!(moderatorships.detect{|x| x.forum_id == fid})
  end
end
