class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.integer :announcement_app_id
      t.integer :schoolperson_id
      t.text :content

      t.timestamps
    end
  end
end
