class WebScraper
	def go
		driver = Selenium::WebDriver.for :chrome

		driver.get "http://www.homesteadpolice.com/Summary_Disclaimer.aspx"

	# click agree
	agree = driver.find_element(:id, "mainContent_CenterColumnContent_btnContinue")
	agree.click()


	# uncheck accident
	accident = driver.find_element(:id, "mainContent_chkTA")
	accident.click()

	# uncheck incident
	incident = driver.find_element(:id, "mainContent_chkLW")
	incident.click()

	# click search
	search = driver.find_element(:id, "mainContent_cmdSubmit")
	search.click()

	number_of_rows = driver.find_elements(:class, "EventSearchGridRow").length
	arrests = []

	number_of_rows.times do |i|
		date = driver.find_element(:xpath => "//*[@id='mainContent_gvSummary']/tbody/tr[#{i+2}]/td[2]")
		type = driver.find_element(:xpath => "//*[@id='mainContent_gvSummary']/tbody/tr[#{i+2}]/td[3]")
		details = driver.find_element(:xpath => "//*[@id='mainContent_gvSummary']/tbody/tr[#{i+2}]/td[4]")
		location = driver.find_element(:xpath => "//*[@id='mainContent_gvSummary']/tbody/tr[#{i+2}]/td[5]")
		arrestee = parse_name(details.text)
		charge = parse_charge(details.text)
		arrest = [date.text, type.text, arrestee, charge, location.text]
		arrests.append(arrest)
	end

	puts 'Getting Data from www.homesteadpolice.com'

	# Authenticate a session with your Service Account

	# session = GoogleDrive::Session.from_service_account_key('public/temp.json')
	session = GoogleDrive::Session.from_service_account_key(StringIO.new(Rails.application.secrets.google_client_secrets.to_json))

	# Get the spreadsheet by its title
	spreadsheet_title = Rails.application.secrets.spreadsheet_title
	spreadsheet = session.spreadsheet_by_title(spreadsheet_title)

	worksheet = spreadsheet.worksheets.first

	puts 'Writing data to spreadsheet'

	arrests.each do |arrest|
		puts "#{arrest}"
		worksheet.insert_rows(worksheet.num_rows + 1, [arrest])
	end
	worksheet.save

	puts 'Finished writing data to spreadsheet'

	File.delete("public/temp.json") if File.exist?("public/temp.json")

	driver.quit()
end

def parse_name(string)
	first_step = string.split('Arrestee: ')
	second_step = first_step[1].split('Charge')[0]
end

def parse_charge(string)
	string.split('Charge: ')[1]
end

end