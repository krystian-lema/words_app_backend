class CreateWords < ActiveRecord::Migration[5.0]
  def change
    create_table :words do |t|
      t.string :definition
      t.string :translation
      t.references :word_collection, foreign_key: true

      t.timestamps
    end
  end
end
