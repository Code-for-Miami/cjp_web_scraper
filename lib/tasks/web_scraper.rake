require 'get_data.rb'

desc "This task does nothing"
task :webscraper do
    WebScraper.new.go
end

