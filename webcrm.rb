require 'pry'
require 'csv'

require_relative './lib/contact'
require_relative './lib/persistence'
require_relative './lib/rolodex'

require 'sinatra'

# use a class variable or global variable so that the
# $rolodex object is persisted between calls
# @@rolodex = Rolodex.new
$rolodex = Rolodex.new "Bitmaker CRM"

# helpers
#
def log message
  puts "__[CRM_LOG]__:#{message}\n"

end

# 
get '/' do

  erb :index
end

get '/contacts' do
  log "GET /contacts"
  @contacts = $rolodex.contacts
  erb :list_contacts
end

get '/contacts/new' do
  erb :new_contact
end

post '/contacts' do
  log params #the params hash
  $rolodex.add_contact params[:first_name], params[:last_name], params[:email], params[:note]

  redirect to('/contacts') # this is a GET

end

get '/pry' do
  binding.pry
end
  
