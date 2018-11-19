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
  		details = details.text.split('Charge')
  		arrestee = details[0]
  		charge = "Charge #{details[1]}"
  		arrest = [date.text, type.text, arrestee, charge, location.text]
  		arrests.append(arrest)
	end

	# Authenticate a session with your Service Account

	# session = GoogleDrive::Session.from_service_account_key('public/temp.json')
	session = GoogleDrive::Session.from_service_account_key(StringIO.new(Rails.application.secrets.google_client_secrets.to_json))

	# Get the spreadsheet by its title
	spreadsheet = session.spreadsheet_by_title("CJP Test Spreadsheet")

	worksheet = spreadsheet.worksheets.first

	arrests.each do |arrest|
		worksheet.insert_rows(worksheet.num_rows + 1, [arrest])
	end
	worksheet.save

	File.delete("public/temp.json") if File.exist?("public/temp.json")

	driver.quit()
  end
end