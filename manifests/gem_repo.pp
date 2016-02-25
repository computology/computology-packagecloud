define packagecloud::gem_repo(
  $base_url,
  $repo_name,
){

  exec { "install packagecloud ${repo_name} repo as gem source":
    command => "gem source --add ${base_url}/${repo_name}/",
    unless  => "gem source --list | grep ${base_url}/${repo_name}",
  }

}
