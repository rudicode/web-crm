require 'pry'
require 'csv'

require_relative './lib/contact'
require_relative './lib/persistence'
require_relative './lib/rolodex'

require 'sinatra'
require "sinatra/reloader" if development?
require "better_errors"

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = __dir__
end

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
  erb :list_contacts, :layout => :layout 
end

get '/contacts/new' do
  erb :new_contact
end

post '/contacts' do
  log params
  $rolodex.add_contact params[:first_name], params[:last_name], params[:email], params[:note]

  redirect to('/contacts') # this is a GET
end

get '/contacts/:id' do
  #display single contact
end

get '/contacts/edit/:id' do
  log params
  if @contact = $rolodex.find_contact_by_id(params[:id])
    log @contact
    erb :edit_contact
  else
    redirect to('/contacts')
  end
end

post '/contacts/:id' do
  # do update here
  @id = params[:id]
  erb :succesful_update
end

post '/contacts/delete/:id' do
  #
end

get '/pry' do
  binding.pry
end
  
