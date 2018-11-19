require 'get_data.rb'

desc "Fetches Data for Community Justice Project"
task :webscraper do
    WebScraper.new.go
end

