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
$random_contacts = []

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
    Ormcontact.count
  end

  def generate_random_contacts

    first = ["Andy", "Jim", "Mary", "Amy", "George", "Lucas", "Chris", "Matt", "Sarah", "Julie"]
    last = ["Smith", "Martinez", "Parker", "Black", "Johnson", "King", "Nolin", "Verges", "Kerns"]
    domain = ["google", "bell", "example", "sympatico", "rogers", "hotmail"]
    email_suffix = [".com", ".net", ".org", ".tv"]
    notes = "Some notes go here."

    random_contacts = []

    11.times do |count|
      first_name = first.sample
      last_name = last.sample
      email = first_name + "." + last_name + "@" + domain.sample + email_suffix.sample

      # @rolodex.add_contact first_name, last_name, email.downcase, notes

      random_contacts << Contact.new(first_name, last_name, email.downcase, notes)
    end
    random_contacts
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

  @contacts = Ormcontact.all
  erb :list_contacts, :layout => :layout 
end

get '/contacts/new' do
  erb :new_contact
end

post '/contacts' do
  log params
  #TODO, sanitize params before creating the contact
  contact = Ormcontact.create params
  if contact.saved?
    $notice = "Contact: #{params[:first_name]} #{params[:last_name]}, added."
    redirect to('/contacts')
  else
    $notice = "Contact: Not Added"
    redirect to('/contacts/new')
  end
  
end

get '/contacts/:id' do
  #display single contact
  if @contact = Ormcontact.get(params[:id])
    erb :show_contact
  else
    $notice = "Contact #{params[:id]} does not exist."
    redirect to('/contacts')
  end
end

get '/contacts/edit/:id' do
  log params
  if @contact = Ormcontact.get(params[:id].to_i)
    log @contact
    erb :edit_contact
  else
    $notice = "Contact with id #{params[:id]} does not exist."
    redirect to('/contacts')
  end
end

post '/contacts/:id' do
  # do update here
  log params

  if contact = Ormcontact.get(params[:id].to_i)
    clean_params = Ormcontact.sanitize_params(params)
    contact.attributes = clean_params
    if contact.save
      $notice = "Contact: #{params[:first_name]} #{params[:last_name]}, updated."
    else
      $notice = "Contact: was not saved."
    end
  else
    $notice = "Contact Does not exist."
  end

  redirect to('/contacts')
  
end

delete "/contacts/:id" do
  log params
  if contact = Ormcontact.get(params[:id].to_i)
    deleted_contact = Ormcontactdeleted.new(contact.attributes)
      # binding.pry
    deleted_contact.save

    contact.destroy
    $notice = "Contact #{params[:id]} has been Deleted."
  else
    $notice = "Could not Delete Contact with id: #{params[:id]}"
  end
  redirect to('/contacts')

end

get "/advanced_options" do
  erb :advanced_options
end

get '/options/add_random_contacts' do
  log "GET /options/add_random_contacts"

  $random_contacts  = generate_random_contacts
  @contacts = $random_contacts

  erb :display_random_contacts
end

post '/options/add_random_contacts' do
  log "POST /options/add_random_contacts"
  log params
  $random_contacts.each do |rand_contact|
    
    new_contact = Ormcontact.create(rand_contact.to_h)

    if new_contact.saved?
      $notice = "Random Contacts Added."
    else
      $notice = "There was an error saving random contacts."
    end
    
  end

  redirect to('/contacts')
  
end


  
