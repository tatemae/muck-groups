class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups, :force => true do |t|
      t.integer   :creator_id
      t.string    :name
      t.text      :description
      t.string    :aasm_state
      t.string    :default_role,              :default => "member"
      t.integer   :visibility,                :default => 2
      t.boolean   :requires_approval_to_join, :default => false
      t.integer   :member_count
      t.string    :photo_file_name
      t.string    :photo_content_type
      t.integer   :photo_file_size
      t.timestamps
    end

    add_index :groups, ["creator_id"]
    
    create_table :membership_requests, :force => true do |t|
      t.integer  :group_id
      t.integer  :user_id
      t.timestamps
    end

    create_table :memberships, :force => true do |t|
      t.integer  :group_id
      t.integer  :user_id
      t.boolean  :banned,     :default => false
      t.string   :role,       :default => "member"
      t.timestamps
    end
    
  end

  def self.down
    drop_table :groups
    drop_table :memberships
    drop_table :membership_requests
  end
end
