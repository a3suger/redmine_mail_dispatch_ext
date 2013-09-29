class CreateMailMessages < ActiveRecord::Migration
  def change
    create_table :mail_messages do |t|
      t.string     :messageid
      t.string     :subject
      t.datetime   :date
      t.references :sender
      t.references :mail_user
      t.references :ticket, :polymorphic => true
      t.references :parent 
      t.references :project
    end
    
    create_table :mail_users do |t|
      t.string    :name 
      t.string    :mail , :null => false
      t.references :user
    end

    create_table :mail_receivers do |t|
      t.references :mail_message
      t.references :receiver, :polymorphic => true
      t.string     :category 
    end
  end
end
