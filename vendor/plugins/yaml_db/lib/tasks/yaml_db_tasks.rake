namespace :db do
	namespace :data do

		desc "Dump contents of database to db/data.extension (defaults to yaml)"
		task :dump => :environment do
      SerializationHelper::Base.new(YamlDb::Helper).dump "db/data.yml.gz"
		end

		desc "Load contents of db/data.extension (defaults to yaml) into database"
		task :load => :environment do
			SerializationHelper::Base.new(YamlDb::Helper).load "db/data.yml.gz"
		end

	end
end
