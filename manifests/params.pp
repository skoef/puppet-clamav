# Documentation goes here
class clamav::params {
  $config_file = $::operatingsystem ? {
    /(?i:FreeBSD)/ => '/usr/local/etc/clamd.conf',
  }

  $freshclam_config_file = $::operatingsystem ? {
    /(?i:FreeBSD)/ => '/usr/local/etc/freshclam.conf',
  }

  $config_file_owner   = $::operatingsystem ? {
    default => 'root',
  }

  $config_file_group   = $::operatingsystem ? {
    /(?i:FreeBSD)/ => 'wheel',
    default        => 'root',
  }

  $dbdir = $::operatingsystem ? {
    /(?i:FreeBSD)/ => '/var/db/clamav'
  }

  $logfile = $::operatingsystem ? {
    /(?i:FreeBSD)/ => '/var/log/clamav/clamd.log',
  }

  $freshclam_logfile = $::operatingsystem ? {
    /(?i:FreeBSD)/ => '/var/log/clamav/freshclam.log',
  }

  $pidfile = $::operatingsystem ? {
    /(?i:FreeBSD)/ => '/var/run/clamav/clamd.pid',
  }

  $freshclam_pidfile = $::operatingsystem ? {
    /(?i:FreeBSD)/ => '/var/run/clamav/freshclam.pid',
  }

  $package_name = $::operatingsystem ? {
    /(?i:FreeBSD)/ => 'security/clamav',
  }

  $process_user = $::operatingsystem ? {
    /(?i:FreeBSD)/ => 'clamav',
  }

  $localsocket = $::operatingsystem ? {
    /(?i:FreeBSD)/ => '/var/run/clamav/clamd.sock',
  }

  $service_name = $::operatingsystem ? {
    /(?i:FreeBSD)/ => 'clamav-clamd',
  }

  $freshclam_service_name = $::operatingsystem ? {
    /(?i:FreeBSD)/ => 'clamav-freshclam',
  }

  $absent                  = false
  $disable                 = false
  $freshclam_disable       = false
  $disableboot             = false
  $freshclam_disableboot   = false
  $service_autorestart     = true
  $freshclam_autorestart   = true
  $config_file_mode        = '0644'
  $template                = 'clamav/clamd.conf.erb'
  $freshclam_template      = 'clamav/freshclam.conf.erb'
  $firewall                = false
  $firewall_src            = ['0.0.0.0', '::/0']
  $firewall_dst            = ['0.0.0.0', '::/0']
  $databasemirror          = 'database.clamav.net'
  $options                 = {
    'LogFile'                  => $logfile,
    'PidFile'                  => $pidfile,
    'DatabaseDirectory'        => $dbdir,
    'LocalSocket'              => $localsocket,
    'FixStaleSocket'           => 'yes',
    'User'                     => $process_user,
    'AllowSupplementaryGroups' => 'yes',
    'ScanMail'                 => 'yes',
  }
  $freshclam_options       = {
    'DatabaseDirectory'        => $dbdir,
    'UpdateLogFile'            => $freshclam_logfile,
    'PidFile'                  => $freshclam_pidfile,
    'DatabaseOwner'            => $process_user,
    'AllowSupplementaryGroups' => 'yes',
    'DatabaseMirror'           => $databasemirror,
    'NotifyClamd'              => $config_file,
  }
}
