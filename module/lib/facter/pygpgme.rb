Facter.add('pygpgme_installed') do
  setcode do
    output = Facter::Core::Execution.exec('rpm -qa')
    /^pygpgme.*/.match(output).nil?
  end
end
