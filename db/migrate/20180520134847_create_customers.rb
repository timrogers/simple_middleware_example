class CreateCustomers < ActiveRecord::Migration[5.2]
  def change
    create_table :customers do |t|
      t.string :email, null: false
      t.string :iban, null: false
      t.references :user, null: false


      t.timestamps
    end

    add_index :customers, :email, unique: true
  end
end
