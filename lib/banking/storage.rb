# frozen_string_literal: true

module Banking
  class Storage
    #attr_accessor :file_path

    #def initialize      
    #  @file_path = 'accounts.yml'
    #end  

    def load_data
      return [] unless File.exist?(DB_PATH)
      YAML.load_file(DB_PATH)

      #if File.exist?(@file_path)
      #  YAML.load_file(@file_path)
      #else
      #  []
      #end
    end

    def save_data(datas)
      File.open(DB_PATH, 'w') { |f| f.write datas.to_yaml }
    end

    #def entity_exists?(login)
    #  load_data.map(&:login).include?(login)
    #end
  end
end
