class CreateContentResources < ActiveRecord::Migration
  def change
    create_table :content_resources do |t|
      t.timestamp :uploaded_at
      t.timestamp :commit_at
      t.integer :user_id
      t.has_attached_file :avatar
      t.timestamps
    end
  end
end
