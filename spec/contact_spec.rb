require_relative '../lib/contact'

describe Contact do
  before :each do
    @first_name = "Homer"
    @last_name = "Simpson"
    @email = "homer@home.com"
    @notes = "Likes duff"
    @contact = Contact.new @first_name, @last_name, @email, @notes
  end

  it "should return an array of it's attributes" do
    attributes = Contact.attributes
    expect(attributes).to eq ["id", "first_name", "last_name", "email", "notes"]
  end

  it "should allow access to data" do
    expect(@contact.first_name).to eq @first_name
    expect(@contact.last_name).to eq @last_name
    expect(@contact.email).to eq @email
    expect(@contact.notes).to eq @notes
  end

  it "should have an id." do
    expect(@contact.id).to be_truthy #not nil
  end

  it "should return full_name" do
    expect(@contact.full_name).to eq "#{@first_name} #{@last_name}"
  end

  it "should return a string with all its values" do
    expect(@contact.to_s).to eq "#{@first_name} #{@last_name} #{@email} [ #{@notes} ]"
  end

end
