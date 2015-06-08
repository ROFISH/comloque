class User < ActiveRecord::Base
  has_many :moderatorships
  has_many :moderated_forums, through: :moderatorships, source: :forum
  has_many :forum_reads
  has_many :topic_reads
  has_many :private_topic_users
  has_many :private_topics, through: :private_topic_users, source: :topic

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

  def is_mod?
    # admins are mods too, this is just for tools that require any person to be a moderator
    # adding the admins by default might change though.
    !moderated_forum_ids.empty? || is_admin?
  end

  def forum_reads_for(fids)
    hash_map = forum_reads.where(forum_id:fids).map{|x| [x.forum_id,x.updated_at]}
    Hash[hash_map]
  end

  def topic_reads_for(fids)
    hash_map = topic_reads.where(topic_id:fids).map{|x| [x.topic_id,x.updated_at]}
    Hash[hash_map]
  end
end
