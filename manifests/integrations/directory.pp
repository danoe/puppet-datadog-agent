# Class: datadog_agent::integrations::directory
#
# This class will install the necessary config to hook the directory in the agent
#
# Parameters:
#   directory
#       (Required) - string, the directory path to monitor
#       This will be included as a tag: name:<name>.
#
#   name
#       (Optional) - string, tag metrics with specified name. defaults to the "directory"
#
#   dirtagname
#       (Optional) - string, the name of the key for the tag used for the directory, the value will be the value of "name" (see above). The resulting tag will be "<dirtagname>:<name>". defaults to "name"
#
#   filetagname
#       (Optional) - string, the name of the key for the tag used for each file, the value will be the filename. The resulting tag will be "<filetagname>:<filename>". defaults to "filename"
#
#   filegauges
#       (Optional) - boolean, when true stats will be an individual gauge per file (max. 20 files!) and not a histogram of the whole directory. default False
#
#   pattern
#       (Optional) - string, the `fnmatch` pattern to use when reading the "directory"'s files. The pattern will be matched against the files' absolute paths and relative paths in "directory". default "*"
#
#   recursive
#       (Optional) - boolean, when true the stats will recurse into directories. default False
#
#   countonly
#       (Optional) - boolean, when true the stats will only count the number of files matching the pattern. Useful for very large directories.
#
#
# Sample Usage:
#
# Add a class for each check instance:
#
# class { 'datadog_agent::integrations::directory':
#   directory => '/opt/ftp_data',
#   recursive => true,
#   countonly => true,
# }
#
# Add multiple instances in one class declaration:
#
# class { 'datadog_agent::integrations::directory':
#   instances => [{
#     'directory' => '/opt/ftp_data',
#     'recursive' => true,
#     'countonly' => true,
#     },
#     'directory' => '/opt/ftp_data-staging',
#     'recursive' => true,
#     'countonly' => true,
#     },
#   ]
# }

class datadog_agent::integrations::directory (
  $directory   = '',
  $filegauges  = false,
  $recursive   = true,
  $countonly   = false,
  $nametag     = '',
  $dirtagname  = '',
  $filetagname = '',
  $pattern     = '',
  $instances   = undef,
) inherits datadog_agent::params {
  include datadog_agent

  validate_string($directory)
  validate_bool($filegauges)
  validate_bool($recursive)
  validate_bool($countonly)

  if !$instances and $directory == '' {
    fail('bad directory argument and no instances hash provided')
  }

  if !$instances and $directory {
    $_instances = [{
      'directory'   => $directory,
      'filegauges'  => $filegauges,
      'recursive'  => $recursive,
      'countonly' => $countonly,
      'name' => $nametag,
      'dirtagname' => $dirtagname,
      'filetagname' => $filetagname,
      'pattern' => $pattern,
    }]
  } elsif !$instances{
    $_instances = []
  } else {
    $_instances = $instances
  }

  if $::datadog_agent::agent6_enable {
    $dst = "${datadog_agent::conf6_dir}/directory.yaml"
  } else {
    $dst = "${datadog_agent::conf_dir}/directory.yaml"
  }

  file { $dst:
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0600',
    content => template('datadog_agent/agent-conf.d/directory.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
