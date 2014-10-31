require 'pry'
# require 'sqlite'
require 'data_mapper'
# require 'csv'
require 'sinatra'
require "sinatra/reloader" if development?
require "better_errors"

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = __dir__
end


DataMapper.setup(:default,"sqlite3://#{File.expand_path(File.dirname(__FILE__))}/db/database.sqlite3")

require_relative './lib/contact'
require_relative './lib/ormcontact'
require_relative './lib/persistence'
require_relative './lib/rolodex'

DataMapper.finalize
DataMapper.auto_upgrade!

# use a class variable or global variable so that the
# $rolodex object is persisted between calls
# @@rolodex = Rolodex.new
$rolodex = Rolodex.new "Bitmaker CRM"
$notice = ""
# helpers
#
def log message
  puts "\n__[CRM_LOG]__:#{message}\n\n"
end

module MyHelpers
  def class_odd_or_even number
    if number.odd?
      return "class=\"odd\""
    end
    "class=\"even\""
  end

  def clear_notice
    $notice=""
  end

  def contact_count
    $rolodex.contacts.size
  end
end

helpers MyHelpers

# 
get '/' do
  @count = contact_count
  # log @count
  erb :index
end

get '/contacts' do
  log "GET /contacts"

  # $notice = "Displaying Contacts"
  # @contacts = $rolodex.contacts
  @contacts = Ormcontact.all
  erb :list_contacts, :layout => :layout 
end

get '/contacts/new' do
  erb :new_contact
end

post '/contacts' do
  log params
  contact = Ormcontact.create params
  if contact.saved?
    $notice = "Contact: #{params[:first_name]} #{params[:last_name]}, added."
    redirect to('/contacts')
  else
    $notice = "Contact: Not Added"
    redirect to('/contacts/new')
  end
  # 
  # if $rolodex.add_contact(params[:first_name], params[:last_name], params[:email], params[:note])
  #   $notice = "Contact: #{params[:first_name]} #{params[:last_name]}, added."
  #   redirect to('/contacts')
  # else
  #   $notice = "Contact: Not Added"
  #   redirect to('/contacts/new') # this is a GET
  # end
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
  log params
  if $rolodex.update_contact(params[:id], params[:first_name], params[:last_name], params[:email], params[:notes])
    $notice = "Contact: #{params[:first_name]} #{params[:last_name]}, updated."
    redirect to('/contacts')
  else
    #error finding the contact to update
    $notice = "Contact: Not updated"
    redirect to('/contacts')
  end
end

delete "/contacts/:id" do
  log params
  @contact = $rolodex.find_contact_by_id(params[:id])
  if @contact
    $rolodex.delete_contact(@contact.id)
    $notice = "Contact: #{@contact.first_name} Deleted"
    redirect to("/contacts")
  else
    $notice = "Contact: Not Deleted"
    redirect to('/contacts') # this is a GET
    # raise Sinatra::NotFound
  end
end

get '/pry' do
  binding.pry
end
  
