class Ormcontact
  include DataMapper::Resource
  
  property :id,         Serial
  property :first_name, String, :required => true
  property :last_name,  String
  property :email,      String
  property :notes,      String

  def self.attributes
    self.properties.map {|p| p.name}
  end

  def self.sanitize_params params
    # takes in a hash and filters out pairs that are not part of the models attributes.
    clean_params = {}
    params.each do |key,value|
      if self.attributes.include?(key.to_sym)
        clean_params[key] = value
      end
    end
    clean_params
  end

end

