Facter.add('pygpgme_installed') do
  setcode do
    os = Facter.value(:operatingsystem)
    case os.downcase
    when /debian|ubuntu/
      'true'
    else
      output = Facter::Core::Execution.exec('rpm -qa | grep pygpgme')
      if !/^pygpgme.*/.match(output).nil?
        'true'
      else
        'false'
      end
    end
  end
end
