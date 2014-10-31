class Ormcontact
  include DataMapper::Resource
  
  property :id,         Serial
  property :first_name, String, :required => true
  property :last_name,  String
  property :email,      String
  property :notes,      String

end

