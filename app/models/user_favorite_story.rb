class UserFavoriteStory < ActiveRecord::Base
  attr_accessible :story_id

  belongs_to :story
  belongs_to :user
end
