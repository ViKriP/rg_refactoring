#module Banking
module Storage
    def accounts
    if File.exists?('../../accounts.yml')
      YAML.load_file('../../accounts.yml')
    else
      []
    end
  end
end
#end
