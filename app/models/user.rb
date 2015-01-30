class User < ActiveRecord::Base
  has_many :moderatorships
  has_many :moderated_forums, through: :moderatorships, source: :forum
  LIQUEFIABLE_ATTRIBUTES = %i(name).freeze
  include Liquefiable

  def is_admin?
    superuser == 'administrator'
  end

  # this is overwritten from the default because we can typically assume that moderatorships is preloaded and cached each pageload.
  def moderated_forum_ids
    @_moderated_forum_ids ||= moderatorships.map(&:forum_id)
  end

  def is_mod_of?(fid)
    moderated_forum_ids.include?(fid)
  end
end
