require_relative '../lib/rolodex'
require_relative '../lib/persistence'

describe Rolodex do
  before :each do
    @rolodex_name = "my rolodex"
    @rolodex = Rolodex.new @rolodex_name
  end

  it "should have a name" do
    expect(@rolodex.name).to eq @rolodex_name
  end

  describe "add_contact" do
    before :each  do
      @first_name = "Homer"
      @last_name = "Simpson"
      @email = "homer@home.com"
      @notes = "Likes duff"
    end

    it "should add new contact" do
      expect do
        @rolodex.add_contact @first_name, @last_name, @email, @notes
      end.to change{@rolodex.contacts.length}.by(1)
    end

    it "should add the correct contact" do
      @initial_index = @rolodex.index
      @rolodex.add_contact @first_name, @last_name, @email, @notes
      expect(@rolodex.contacts.last.first_name).to be @first_name
      expect(@rolodex.contacts.last.last_name).to be @last_name
      expect(@rolodex.contacts.last.email).to be @email
      expect(@rolodex.contacts.last.notes).to be @notes
      expect(@rolodex.contacts.last.id).to be @initial_index
    end

    it "should increment the contact index" do
      expect do 
        @rolodex.add_contact @first_name, @last_name, @email, @notes
      end.to change{@rolodex.index}.by(1)
    end

  end

  describe "find_contact_by_id" do
    before :each  do
      @first_name = "Homer"
      @last_name = "Simpson"
      @email = "homer@home.com"
      @notes = "Likes duff"
      @index = @rolodex.index
      @rolodex.add_contact @first_name, @last_name, @email, @notes
    end

    it "should find the contact by id" do
      contact = @rolodex.find_contact_by_id @index
      expect(contact.first_name).to eq @first_name
      expect(contact.last_name).to eq @last_name
      expect(contact.email).to eq @email
      expect(contact.notes).to eq @notes
    end

  end

  describe "update_contact" do
    before(:each) do
      @first_name = "Homer"
      @last_name = "Simpson"
      @email = "homer@home.com"
      @notes = "Likes duff"
      @index = @rolodex.index
      @rolodex.add_contact @first_name, @last_name, @email, @notes
    end

    it "should update the contact" do
      first_name = "Bart"
      last_name  = "Simpson"
      email      = "bart@school.com"
      notes      = "Skateboarding kid."
      @new_contact = Contact.new first_name, last_name, email, notes

      @rolodex.update_contact 501, first_name, last_name, email, notes
      updated_contact = @rolodex.find_contact_by_id 501

      expect(updated_contact.first_name).to eq first_name
      expect(updated_contact.last_name).to eq last_name
      expect(updated_contact.email).to eq email
      expect(updated_contact.notes).to eq notes
    end
  end

  describe "delete_contact" do
    before(:each) do
      @first_name = "Homer"
      @last_name = "Simpson"
      @email = "homer@home.com"
      @notes = "Likes duff"
      @index = @rolodex.index
      @rolodex.add_contact @first_name, @last_name, @email, @notes
    end

    it "should delete a contact" do
      @rolodex.delete_contact(@index)
      contact = @rolodex.find_contact_by_id(@index)
      expect(contact).to be nil
    end
  end

  describe "undelete contact" do
    before(:each) do
      @first_name = "Homer"
      @last_name = "Simpson"
      @email = "homer@home.com"
      @notes = "Likes duff"
      @index = @rolodex.index
      @rolodex.add_contact @first_name, @last_name, @email, @notes
    end

    it "should allow to undelete a contact" do
      @rolodex.delete_contact(@index)
      contact = @rolodex.find_contact_by_id(@index)
      expect(contact).to be nil
      @rolodex.undelete_contact @index
      undeleted_contact = @rolodex.find_contact_by_id(@index)
      expect(undeleted_contact).to be_truthy #not nil
    end
  end
end
