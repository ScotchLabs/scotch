# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

SerializationHelper::Base.new(YamlDb::Helper).load "db/data.yml.gz"

User.all.each do |u|
  u.password = "123456"
  u.save
end
