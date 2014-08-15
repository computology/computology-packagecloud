Facter.add('pygpgme_installed') do
  setcode do
    output = Facter::Core::Execution.exec('rpm -qa | grep pygpgme')
    if !/^pygpgme.*/.match(output).nil?
      'true'
    else
      'false'
    end
  end
end
