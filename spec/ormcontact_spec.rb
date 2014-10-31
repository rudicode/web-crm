require 'data_mapper'
require_relative '../lib/ormcontact'

describe Ormcontact do
  before :each do
  end
  
  describe "sanitize_params" do

    it "should filter a hash to only allow attributes" do
      attributes = Ormcontact.attributes
      expect(attributes).to eq [:id, :first_name, :last_name, :email, :notes]

      params = {"first_name"=>"Maggie", "last_name"=>"Simpson", "email"=>"maggie@simpsons.net", "notes"=>"does", "splat"=>[], "captures"=>["3"], "id"=>"3"}
      clean_params = {"first_name"=>"Maggie", "last_name"=>"Simpson", "email"=>"maggie@simpsons.net", "notes"=>"does", "id"=>"3"}
      
      result = Ormcontact.sanitize_params(params)
      expect(result).to eq clean_params
      p clean_params
    end

  end
end