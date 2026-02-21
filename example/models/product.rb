# order.rb

require 'sqlite3'
require 'fileutils'
require 'active_record'

# database connection configuration.
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: File.expand_path('../db/development.sqlite3', __dir__)
)

# model
class Product < ActiveRecord::Base
end

# migration to create products table.
ActiveRecord::Schema.define do
  unless ActiveRecord::Base.connection.table_exists?(:products)
    create_table :products do |t|
      t.string :title
      t.text :description
      t.string :category
      t.decimal :price, precision: 10, scale: 2
      t.timestamps
    end
  end
end