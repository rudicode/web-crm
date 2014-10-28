class Persistence

  attr_reader :list

  def initialize name
    @file_name = name
    load_data
  end

  def load_data

    if File.file?(@file_name)
      if @list = CSV.read(@file_name, converters: :numeric)
        #data loaded
      end
    end

  end

  def save_data data

    CSV.open(@file_name, "wb") do |csv|

      data.each do |row|
        csv << row
      end

    end
  end



end
