# frozen_string_literal: true

module Storage
  def accounts
    if File.exists?('../../accounts.yml')
      YAML.load_file('../../accounts.yml')
    else
      []
    end
  end

  def save_data(path, datas)
    File.open(path, 'w') { |f| f.write datas.to_yaml } #Storing
  end
end