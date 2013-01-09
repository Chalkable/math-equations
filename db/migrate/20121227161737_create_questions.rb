class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.integer :announcement_app_id
      t.integer :schoolperson_id
      t.text :content

      t.timestamps
    end
  end
end
