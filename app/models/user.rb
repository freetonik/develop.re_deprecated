class User < ActiveRecord::Base
  has_many :stories,
    -> { includes :user }
  has_many :comments
  has_many :sent_messages,
    :class_name => "Message",
    :foreign_key => "author_user_id"
  has_many :received_messages,
    :class_name => "Message",
    :foreign_key => "recipient_user_id"
  has_many :tag_filters
  has_many :user_favorite_stories, :dependent => :destroy
  has_many :favorite_stories, :through => :user_favorite_stories, :source => :story
  belongs_to :invited_by_user,
    :class_name => "User"

  has_secure_password

  validates :email, :format => { :with => /\A[^@ ]+@[^@ ]+\.[^@ ]+\Z/ },
    :uniqueness => { :case_sensitive => false }

  validates :password, :presence => true, :on => :create

  validates :username, :format => { :with => /\A[A-Za-z0-9][A-Za-z0-9_-]*\Z/ },
    :uniqueness => { :case_sensitive => false }

  validates_each :username do |record,attr,value|
    if BANNED_USERNAMES.include?(value.to_s.downcase)
      record.errors.add(attr, "is not permitted")
    end
  end

  attr_accessible :username, :email, :password, :password_confirmation,
    :about, :email_replies, :pushover_replies, :pushover_user_key,
    :pushover_device, :email_messages, :pushover_messages, :email_mentions,
    :pushover_mentions, :mailing_list_enabled

  before_save :check_session_token
  before_validation :on => :create do
    self.create_rss_token
    self.create_mailing_list_token
  end

  BANNED_USERNAMES = [ "admin", "administrator", "hostmaster", "mailer-daemon",
    "postmaster", "root", "security", "support", "webmaster", ]

  def as_json(options = {})
    h = super(:only => [
      :username,
      :created_at,
      :is_admin,
      :is_moderator,
    ])
    h[:avatar_url] = avatar_url
    h
  end

  def avatar_url
    "https://secure.gravatar.com/avatar/" +
      Digest::MD5.hexdigest(self.email.strip.downcase) + "?r=pg&d=mm&s=100"
  end

  def average_karma
    if (k = self.karma) == 0
      0
    else
      k.to_f / (self.stories_submitted_count + self.comments_posted_count)
    end
  end

  def check_session_token
    if self.session_token.blank?
      self.session_token = Utils.random_str(60)
    end
  end

  def create_mailing_list_token
    if self.mailing_list_token.blank?
      self.mailing_list_token = Utils.random_str(10)
    end
  end

  def create_rss_token
    if self.rss_token.blank?
      self.rss_token = Utils.random_str(60)
    end
  end

  def comments_posted_count
    Keystore.value_for("user:#{self.id}:comments_posted").to_i
  end

  def initiate_password_reset_for_ip(ip)
    self.password_reset_token = Utils.random_str(40)
    self.save!

    PasswordReset.password_reset_link(self, ip).deliver
  end

  def linkified_about
    # most users are probably mentioning "@username" to mean a twitter url, not
    # a link to a profile on this site
    Markdowner.to_html(self.about, { :disable_profile_links => true })
  end

  def most_common_story_tag
    Tag.joins(
      :stories
    ).where(
      :stories => { :user_id => self.id }
    ).group(
      Tag.arel_table[:id]
    ).order(
      'COUNT(*) desc'
    ).first
  end

  def recent_threads(amount)
    self.comments.order('created_at desc').limit(amount).uniq.pluck(:thread_id)
  end

  def stories_submitted_count
    Keystore.value_for("user:#{self.id}:stories_submitted").to_i
  end

  def undeleted_received_messages
    received_messages.where(:deleted_by_recipient => false)
  end

  def undeleted_sent_messages
    sent_messages.where(:deleted_by_author => 0)
  end

  def unread_message_count
    Keystore.value_for("user:#{self.id}:unread_messages").to_i
  end

  def update_unread_message_count!
    Keystore.put("user:#{self.id}:unread_messages",
      Message.where(:recipient_user_id => self.id,
        :has_been_read => false).count)
  end
end
