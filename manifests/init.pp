# Documentation goes here
class clamav (
  $service_name           = $clamav::params::service_name,
  $freshclam_service_name = $clamav::params::freshclam_service_name,
  $package_name           = $clamav::params::package_name,
  $absent                 = $clamav::params::absent,
  $disable                = $clamav::params::disable,
  $freshclam_disable      = $clamav::params::freshclam_disable,
  $disableboot            = $clamav::params::disableboot,
  $freshclam_disableboot  = $clamav::params::freshclam_disableboot,
  $service_autorestart    = $clamav::params::service_autorestart,
  $freshclam_autorestart  = $clamav::params::freshclam_autorestart,
  $config_dir             = $clamav::params::config_dir,
  $config_file            = $clamav::params::config_file,
  $config_file_owner      = $clamav::params::config_file_owner,
  $config_file_group      = $clamav::params::config_file_group,
  $config_file_mode       = $clamav::params::config_file_mode,
  $freshclam_config_file  = $clamav::params::freshclam_config_file,
  $pidfile                = $clamav::params::pidfile,
  $template               = $clamav::params::template,
  $freshclam_template     = $clamav::params::freshclam_template,
  $firewall               = $clamav::params::firewall,
  $firewall_src           = $clamav::params::firewall_src,
  $firewall_dst           = $clamav::params::firewall_dst,
  $firewall_port          = $clamav::params::firewall_port,
  $databasemirror         = $clamav::params::databasemirror,
  $options                = $clamav::params::options,
  $freshclam_options      = $clamav::params::freshclam_options,
) inherits clamav::params {

  $bool_absent                = any2bool($absent)
  $bool_disable               = any2bool($disable)
  $bool_freshclam_disable     = any2bool($freshclam_disable)
  $bool_freshclam_disableboot = any2bool($freshclam_disableboot)
  $bool_service_autorestart   = any2bool($service_autorestart)
  $bool_freshclam_autorestart = any2bool($freshclam_autorestart)
  $bool_firewall              = any2bool($firewall)

  $manage_package_ensure = $clamav::bool_absent ? {
    true  => 'absent',
    false => 'installed',
  }

  $manage_service_ensure = $clamav::bool_disable ? {
    true    => 'stopped',
    default => $clamav::bool_absent ? {
      true    => 'stopped',
      default => 'running',
    }
  }

  $manage_freshclam_ensure = $clamav::bool_freshclam_disable ? {
    true    => 'stopped',
    default => 'running',
  }

  $manage_freshclam_enable = $clamav::bool_disableboot ? {
    true    => false,
    default => $clamav::bool_disable ? {
      true    => false,
      default => $clamav::bool_absent ? {
        true  => false,
        false => true,
      },
    },
  }

  $manage_service_enable = $clamav::bool_freshclam_disableboot ? {
    true    => false,
    default => $clamav::bool_freshclam_disable ? {
      true    => false,
      false   => true,
    },
  }

  $manage_service_autorestart = $clamav::bool_service_autorestart ? {
    true  => "Service[${clamav::service_name}]",
    false => undef,
  }

  $manage_freshclam_autorestart = $clamav::bool_freshclam_autorestart ? {
    true  => "Service[${clamav::freshclam_service_name}]",
    false => undef,
  }

  $manage_file_ensure = $clamav::bool_absent ? {
    true  => 'absent',
    false => 'file',
  }

  $manage_directory_ensure = $clamav::bool_absent ? {
    true  => 'absent',
    false => 'file',
  }

  package { 'clamav':
    ensure => $manage_package_ensure,
    name   => $clamav::package_name,
  }

  exec { 'freshclam':
    path    => ['/usr/bin', '/usr/local/bin'],
    command => 'freshclam',
    creates => "${clamav::params::dbdir}/mirrors.dat",
    require => File['freshclam.conf'],
    before  => Service['clamav'],
  }

  service { 'clamav':
    ensure  => $manage_service_ensure,
    name    => $clamav::service_name,
    enable  => $manage_service_enable,
    require => Package[$clamav::package_name],
  }

  service { 'freshclam':
    ensure  => $manage_freshclam_ensure,
    name    => $clamav::freshclam_service_name,
    enable  => $manage_freshclam_enable,
    require => Package[$clamav::package_name],
  }

  file { 'clamav.conf':
    path    => $clamav::config_file,
    owner   => $clamav::config_file_owner,
    group   => $clamav::config_file_group,
    mode    => $clamav::config_file_mode,
    content => template($clamav::template),
    notify  => $manage_service_autorestart,
  }

  file { 'freshclam.conf':
    path    => $clamav::freshclam_config_file,
    owner   => $clamav::config_file_owner,
    group   => $clamav::config_file_group,
    mode    => $clamav::config_file_mode,
    content => template($clamav::freshclam_template),
    notify  => $manage_freshclam_autorestart,
  }

  if $bool_firewall == true {
    firewall::rule { 'clamav-allow-in':
      protocol    => 'tcp',
      port        => $firewall_port,
      direction   => 'input',
      source      => $firewall_src,
      destination => $firewall_dst,
    }
  }
}
