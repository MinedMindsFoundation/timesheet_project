# http://www.rubydoc.info/github/google/google-api-ruby-client/Google/Apis/CalendarV3
require 'googleauth'
require 'google/apis/calendar_v3'



 class GoogleCalendar

  def initialize
    authorize
  end

  def service
    @service
  end

  def events(reload=false)
    # NOTE: This is just for demonstration purposes and not complete.
    # If you have more than 2500 results, you'll need to get more than    
    # one set of results.
    @events = nil if reload
    @events ||= service.list_events(calendar_id, max_results: 2500).items
  end

  def new_event(start_date,end_date,email,name)
    create_calendar_event(start_date,end_date,email,name)
  end


  def create_calendar_event(start_date,end_date,email,name)
    event = Google::Apis::CalendarV3::Event.new({
        summary: "#{name}'s Paid Time Off",
        location: '',
        description: '',
        start: {
          date_time: "#{start_date}T0:00:00-00:00"
        },
        end: {
          date_time: "#{end_date}T0:00:00-00:00"
        },
        # recurrence: [
        #   'RRULE:FREQ=DAILY;COUNT=2'
        # ],
        attendees: [
          {email: "#{email}"}
        ]
        # reminders: {
        #   use_default: false,
        #   overrides: [
        #     {'method' => 'email', 'minutes': 24 * 60},
        #     {'method' => 'popup', 'minutes': 10},
        #   ],
        # },
      })
      
      result = service.insert_event('primary', event)
      puts "Event created: #{result.html_link}"
    end

private

  def calendar_id
    @calendar_id ||= ENV['calendar_id'] # The calendar ID you copied in step 20 above (or some reference to it).  
  end

  def authorize
    calendar = Google::Apis::CalendarV3::CalendarService.new
    calendar.client_options.application_name = 'App Name' # This is optional
    calendar.client_options.application_version = 'App Version' # This is optional

    # An alternative to the following line is to set the ENV variable directly 
    # in the environment or use a gem that turns a YAML file into ENV variables
    ENV['GOOGLE_APPLICATION_CREDENTIALS'] = "google_api.json"
    scopes = [Google::Apis::CalendarV3::AUTH_CALENDAR]
    calendar.authorization = Google::Auth.get_application_default(scopes)
    @service = calendar
  end


end


#gem install 'google-api-client'
 

# class GoogleCalendar
#     #Setup auth client
#     client_secrets = Google::APIClient::ClientSecrets.load #client_secrets.json must be present in current directory!
#     auth_client = client_secrets.to_authorization
#     auth_client.update!(
#     :scope => 'https://www.googleapis.com/auth/calendar',
#     :access_type => "offline", #will make refresh_token available
#     :approval_prompt =>'force',
#     :redirect_uri => 'http://www.myauthorizedredirecturl.com'
#     )

#     refresh_token_available = File.exist?('refresh_token.txt')

#     if !refresh_token_available
#     #OAuth URL - this is the url that will prompt a Google Account owner to give access to this app.
#     puts "Navigate browser to: '#{auth_client.authorization_uri.to_s}' and copy/paste auth code after redirect."

#     #Once the authorization_uri (above) is followed and authorization is given, a redirect will be made 
#     #to http://www.myauthorizedredirecturl.com (defined above) and include the auth code in the request url.
#     print "Auth code: "
#     auth_client.code = gets
#     else 
#     #If authorization has already been given and refresh token saved previously, simply set the refresh code here.
#     auth_client.refresh_token = File.read('refresh_token.txt')
#     end

#     #Now, get our access token which is what we will need to work with the API.
#     auth_client.fetch_access_token!

#     if !refresh_token_available
#     #Save refresh_token for next time
#     #Note: auth_client.refresh_token is only available the first time after OAuth permission is granted.  
#     #If you need it again, the Google Account owner would have deauthorize your app and you would have to request access again.
#     #Therefore, it is important that the refresh token is saved after authenticating the first time!
#     File.open('refresh_token.txt', 'w') { |file| file.write(auth_client.refresh_token) }
#     refresh_token_available = true
#     end

#     api_client = Google::APIClient.new
#     cal = api_client.discovered_api('calendar', 'v3')

#     #Get Event List
#     puts "Getting list of events..."
#     list = api_client.execute(:api_method => cal.events.list, 
#     :authorization => auth_client,
#     :parameters => {
#         'maxResults' => 20, 
#         'timeMin' => '2014-06-18T03:12:24-00:00', 
#         'q' => 'Meeting', 
#         'calendarId' => 'primary'})

#     puts "Fetched #{list.data.items.count} events..."

#     #Update Event
#     puts "Updating first event from list..."
#     update_event = list.data.items[0]
#     update_event.description = "Updated Description here"
#     result = api_client.execute(:api_method => cal.events.update, 
#     :authorization => auth_client,
#     :parameters => { 'calendarId' => 'primary', 'eventId' => update_event.id}, 
#     :headers => {'Content-Type' => 'application/json'},
#     :body_object => update_event)
#     puts "Done with update."

#     #Add New Event
#     puts "Inserting new event..."
#     new_event = cal.events.insert.request_schema.new
#     new_event.start = { 'date' => '2015-01-01' } #All day event
#     new_event.end = { 'date' => '2015-01-01' } 
#     new_event.description = "Description here"
#     new_event.summary = "Summary here"
#     result = api_client.execute(:api_method => cal.events.insert, 
#     :authorization => auth_client,
#     :parameters => { 'calendarId' => 'primary'}, 
#     :headers => {'Content-Type' => 'application/json'},
#     :body_object => new_event)
#     puts "Done with insert."
# end