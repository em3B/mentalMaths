class CreateSchoolInvitations < ActiveRecord::Migration[8.0]
  def change
    create_table :school_invitations do |t|
      t.references :school, null: false, foreign_key: true
      t.string :email
      t.string :token
      t.datetime :accepted_at
      t.datetime :expires_at

      t.timestamps
    end
  end
end
