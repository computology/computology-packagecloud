Facter.add('osreleasemaj') do
  setcode do
    os_str = Facter.value(:operatingsystemrelease)
    os_str.split('.').first
  end
end
