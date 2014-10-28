
class Rolodex
  attr_reader :name, :index, :contacts, :deleted_contacts
  def initialize name
    @name = name
    @index = 501
    @contacts = []
    @deleted_contacts = []
    @persistence = Persistence.new "data/#{@name}.csv"
    load_rolodex
  end



  def add_contact first_name, last_name, email, notes
    contact = Contact.new first_name, last_name, email, notes
    contact.id = @index
    @index += 1
    @contacts << contact
  end

  def find_contact_by_id id
    found_contact = nil
    @contacts.each do |contact|
      found_contact = contact if contact.id == id
    end
    found_contact
  end

  def find_deleted_by_id id
    found_contact = nil
    @deleted_contacts.each do |contact|
      found_contact = contact if contact.id == id
    end
    found_contact
  end

  def update_contact id, first_name, last_name, email, notes

    contact = find_contact_by_id id

    if contact
      contact.first_name = first_name
      contact.last_name  = last_name
      contact.email      = email
      contact.notes      = notes
    end

    contact
  end

  def delete_contact id
    contact = find_contact_by_id id
    if contact
      @deleted_contacts << contact
      #binding.pry
      @contacts.delete contact
    end
  end

  def undelete_contact id
    deleted_contact = find_deleted_by_id id
    if deleted_contact
      @contacts << deleted_contact
      @deleted_contacts.delete deleted_contact
    end
  end


  def load_rolodex
    return unless @persistence.list

    highest_id = @index

    @persistence.list.each do |row|
      contact = Contact.new row[1], row[2], row[3], row[4]
      contact.id = row[0]
      @contacts << contact
      highest_id = contact.id if contact.id > highest_id
    end
    @index = highest_id + 1
  end

  def save_rolodex
    # uses @persistence to save the rolodex.
    data = []
    @contacts.each do |contact|
      data << [contact.id, contact.first_name, contact.last_name,
               contact.email, contact.notes]
    end
    @persistence.save_data data
  end
end
