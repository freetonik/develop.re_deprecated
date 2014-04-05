class AddUserFavoriteStories < ActiveRecord::Migration
  def change
    create_table :user_favorite_stories do |t|
      t.timestamps :null => false
      t.integer :story_id
      t.integer :user_id
    end

    add_index :user_favorite_stories, [ "user_id", "story_id" ],
      :name => "user_favorite_stories_idx", :unique => true
  end
end
