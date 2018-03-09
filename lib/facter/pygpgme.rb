Facter.add('pygpgme_installed') do
  setcode do
    os = Facter.value(:operatingsystem)
    case os.downcase
    when /debian|ubuntu|windows/
      'true'
    else
      output = Facter::Core::Execution.exec('rpm -q pygpgme')
      if !/^pygpgme-.*/.match(output).nil?
        'true'
      else
        'false'
      end
    end
  end
end
