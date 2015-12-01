class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :title
      t.string :notes
      t.datetime :due
      t.integer :completion

      t.timestamps null: false
    end
  end
end
