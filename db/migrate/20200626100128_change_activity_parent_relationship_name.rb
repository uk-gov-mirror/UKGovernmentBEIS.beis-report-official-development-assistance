class ChangeActivityParentRelationshipName < ActiveRecord::Migration[6.0]
  def up
    add_column :activities, :parent_id, :string
    Activity.transaction do
      Activity.all.each do |activity|
        activity.update!(parent_id: activity.activity_id)
      end
    end
    remove_column :activities, :activity_id, :string
  end

  def down
    add_column :activities, :activity_id, :string
    Activity.transaction do
      Activity.all.each do |activity|
        activity.update!(activity_id: activity.parent_id)
      end
    end
    remove_column :activities, :parent_id, :string
  end
end
