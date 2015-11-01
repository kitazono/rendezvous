# == Schema Information
#
# Table name: users
#
#  id                      :integer          not null, primary key
#  name                    :string(255)
#  image_url               :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#  email                   :string(255)      default(""), not null
#  encrypted_password      :string(255)      default(""), not null
#  reset_password_token    :string(255)
#  reset_password_sent_at  :datetime
#  remember_created_at     :datetime
#  sign_in_count           :integer          default(0), not null
#  current_sign_in_at      :datetime
#  last_sign_in_at         :datetime
#  current_sign_in_ip      :string(255)
#  last_sign_in_ip         :string(255)
#  google_auth_token       :string(255)
#  google_refresh_token    :string(255)
#  google_token_expires_at :datetime
#  nickname                :string(255)      default(""), not null
#

require 'faraday'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  ######################################################################
  # Associations
  ######################################################################
  has_many :posts, foreign_key: 'author_id'
  has_many :comments, foreign_key: 'author_id'
  has_many :notifications
  has_many :footprints

  has_many :watchings, class_name: 'Watch', foreign_key: 'watcher_id'
  has_many :watching_posts, through: :watchings, source: :watchable, source_type: 'Post'

  ######################################################################
  # scope
  ######################################################################
  scope :post_recently, (lambda do
    User.joins(:posts).group('id').order('posts.updated_at desc')
  end)

  scope :search, (lambda do |query|
    where('name LIKE ? OR nickname LIKE ?', "%#{query}%", "%#{query}%")
  end)

  scope :post_today, -> { joins(:posts).where('posts.updated_at > ?', 1.day.ago) }

  scope :now_viewing, -> { select(:id).joins(:footprints).where('footprints.updated_at > ?', 10.minutes.ago).uniq }

  ######################################################################
  # Validations
  ######################################################################
  # validates :name, presence: true
  validates :email, presence: true
  validates :email, uniqueness: true
  # validates :nickname, presence: true
  # validates :nickname, format: { with: /\A[0-9A-Za-z]+\z/i }
  # validates :nickname, uniqueness: true

  ######################################################################
  # instance methods
  ######################################################################

  # push通知を追加
  def push_notification(detail_path, body)
    return if notifications.where(detail_path: detail_path).unread.exists?

    notifications.create(detail_path: detail_path, body: body, is_read: false)
  end

  # record footprint
  def visit_post!(post)
    footprints.create!(post: post)
  end

  def watch!(hash)
    if hash[:post]
      watching_posts << hash[:post] unless watching_posts.include?(hash[:post])
    elsif hash[:tag]
      fail 'Not Implemented.'
    elsif hash[:user]
      fail 'Not Implemented.'
    else
      fail 'No hash argument set.'
    end
  end

  def unwatch!(hash)
    if hash[:post]
      hash[:post].watches.where(watcher: self).destroy_all
    elsif hash[:tag]
      fail 'Not Implemented.'
    elsif hash[:user]
      fail 'Not Implemented.'
    else
      fail 'No hash argument set.'
    end
  end

  # check if user watching post/tag/user
  # TODO: tag/user
  def watching?(hash)
    if hash[:post]
      hash[:post].watches.where(watcher: self).exists?
    elsif hash[:tag]
      fail 'Not Implemented.'
    elsif hash[:user]
      fail 'Not Implemented.'
    else
      fail 'No hash argument set.'
    end
  end

  # def watching_posts
  #   ids = watching_items.where(resource_type: "Post").pluck(:resource_id)
  #   Post.where(id: ids)
  # end
end
