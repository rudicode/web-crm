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

get '/' do
  erb :index
end

post '/contacts' do
  puts #the params hash
  contact = Contact.new(params[:first_name], params[:last_name], params[:email], params[:note])
  $rolodex.add_contact contact  

  redirect to('/contacts') # this is a GET

end
  
