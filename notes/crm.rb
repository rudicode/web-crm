class CRM

  def self.run name
    crm = CRM.new name
    crm.main_menu
  end

  def initialize name
    @name = name
    @rolodex = Rolodex.new "rolodex_1"
    @notice = ""
  end

  def main_menu
    clear_screen
    while true
      display_menu
      input = get_input
      process_option input
      break if input == 9
    end
  end

  def display_menu
    menu = %{
      #{@notice}

    #{@name}

      [ 1 ] Add Contact
      [ 2 ] Modify Contact
      [ 3 ] Display All
      [ 4 ] Display Contact
      [ 5 ] Display Attribute           Debug options
      [ 6 ] Delete Contact          [ 98 ] Add Random contacts
      [ 7 ] Undelete Contact        [ 99 ] Trigger pry
      [ 8 ] Save Contacts
      [ 9 ] Exit

    }

    clear_screen
    puts menu
    print "Choose an option: -> "
    clear_notice
  end

  def get_input
    gets.chomp().to_i
  end

  def process_option option
    case option
    when 1 then add_contact
    when 2 then modify_contact
    when 3 then display_all_contacts
    when 4 then display_contact
    when 5 then display_attribute
    when 6 then delete_contact
    when 7 then undelete_contact
    when 8 then save_contacts
    when 9 then return
    when 99 then trigger_pry
    when 98 then add_a_bunch_of_contacts_so_i_dont_have_to_keep_typing_them_out
    else
      @notice = "#{option} is not a valid option."
    end
    wait_for_enter
  end

  def add_contact
    clear_screen

    first_name, last_name, email, notes = get_contact_from_user "ADD CONTACT\n\n"

    @rolodex.add_contact first_name, last_name, email, notes

    # no error checking yet, assume it was added.
    @notice = "#{first_name} #{last_name} added to contacts."

  end

  def display_all_contacts

    clear_screen

    display_header

    lines = []

    @rolodex.contacts.each do |contact|
      lines << columnize(contact.id, contact.first_name, contact.last_name,
                         contact.email, contact.notes)
      lines << "\n"
    end

    display_with_pages lines

    puts "\nDisplayed #{@rolodex.contacts.count} contact(s)."

  end

  def display_attribute

    attributes = Contact.attributes
    message = "Which Attribute?\n\n"
    attributes.each_with_index do |attribute,index|
      message += "    [ #{index} ] #{attribute}\n"
    end

    message += "\n Enter attribute number -> "

    attribute_number = get_number_from_user message

    unless attribute_number.between?(0,attributes.length) 
      @notice = "Error, did not select attribute."
      return
    end

    clear_screen

    puts "Display attribute: #{attributes[attribute_number]}\n"
    puts "-------------------------------"

    lines = []

    @rolodex.contacts.each do |contact|
      current_attribute = contact.send("#{attributes[attribute_number]}")
      lines << current_attribute
      lines << "\n"
    end

    display_with_pages lines

  end

  def display_with_pages lines
    display_line = 1

    lines.each do |line|
      puts line
      if display_line >= 24
        wait_for_enter
        puts
        display_line = 1
      end
      display_line += 1
    end
  end

  def modify_contact
    display_all_contacts
    input_id = get_number_from_user "Enter the ID of the contact to edit."
    contact_to_update = @rolodex.find_contact_by_id input_id
    unless contact_to_update
      @notice = "Contact with ID #{input_id} does not exist."
      return
    end

    first_name, last_name, email, notes = get_contact_from_user "Edit Contact #{input_id}"

    updated_contact = @rolodex.update_contact input_id, first_name, last_name, email, notes

    if updated_contact
      @notice = "Contact #{input_id} was updated."
    else
      @notice = "Contact with ID #{input_id} failed to update."
    end

  end

  def display_contact message = "Enter the ID of the contact to display."
    input_id = get_number_from_user message
    contact = @rolodex.find_contact_by_id input_id

    unless contact
      @notice = "Contact with id: #{input_id} Does Not exist."
      return nil
    end

    display_header
    puts columnize contact.id, contact.first_name, contact.last_name,
      contact.email, contact.notes
    puts

    return input_id

  end

  def delete_contact

    contact_id = display_contact "Enter the ID of the contact to DELETE: "
    return if contact_id.nil?
    print "Are you sure you want to delete this contact. (y/n) : "
    if gets.chomp().to_s == "y"
      @rolodex.delete_contact contact_id
      @notice = "Contact ID #{contact_id} was deleted."
    end
  end

  def undelete_contact
    display_header

    @rolodex.deleted_contacts.each do |contact|

      puts columnize contact.id, contact.first_name, contact.last_name,
        contact.email, contact.notes
      puts

    end
    puts "\nDisplayed #{@rolodex.deleted_contacts.count} contact(s)."

    input_id = get_number_from_user "Enter the ID of the contact to UN-DELETE: "
    if @rolodex.undelete_contact input_id
      @notice = "Contact ID #{input_id} was undeleted."
    else
      @notice = "Contact ID #{input_id} does not exist."
    end
  end

  def save_contacts
    @rolodex.save_rolodex
  end

  private

  def get_number_from_user message
    print "#{message} "
    input_id = gets.chomp().to_i
  end

  def get_contact_from_user message
    # routine to get the contact input from user.
    clear_screen
    puts "#{message}\n\n"

    print "First name: "
    first_name = gets.chomp().to_s

    print "Last name : "
    last_name = gets.chomp().to_s

    print "email     : "
    email = gets.chomp().to_s

    print "Notes     : "
    notes = gets.chomp().to_s
    return first_name, last_name, email, notes
  end

  def self.stub(*names)
    # refactored with help from ...
    names.each do |name|
      define_method(name) do
        @notice = "#{self.class}##{name} Not implemented yet!!"
      end
    end
  end

  # stub :display_attribute


  def clear_screen
    puts"\e[H\e[2J"
  end

  def wait_for_enter
    print"\nPress ENTER to continue."
    gets
  end

  def clear_notice
    @notice = ""
  end

  def display_header
    puts
    puts columnize " ID ", "First", "Last", "Email", "Notes"
    puts columnize "----", "-----", "----", "-----", "-----"
    puts
  end

  def trigger_pry
    # need to have the pry gem installed to use this
    # also the pry-byebug gem for ruby 2.x.x, adds debugger
    binding.pry
  end

  def add_a_bunch_of_contacts_so_i_dont_have_to_keep_typing_them_out

    first = ["Andy", "Jim", "Mary", "Amy", "George", "Lucas", "Chris", "Matt", "Sarah", "Julie"]
    last = ["Smith", "Martinez", "Parker", "Black", "Johnson", "King", "Nolin", "Verges", "Kerns"]
    domain = ["google", "bell", "example", "sympatico", "rogers", "hotmail"]
    email_suffix = [".com", ".net", ".org", ".tv"]
    notes = "Some notes go here."

    11.times do |count|
      first_name = first.sample
      last_name = last.sample
      email = first_name + "." + last_name + "@" + domain.sample + email_suffix.sample

      @rolodex.add_contact first_name, last_name, email.downcase, notes
    end
  end

  def columnize id, a, b, c, d
    left_padding = "  "
    left_padding + id.to_s.ljust(6) + a.ljust(10) + b.ljust(16) + c.ljust(32) + d
  end
end
